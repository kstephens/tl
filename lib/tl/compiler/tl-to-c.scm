;; A TL-to-C compiler.
;; Author: Kurt Stephens

;; Based on a "Scheme-to-C Compiler."
;; http://matt.might.net/articles/compiling-scheme-to-c/.
;;
;; Author: Matthew Might
;; Site:   http://matt.might.net/
;;         http://www.ucombinator.org/

;; Utilities.
(define (%string-truncate! s l)
  (let ((t (make-string l)))
    (string-copy! t 0 s 0 l)
    t))
(load "tl/string.scm")
(define closure->formals tl_closure_formals)
(define closure->body    tl_closure_body)
(define closure->environ tl_cdr) ;; see L(proc) in tl_eval().

;; TL top-level environment.
(define tl-top-level-env (tl_get_top_level_env))
(define (tl-lookup-slot sym)
  (let ((b (tl_lookup sym tl-top-level-env)))
    (if (null? b) #f
      (cons sym (car b)))))

(define (void) (if #f #t))
(define (tagged-list? tag l)
  (and (pair? l)
       (eq? tag (car l))
       l))
(define (char->natural c)
  (let ((i (char->integer c)))
    (if (< i 0)
        (* -2 i)
        (+ (* 2 i) 1))))
(define (integer->char-list n)
  (string->list (number->string n)))
(define gensym-count 0)
(define gensym (lambda params
                 (set! gensym-count (+ gensym-count 1))
                       (string->symbol (string-append 
                                        (if (null? params) ""
                                        (if (symbol? (car params))
                                            (symbol->string (car params))
                                            (car params)))
                                        "$"
                                        (number->string gensym-count)))))
(define (symbol<? sym1 sym2)
  (string<? (symbol->string sym1)
            (symbol->string sym2)))
(define (insert sym S)
  (if (not (pair? S))
      (list sym)
      (cond
        ((eq? sym (car S))       S)
        ((symbol<? sym (car S))  (cons sym S))
        (else (cons (car S) (insert sym (cdr S)))))))
(define (remove sym S)
  (if (not (pair? S))
      '()
      (if (eq? (car S) sym)
          (cdr S)
          (cons (car S) (remove sym (cdr S))))))
(define (union set1 set2)
  ; NOTE: This should be implemented as merge for efficiency.
  (if (not (pair? set1))
      set2
      (insert (car set1) (union (cdr set1) set2))))
(define (difference set1 set2)
  ; NOTE: This can be similarly optimized.
  (if (not (pair? set2))
      set1
      (difference (remove (car set2) set1) (cdr set2))))
(define (reduce f lst init)
  (if (not (pair? lst))
      init
      (reduce f (cdr lst) (f (car lst) init))))
(define (azip list1 list2)
  (if (and (pair? list1) (pair? list2))
      (cons (list (car list1) (car list2))
            (azip (cdr list1) (cdr list2)))
      '()))
(define (assq-remove-key env key)
  (if (not (pair? env))
      '()
      (if (eq? (car (car env)) key)
          (assq-remove-key (cdr env) key)
          (cons (car env) (assq-remove-key (cdr env) key)))))
(define (assq-remove-keys env keys)
  (if (not (pair? keys))
      env
      (assq-remove-keys (assq-remove-key env (car keys)) (cdr keys))))

;; Data type predicates and accessors.

(define (immediate-const? exp)
  (or (integer? exp)
      (boolean? exp)
      (character? exp)
      (void? exp)))
(define (const? exp)
  (or (immediate-const? exp)
      (string? exp)))

(define (quote? exp)
  (tagged-list? 'quote exp))
(define (quote->value exp)
  (cadr exp))

(define (c-var? exp)
  (tagged-list? '&c:var exp))
(define (c-func? exp)
  (tagged-list? '&c:func exp))

(define (ref? exp)
  (symbol? exp))

(define (let? exp)
  (tagged-list? 'let exp))
(define (let->bindings exp)
  (cadr exp))
(define (let->body exp)
  (cddr exp))
(define (let->bound-vars exp)
  (map car (cadr exp)))
(define (let->args exp)
  (map cadr (cadr exp)))

(define (letrec? exp)
  (tagged-list? 'letrec exp))
(define (letrec->bindings exp)
  (cadr exp))
(define (letrec->body exp)
  (cddr exp))
(define (letrec->bound-vars exp)
  (map car (cadr exp)))
(define (letrec->args exp)
  (map cadr (cadr exp)))

(define (lambda? exp)
  (tagged-list? 'lambda exp))
(define (lambda->formals exp)
  (cadr exp))
(define (lambda->exp exp)
  (caddr exp))
(define (lambda->body exp)
  (cddr exp))

(define (restarg? exp)
  (and (tagged-list? '&rest exp) (restarg->name exp)))
(define (restarg->name exp)
  (cadr exp))

(define (if? exp)
  (tagged-list? 'if exp))
(define (if->condition exp)
  (cadr exp))
(define (if->then exp)
  (caddr exp))
(define (if->else exp)
  (let ((tail (cdddr exp)))
    (if (pair? tail) (car tail) tl_v)))

(define (app? exp)
  (pair? exp))
(define (app->fun exp)
  (car exp))
(define (app->args exp)
  (cdr exp))

(define (prim? exp)
  (or (c-func? exp)
    (and (symbol? exp)
      (let ((slot (tl-lookup-slot exp)))
        (and slot (primitive? (cdr slot)) (cdr slot))))))
(define (prim->name prim)
  (if (c-func? prim) (symbol->string (cadr prim))
    (primitive->name prim)))

(define (begin? exp) 
  (tagged-list? 'begin exp))
(define (begin->exps exp)
  (cdr exp))

(define (set!? exp)
  (tagged-list? 'set! exp))
(define (set!->var exp)
  (cadr exp))
(define (set!->exp exp)
  (caddr exp))

(define (comp:closure? exp)
  (tagged-list? 'closure exp))
(define (closure->lam exp) 
  (cadr exp))
(define (closure->env exp) 
  (caddr exp))

(define (env-make? exp) 
  (tagged-list? 'env-make exp))
(define (env-make->id exp)
  (cadr exp))
(define (env-make->fields exp)
  (map car (cddr exp)))
(define (env-make->values exp)
  (map cadr (cddr exp)))
(define (env-get? exp)
  (tagged-list? 'env-get exp))
(define (env-get->id exp)
  (cadr exp))
(define (env-get->field exp)
  (caddr exp))
(define (env-get->env exp)
  (cadddr exp)) 

(define (set-cell!? exp)
  (tagged-list? 'set-cell! exp))
(define (set-cell!->cell exp)
  (cadr exp))
(define (set-cell!->value exp)
  (caddr exp))

(define (cell? exp)
  (tagged-list? '%cell exp))
(define (cell->value exp)
  (cadr exp))
(define (cell-get? exp)
  (tagged-list? '%cell-get exp))
(define (cell-get->cell exp)
  (cadr exp))

;; Syntax manipulation.

(define (substitute-var env var)
  (let ((sub (assq var env)))
    (if sub
        (cadr sub)
        var)))
(define (substitute-with env)
  (lambda (exp)
    (substitute env exp)))
(define (substitute env exp)
  (cond
    ; Core forms:    
    ((null? env)        exp)
    ((quote? exp)       exp)
    ((const? exp)       exp)
    ((c-var? exp)       exp)
    ((prim? exp)        exp)
    ((ref? exp)         (substitute-var env exp))
    ((lambda? exp)      `(lambda ,(lambda->formals exp)
                           ,(substitute (assq-remove-keys env (formals=>names (lambda->formals exp))) 
                                        (lambda->exp exp))))
    ((set!? exp)        `(set! ,(substitute-var env (set!->var exp))
                               ,(substitute env (set!->exp exp))))
    ((if? exp)          `(if ,(substitute env (if->condition exp))
                             ,(substitute env (if->then exp))
                             ,(substitute env (if->else exp))))
    ; Sugar:
    ((let? exp)         (let ((new-env (assq-remove-keys env (let->bound-vars exp))))
                          `(let ,(azip (let->bound-vars exp)
                                     (map (substitute-with env) (let->args exp)))
                           ,@(map (substitute-wth new-env) (let->body exp))))
    ((letrec? exp)      (let ((new-env (assq-remove-keys env (letrec->bound-vars exp))))
                          `(letrec ,(azip (letrec->bound-vars exp) 
                                          (map (substitute-with new-env) 
                                               (letrec->args exp)))
                             ,@(map (substitute-with new-env) (letrec->body exp)))))
    ((begin? exp)       (cons 'begin (map (substitute-with env) (begin->exps exp))))
    ; IR (1):
    ((cell? exp)        `(%cell      ,(substitute env (cell->value exp))))
    ((cell-get? exp)    `(%cell-get  ,(substitute env (cell-get->cell exp))))
    ((set-cell!? exp)   `(%set-cell! ,(substitute env (set-cell!->cell exp))
                                     ,(substitute env (set-cell!->value exp))))
    ; IR (2):
    ((comp:closure? exp)`(closure ,(substitute env (closure->lam exp))
                                  ,(substitute env (closure->env exp))))
    ((env-make? exp)    `(env-make ,(env-make->id exp) 
                                   ,@(azip (env-make->fields exp)
                                           (map (substitute-with env)
                                                (env-make->values exp)))))
    ((env-get? exp)     `(env-get ,(env-get->id exp)
                                  ,(env-get->field exp)
                                  ,(substitute env (env-get->env exp))))
    ; Application:
    ((app? exp)         (map (substitute-with env) exp))
    (else               (error "substitute: unhandled expression type: " exp))))


;; Import top-level definitions as referenced from tl-lookup-slot.
(define imports '())
(define import-anons '())
(define (import-anon exp env)
  (let ((slot (assq exp import-anons)))
    (if slot (cadr slot)
      (let ((name (gensym '%import-anon-)))
        ;; (write (list 'import-anon exp '=> name) tl_stderr)(newline tl_stderr)
        (set! import-anons (cons (list exp name) import-anons))
        (set! slot (list name exp '=> exp))
        (set! imports (cons slot imports))
        (set-car! (cdr slot) (import-value exp env))
        name))))
(define (import-value exp env)
  (cond
    ((closure? exp)
      (let (($exp `(lambda ,(closure->formals exp) ,@(closure->body exp))))
        (import $exp env)))
    (else `(quote ,exp))))
(define (import-ref exp env)
  ;; (display "  " tl_stderr)(write (list 'import-ref env exp) tl_stderr)(newline tl_stderr)
  (if (not (or (memq exp env) (assq exp imports)))
    (let ((slot (tl-lookup-slot exp)))
      (if slot ;; (name . val)
        (begin
          (set! slot (list exp (cdr slot))) ;; (name val)
          ;; (display "import-ref " tl_stderr)(write slot tl_stderr)(newline tl_stderr)
          (set! imports (cons slot imports))
          (set-car! (cdr slot) (import-anon (cadr slot) env))))))
  exp)
(define (import exp env)
  ;; (display "  " tl_stderr)(write (list 'import exp env) tl_stderr)(newline tl_stderr)
  (cond
    ; Core forms:
    ((quote? exp)      exp)
    ((const? exp)      exp)
    ((c-var? exp)      exp)
    ((prim? exp)       exp)
    ((ref? exp)        (import-ref exp env))
    ((closure? exp)    (import-anon exp env))
    ((lambda? exp)     (let (($env (append (formals=>names (lambda->formals exp)) env)))
                         `(lambda ,(lambda->formals exp)
                            ,@(map (lambda (x) (import x $env)) (lambda->body exp)))))
    ((set!? exp)       `(set! ,(set!->var exp) ,(import (set!->exp exp) env)))
    ((if? exp)         `(if ,@(map (lambda (x) (import x env)) (cdr exp))))

    ; Sugar
    ((let? exp)        (let ((bindings (map (lambda (x) (list (car x) (import (cadr x) env))) (let->bindings exp)))
                              ($env (append (let->bound-vars exp) env)))
                         `(let ,bindings
                            ,@(map (lambda (x) (import x $env)) (let->body exp)))))
    ((begin? exp)      `(begin ,(map (lambda (x) (import x env)) (cdr exp))))
    
    ; Applications:
    ((app? exp)        (map (lambda (x) (import x env)) exp))
    (else              (error "import: unknown exp: " exp))))


;; literals.

(define literals '())
(define (find-literal val)
  (assoc val literals))
(define (capture-literal val)
  (if (immediate-const? val) val
    (let ((lit (find-literal val)))
      (if lit (cadr lit)
        (let ((var (gensym '%lit)))
          (set! literals (cons (list val var) literals))
          var)))))
(define (convert-literals exp)
  ;; (display "convert-literals " tl_stderr) (write exp tl_stderr) (display "\n" tl_stderr)
  (cond
    ; Core forms:
    ((quote? exp)      (if (null? (quote->value exp)) exp (capture-literal (quote->value exp))))
    ((string? exp)     (capture-literal exp))
    ((const? exp)      exp)
    ((c-var? exp)      exp)
    ((prim? exp)       exp)
    ((ref? exp)        exp)
    ((lambda? exp)     `(lambda ,(lambda->formals exp)
                          ,@(map convert-literals (lambda->body exp))))
    ((set!? exp)       `(set! ,(set!->var exp) ,(convert-literals (set!->exp exp))))
    ((if? exp)         `(if ,(convert-literals (if->condition exp))
                            ,(convert-literals (if->then exp))
                            ,(convert-literals (if->else exp))))
    ; Sugar:
    ((let? exp)      `(let
                       ,(map convert-literals-binding (let->bindings exp))
                       ,@(map convert-literals (let->body exp))))
    ((letrec? exp)   `(letrec
                       ,(map convert-literals-binding (letrec->bindings exp)))
                       ,@(map convert-literals (letrec->body exp)))
    ((begin? exp)    `(begin
                       ,@(map convert-literals (begin->exps exp))))
    ; Applications:
    ((app? exp)        (map convert-literals exp))
    (else              (error "convert-literals: unknown exp: " exp))))
(define (convert-literals-binding b)
  (list (car b) (convert-literals (cadr b))))
(define (bind-literals literals exp)
  `(let ,(map literal-binding literals) ,exp))
(define (literal-binding lit)
  `(,(cadr lit) ,(encode-literal (car lit))))
(define (encode-literal exp)
  (cond
    ((null? exp)   `(quote ,exp))
    ((symbol? exp) `((&c:func tl_m_symbol) ((&c:func tl_S) ,(symbol->string exp))))
    ((pair? exp)   (list '(&c:func tl_cons) (encode-literal (car exp)) (encode-literal (cdr exp))))
    ((vector? exp) (list 'list->vector (encode-literal (vector->list exp))))
    ((void? exp)   '((&c:var tl_v)))
    ((type? exp)   (encode-type exp))
    (else          exp)))
(define (encode-type exp)
  (cond
    ((eq? (tl_type tl_v) exp)  '(tl_type (&c:var tl_v)))
    ((eq? (tl_type 1) exp)     '(tl_type 1))
    ((eq? (tl_type #\a) exp)   '(tl_type #\a))
    ((eq? (tl_type "") exp)    '(tl_type ""))
    ((eq? (tl_type 'tl_type) exp) '(tl_type 'tl_type))
    ((eq? (tl_type '()) exp)      '(tl_type '()))
    ((eq? (tl_type (cons '() '())) exp)
      `(tl_type (cons '() ())))
    ((eq? (tl_type '#()) exp)     '(tl_type '#()))
    (else exp)))
    
;; Desugaring.

(define (formals=>restarg formals)
  (cond
    ((null? formals)    formals)
    ((symbol? formals)  `((&rest ,formals)))
    ((pair? formals)    (cons (car formals) (formals=>restarg (cdr formals))))
    (else               (formals=>restarg (cdr formals)))))
(define (formal->name formal)
  (cond
    ((restarg? formal)  (restarg->name formal))
    (else               formal)))
(define (formals=>names formals)
  (cond
    ((null? formals)    formals)
    ((symbol? formals)  (cons formals '()))
    ((pair? formals)    (cons (formal->name (car formals)) (formals=>names (cdr formals))))
    (else               (error "formals=>names"))))
(define (formals-restarg? formals)
  (define (find-lastarg-restarg last formals)
    (cond
      ((null? formals)    #f)
      ((symbol? formals)  (cons last formals))
      ((pair? formals)    (let* ((cur (car formals))
                                  (rest (restarg? cur)))
                            (or (and rest (cons last rest))
                              (find-lastarg-restarg cur (cdr formals)))))
      (else               (error "formals-restarg?"))))
  (find-lastarg-restarg #f formals))
(define (body=>begin body)
  (cond
    ((null? body) (list 'quote tl_v))
    ;; ((null? body) `',tl_v)
    ((not (pair? (cdr body))) (car body))
    (else `(begin ,@body))))
(define (let=>lambda exp)
  (if (let? exp)
      (let ((vars (map car (let->bindings exp)))
            (args (map cadr (let->bindings exp))))
        `((lambda (,@vars) ,@(let->body exp)) ,@args))
      exp))
(define (letrec=>lets+sets exp)
  (if (letrec? exp)
      (let* ((bindings  (letrec->bindings exp))
             (namings   (map (lambda (b) (list (car b) #f)) bindings))
             (names     (letrec->bound-vars exp))
             (sets      (map (lambda (binding) 
                               (cons 'set! binding))
                             bindings))
             (args      (letrec->args exp)))
        `(let ,namings
           (begin ,@(append sets (letrec->body exp)))))))
(define (singlet? l)
  (and (pair? l) (null? (cdr l))))
(define (begin=>let exp)
  (define (dummy-bind exps)
    (cond
      ((singlet? exps)  (car exps))
      
      ((pair? exps)     `(let (($_ ,(car exps)))
                          ,(dummy-bind (cdr exps))))))
  (dummy-bind (begin->exps exp)))

; desugar : exp -> exp
(define (desugar exp)
  (cond
    ; Core forms:
    ((quote? exp)      exp)
    ((const? exp)      exp)
    ((c-var? exp)      exp)
    ((prim? exp)       exp)
    ((ref? exp)        exp)
    ((closure? exp)    exp)
    ((lambda? exp)     `(lambda ,(formals=>restarg (lambda->formals exp))
                          ,(desugar (body=>begin (lambda->body exp)))))
    ((set!? exp)       `(set! ,(set!->var exp) ,(desugar (set!->exp exp))))
    ((if? exp)         `(if ,(desugar (if->condition exp))
                            ,(desugar (if->then exp))
                            ,(desugar (if->else exp))))
    ; Sugar:
    ((let? exp)        (desugar (let=>lambda exp)))
    ((letrec? exp)     (desugar (letrec=>lets+sets exp)))
    ;;  ((begin? exp)      (desugar (begin=>let exp)))
    ; IR (1):
    ((cell? exp)       `(%cell      ,(desugar (cell->value exp))))
    ((cell-get? exp)   `(%cell-get  ,(desugar (cell-get->cell exp))))
    ((set-cell!? exp)  `(%set-cell! ,(desugar (set-cell!->cell exp))
                                    ,(desugar (set-cell!->value exp))))
    ; IR (2): 
    ((comp:closure? exp) `(closure ,(desugar (closure->lam exp))
                                 ,(desugar (closure->env exp))))
    ((env-make? exp)   `(env-make ,(env-make->id exp)
                                  ,@(azip (env-make->fields exp)
                                          (map desugar (env-make->values exp)))))
    ((env-get? exp)    `(env-get ,(env-get->id exp)
                                 ,(env-get->field exp)
                                 ,(env-get->env exp)))
    ; Applications:
    ((app? exp)        (map desugar exp))    
    (else              (error "desugar: unknown exp: " exp))))
    
;; Syntactic analysis.

; free-vars : exp -> sorted-set[var]
(define (free-vars exp)
  (cond
    ; Core forms:
    ((quote? exp)    '())
    ((const? exp)    '())
    ((c-var? exp)    '())
    ((prim? exp)     '())
    ((ref? exp)      (list exp))
    ((lambda? exp)   (difference (free-vars (lambda->exp exp))
                                 (formals=>names (lambda->formals exp))))
    ((if? exp)       (union (free-vars (if->condition exp))
                            (union (free-vars (if->then exp))
                                   (free-vars (if->else exp)))))
    ((set!? exp)     (union (list (set!->var exp)) 
                            (free-vars (set!->exp exp))))
    ; Sugar:
    ((let? exp)      (free-vars (let=>lambda exp)))
    ((letrec? exp)   not-handled)
    ((begin? exp)    (reduce union (map free-vars (begin->exps exp)) '()))
    ; IR (1):
    ((cell-get? exp)  (free-vars (cell-get->cell exp)))
    ((cell? exp)      (free-vars (cell->value exp)))
    ((set-cell!? exp) (union (free-vars (set-cell!->cell exp))
                             (free-vars (set-cell!->value exp))))
    ; IR (2):
    ((comp:closure? exp)(union (free-vars (closure->lam exp))
                             (free-vars (closure->env exp))))
    ((env-make? exp)  (reduce union (map free-vars (env-make->values exp)) '()))
    ((env-get? exp)   (free-vars (env-get->env exp)))
    ; Application:
    ((app? exp)       (reduce union (map free-vars exp) '()))
    (else             (error "free-vars: unknown expression: " exp))))

;; Mutable variable analysis and elimination.
;;
;; Mutables variables analysis and elimination happens
;; on a desugared Intermediate Language (1).
;;
;; Mutable variable analysis turns mutable variables 
;; into heap-allocated cells:

(define mutable-variables '())
(define (mark-mutable symbol)
  (set! mutable-variables (cons symbol mutable-variables)))
(define (is-mutable? symbol)
  (memq symbol mutable-variables))
(define (analyze-mutable-variables exp)
  (cond 
    ; Core forms:
    ((quote? exp)    (void))
    ((const? exp)    (void))
    ((c-var? exp)    (void))
    ((prim? exp)     (void))
    ((ref? exp)      (void))
    ((lambda? exp)   (for-each analyze-mutable-variables (lambda->body exp)))
    ((set!? exp)     (begin
                       (mark-mutable (set!->var exp))
                       (analyze-mutable-variables (set!->exp exp))))
    ((if? exp)       (begin
                       (analyze-mutable-variables (if->condition exp))
                       (analyze-mutable-variables (if->then exp))
                       (analyze-mutable-variables (if->else exp))))
    ; Sugar:
    ((let? exp)      (begin
                       (for-each analyze-mutable-variables (map cadr (let->bindings exp)))
                       (for-each analyze-mutable-variables (let->body exp))))
    ((letrec? exp)   (begin
                       (for-each analyze-mutable-variables (map cadr (letrec->bindings exp)))
                       (for-each analyze-mutable-variables (letrec->body exp))))
    ((begin? exp)    (for-each analyze-mutable-variables (begin->exps exp))
    ; Application:
    ((app? exp)      (for-each analyze-mutable-variables exp))
    (else            (error "analyze-mutable-variables: unknown expression type: " exp))))
(define (wrap-mutable-formals formals body-exp)
  (if (not (pair? formals))
    body-exp
    (if (is-mutable? (car formals))
      `(let ((,(car formals) (&cell ,(car formals))))
         ,(wrap-mutable-formals (cdr formals) body-exp))
      (wrap-mutable-formals (cdr formals) body-exp))))
(define (wrap-mutables exp)
  (cond
    ; Core forms:
    ((quote? exp)    exp)
    ((const? exp)    exp)
    ((c-var? exp)    exp)
    ((ref? exp)      (if (is-mutable? exp)
                         `(%cell-get ,exp)
                         exp))
    ((prim? exp)     exp)
    ((lambda? exp)   `(lambda ,(lambda->formals exp)
                        ,(wrap-mutable-formals (formals=>names (lambda->formals exp))
                                               (wrap-mutables (lambda->exp exp)))))
    ((set!? exp)     `(%set-cell! ,(set!->var exp) ,(wrap-mutables (set!->exp exp))))
    ((if? exp)       `(if ,(wrap-mutables (if->condition exp))
                          ,(wrap-mutables (if->then exp))
                          ,(wrap-mutables (if->else exp))))
    ; Application:
    ((app? exp)      (map wrap-mutables exp))
    (else            (error "wrap-mutables: unknown expression type: " exp))))
                        

;; Name-mangling.

;; We have to "mangle" Scheme identifiers into
;; C-compatible identifiers, because names like
;; foo-bar/baz are not identifiers in C.

(define (mangle symbol)
  (define (m chars)
    (if (null? chars)
        '()
        (if (or (and (char-alphabetic? (car chars)) (not (char=? (car chars) #\_)))
                (char-numeric? (car chars)))
            (cons (car chars) (m (cdr chars)))
            (cons #\_ (append (integer->char-list (char->natural (car chars)))
                              (m (cdr chars)))))))
  (list->string (m (string->list (symbol->string symbol)))))

;; Closure-conversion.

;; Closure conversion operates on a desugared
;; Intermediate Language (2).  Closure conversion
;; eliminates all of the free variables from every
;; lambda term.

;; The transform is:

;;  (lambda (v1 ... vn) body)
;;             =>
;;  (closure (lambda ($env v1 ... vn) 
;;                   {xi => (env-get $id xi $env)}body)
;;           (env-make $id (x1 x1) ... (xn xn)))

;;  where x1,...xn are the free variables in the lambda term.

; type env-id = natural

(define num-environments 0)
(define environments '())
(define (allocate-environment fields)
  (let ((env (assoc fields environments)))
    (if env (cadr env)
      (begin
        (set! num-environments (+ 1 num-environments))
        (set! environments (cons (list fields num-environments) environments))
        num-environments))))
(define (get-environment id)
  (cdr (assv id environments)))
(define (closure-convert exp)
  (cond
    ((quote? exp)        exp)
    ((const? exp)        exp)
    ((c-var? exp)        exp)
    ((prim? exp)         exp)
    ((ref? exp)          exp)
    ((lambda? exp)       (let* (($env (gensym 'env))
                                (body  (closure-convert (lambda->exp exp)))
                                (fv    (difference (free-vars body) (formals=>names (lambda->formals exp))))
                                (id    (allocate-environment fv))
                                (sub  (map (lambda (v)
                                             (list v `(env-get ,id ,v ,$env)))
                                           fv)))
                           `(closure (lambda (,$env ,@(lambda->formals exp))
                                       ,(substitute sub body))
                                     (env-make ,id ,@(azip fv fv)))))
    ((if? exp)           `(if ,(closure-convert (if->condition exp))
                              ,(closure-convert (if->then exp))
                              ,(closure-convert (if->else exp))))
    ((begin? exp)        `(begin ,@(map closure-convert (begin->exps exp))))
    ((set!? exp)         `(set! ,(set!->var exp)
                                ,(closure-convert (set!->exp exp))))
    ; IR (1):
    ((cell? exp)         `(%cell      ,(closure-convert (cell->value exp))))
    ((cell-get? exp)     `(%cell-get  ,(closure-convert (cell-get->cell exp))))
    ((set-cell!? exp)    `(%set-cell! ,(closure-convert (set-cell!->cell exp))
                                      ,(closure-convert (set-cell!->value exp))))
    ; Applications:
    ((app? exp)          (map closure-convert exp))
    (else                (error "closure-convert: unhandled exp: " exp))))
    

;; Compilation routines.

; c-compile-program : exp -> string
(define (c-compile-program exp)
  (let* ((preamble "")
         (append-preamble (lambda (s)
                            (set! preamble (string-append preamble "  " s "\n"))))
         (body (c-compile-exp exp append-preamble)))
    (string-append 
     "int _tl_main (int argc, char* argv[]) {\n"
     preamble 
     "  " body " ;\n"
     "  return 0;\n"
     " }\n")))

; c-compile-exp : exp (string -> void) -> string
(define (c-compile-exp exp append-preamble)
  (cond
    ; Core forms:
    ((quote? exp)       (c-compile-const (quote->value exp)))
    ((const? exp)       (c-compile-const exp))
    ((c-var? exp)       (c-compile-c-var exp))
    ((ref?   exp)       (c-compile-ref exp))
    ((if? exp)          (c-compile-if exp append-preamble))
    ((begin? exp)       (c-compile-body (begin->exps exp) append-preamble))
    ; IR (1):
    ((cell? exp)        (c-compile-cell exp append-preamble))
    ((cell-get? exp)    (c-compile-cell-get exp append-preamble))
    ((set-cell!? exp)   (c-compile-set-cell! exp append-preamble))
    ; IR (2):
    ((comp:closure? exp)(c-compile-closure exp append-preamble))
    ((env-make? exp)    (c-compile-env-make exp append-preamble))
    ((env-get? exp)     (c-compile-env-get exp append-preamble))
    ; Application:      
    ((app? exp)         (c-compile-app exp append-preamble))
    (else               (error "c-compile-exp: unknown exp " exp))))
(define (c-compile-const exp)
  (cond
    ((integer? exp) (string-append 
                     "tl_i(" (number->string exp) ")"))
    ((boolean? exp) (string-append
                     "tl_b(" (if exp "1" "0") ")"))
    ((character? exp) (string-append
                     "tl_c(" (char->integer exp) ")"))
    ((string? exp)  (string-append
                     "tl_m_string(\"" (%string-escape exp) "\", " (number->string (string-length exp)) ")"))
    ((symbol? exp)  (string-append
                     "tl_m_symbol(\"" (%string-escape (symbol->string exp)) "\")"))
    ((null? exp)    "tl_nil")
    ((void? exp)    "tl_v")
    (else           (error "c-compile-const: unknown constant: " exp))))
(define (c-compile-c-var exp)
  (symbol->string (cadr exp)))
(define (c-compile-ref exp)
  (string-append "_" (mangle exp)))
(define (c-compile-args args append-preamble)
  (if (not (pair? args))
      ""
      (string-append
       (c-compile-exp (car args) append-preamble)
       (if (pair? (cdr args))
           (string-append ", " (c-compile-args (cdr args) append-preamble))
           ""))))
(define (c-compile-body body append-preamble)
  (string-append "(" (c-compile-body-exprs body append-preamble) ")"))
(define (c-compile-body-exprs body append-preamble)
  (if (not (pair? body))
      ""
      (string-append
       (c-compile-exp (car body) append-preamble)
       (if (pair? (cdr body))
           (string-append ",\n  " (c-compile-body-exprs (cdr body) append-preamble))
           ""))))
(define (c-compile-app exp append-preamble)
  (let ((prim (prim? (app->fun exp))))
    (if prim
      (c-compile-app-prim exp prim append-preamble)
      (c-compile-app-closure exp append-preamble))))
(define (c-compile-app-prim exp prim append-preamble)
  (let ((args     (app->args exp))
        (fun      (app->fun exp)))
    (string-append
      "(" (prim->name prim)
      "(" (c-compile-args args append-preamble) "))")))
(define (c-compile-app-closure exp append-preamble)
  (let (($tmp (mangle (gensym 'tmp))))    
    (append-preamble (string-append
                      "tl " $tmp " ; "))
    (let  ((args     (app->args exp))
           (fun      (app->fun exp)))
      (string-append
       "("  $tmp " = " (c-compile-exp fun append-preamble) 
       ", "
       "tl_FP(" $tmp ",tl,())("
       "tl_closure_env(" $tmp ")"
       (if (null? args) "" ", ")
       (c-compile-args args append-preamble)
       ", tl_MARK"
       "))"))))
(define (c-compile-if exp append-preamble)
  (string-append
   "tl_B(" (c-compile-exp (if->condition exp) append-preamble) ") ? "
   "(" (c-compile-exp (if->then exp) append-preamble)      ") : "
   "(" (c-compile-exp (if->else exp) append-preamble)      ")"))
(define (c-compile-set-cell! exp append-preamble)
  (string-append
   "("
   "(*(tl*) " (c-compile-exp (set-cell!->cell exp) append-preamble) ")"
   " = "
   (c-compile-exp (set-cell!->value exp) append-preamble)
   ")"))
(define (c-compile-cell-get exp append-preamble)
  (string-append
   "(*(tl*) " (c-compile-exp (cell-get->cell exp) append-preamble) ")"
    ))
(define (c-compile-cell exp append-preamble)
  (string-append
   "tl_m_cell(" (c-compile-exp (cell->value exp) append-preamble) ")"))
(define (c-compile-env-make exp append-preamble)
  (string-append
   "__alloc_env_" (number->string (env-make->id exp))
   "(" (c-compile-args (env-make->values exp) append-preamble) ")"))
(define (c-compile-env-get exp append-preamble)
  (string-append
   "((struct __env_"
   (number->string (env-get->id exp)) "*) "
   (c-compile-exp (env-get->env exp) append-preamble) ")->_"
   (mangle (env-get->field exp))))

;; Lambda compilation.

;; Lambdas get compiled into procedures that, 
;; once given a C name, produce a C function
;; definition with that name.

;; These procedures are stored up and eventually 
;; emitted.

(define num-lambdas 0)
(define lambdas '())
(define (allocate-lambda lam)
  (let ((id num-lambdas))
    (set! num-lambdas (+ 1 num-lambdas))
    (set! lambdas (cons (list id lam (c-compile-lambda lam)) lambdas))
    id))
(define (get-lambda id)
  (cdr (assv id lambdas)))
(define (c-compile-closure exp append-preamble)
  (let* ((lam (closure->lam exp))
         (env (closure->env exp))
         (lid (allocate-lambda lam)))
    (string-append
     "tl_m_closure("
     "__lambda_" (number->string lid)
     ", "
     (c-compile-exp env append-preamble)
     ")")))
(define (c-compile-formals formals)
  (if (not (pair? formals))
      ""
      (string-append
        (c-compile-formal (car formals))
       (if (pair? (cdr formals))
           (string-append ", " (c-compile-formals (cdr formals)))
           ""))))
(define (c-compile-formal formal)
  (cond
    ((restarg? formal)  (string-append
                          "..." " /* " (symbol->string (restarg->name formal)) " */" ))
    (else               (string-append
                          "tl " (c-compile-ref formal) " /* " (symbol->string formal) " */"))))
(define (c-compile-lambda exp)
  (let* ((preamble "")
         (append-preamble (lambda (s)
                            (set! preamble (string-append preamble "  " s "\n"))))
         (restarg (formals-restarg? (lambda->formals exp))))
    (let ((formals (c-compile-formals (lambda->formals exp)))
          (body    (c-compile-body    (lambda->body exp) append-preamble)))
      (if restarg
        (begin
          (append-preamble (string-append "tl " (c-compile-ref (cdr restarg)) " ;"))
          (append-preamble "{ va_list vap ;")
          (append-preamble (string-append "va_start(vap, " (c-compile-ref (car restarg)) ") ;"))
          (append-preamble (string-append (c-compile-ref (cdr restarg)) " = tl_va_restarg(&vap) ;"))
          (append-preamble "va_end(vap) ; }")
          ))
      (lambda (name)
        (string-append "static tl " name "(" formals ") {\n"
                       preamble
                       "  return " body " ;\n"
                       "}\n")))))
(define (c-compile-env-struct env)
  (let* ((id     (cadr env))
         (fields (car env))
         (sid    (number->string id))
         (tyname (string-append "struct __env_" sid)))
    (string-append 
     "struct __env_" (number->string id) " {\n"
      " const char **names;\n"
     (apply string-append (map (lambda (f)
                                 (string-append
                                  " tl _"
                                  (mangle f) 
                                  " ; \n"))
                               fields))
     "} ;\n\n"
     "static " tyname "*" " __alloc_env_" sid
     "(" (c-compile-formals fields) ")" "{\n"
      "  static const char *names[] = { "
      (apply string-append
            (map (lambda (f)
                   (string-append "\"" (symbol->string f) "\", "))
                 fields))
      " 0 };\n"
     "  " tyname "*" " t = tl_m_env(sizeof(" tyname "))" ";\n"
     "  t->names = names;\n"
     (apply string-append 
            (map (lambda (f)
                   (string-append "  t->_" (mangle f) " = _" (mangle f) ";\n"))
                 fields))
     "  return t;\n"
     "}\n\n"
     )))

;; Code emission.
(define (emit line)
  (display line)
  (newline))
(define (c-compile-and-emit emit input-program)
  (define compiled-program "")
  (set! lambdas '())

  (set! input-program (tl_macro_expand input-program))
  ;; (display ";; after macro-expand:\n" tl_stderr)(write input-program tl_stderr)(display "\n\n" tl_stderr)

  (set! imports '())
  (set! import-anons '())
  (set! input-program (import input-program '()))
  (display ";; imports\n" tl_stderr)(for-each (lambda (x) (write x tl_stderr)(display "\n" tl_stderr)) imports)(display "\n" tl_stderr)
  (if (not (null? imports))
    (set! input-program `(letrec ,imports ,input-program)))

  (set! input-program (desugar input-program))

  (let ((exp #f))
    (set! literals '())
    (set! exp (convert-literals input-program))
    ;; (display ";; literals\n" tl_stderr)(write literals tl_stderr)(display "\n\n" tl_stderr)
    (set! input-program (desugar (bind-literals literals exp)))
    ;; (display ";; after bind-literals:\n" tl_stderr)(write input-program tl_stderr)(display "\n\n" tl_stderr)
    )

  (set! mutable-variables '())
  (analyze-mutable-variables input-program)

  (set! input-program (desugar (wrap-mutables input-program)))
  (display ";; after desugar:\n" tl_stderr)(write input-program tl_stderr)(display "\n\n" tl_stderr)

  (set! input-program (closure-convert input-program))

  (emit "#define _tl_main _tl_main")
  (emit "#include \"tl.c\"")
  
  (emit "")
  
  (for-each 
   (lambda (env)
     (emit (c-compile-env-struct env)))
   environments)

  (set! compiled-program  (c-compile-program input-program))

  ;; Emit lambdas:
  ; Print the prototypes:
  (for-each
   (lambda (l)
     (emit (string-append "static tl __lambda_" (number->string (car l))
             "(" (c-compile-formals (lambda->formals (cadr l))) ") ;")))
   lambdas)
  
  (emit "")
  
  ; Print the definitions:
  (for-each
   (lambda (l)
     (emit ((caddr l) (string-append "__lambda_" (number->string (car l))))))
   lambdas)
  
  (emit compiled-program))

;; Compile and emit:
; (define the-program (read))
; (c-compile-and-emit emit the-program)

; Suitable definitions for the cell functions:
(define %cell      tl_m_cell)
(define %set-cell! tl_set_cell)
(define %get-cell  tl_get_cell)

