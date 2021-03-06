(define *macro-define-trace* #f)
(define *macro-expand-trace* #f)
(define <macro-environment> (make-type "macro-environment"))
(let ((id 0))
  (define (macro-environment-new)
    (set! id (+ id 1))
    ;; (tl_set_type 
    (vector '<struct> #f #f id #f (map-new) (map-new))
    ;; <vector>) ;; fixme
    ))
(define (macro-environment-id self) (vector-ref self 3))
(define (macro-environment-parent self) (vector-ref self 4))
(define (macro-environment-parent= self v)
  (vector-set! self 4 v) self)
(define (macro-environment-bindings self) (vector-ref self 5))
(define (macro-environment-constants self) (vector-ref self 6))
(define (macro-environment-write self port op)
  (display "#<macro-environment " port)
  (write (macro-environment-id self) port)
  (display" >" port))
; (%object-writer <macro-environment> macro-environment-write)
(define (macro-environment-set-transformer self symbol transformer)
  (map-set (macro-environment-bindings self) symbol transformer)
  ;; (display "\n\n  ### set-macro ")(write symbol)(write transformer)(display "\n\n")
  self)
(define (macro-environment-get-transformer self car-expr)
  (let ((x (map-get (macro-environment-bindings self) car-expr)))
    (if (null? x)
      (if (macro-environment-parent self)
        (macro-environment-get-transformer (macro-environment-parent self) car-expr)
        x)
      x)))
(define (macro-environment-define-constant self symbol const)
  (let ((needs-quote?
          (if (pair? const) #t
            (if (null? const) #t
              (if (symbol? const) #t
                (vector? const))))))
    (if needs-quote? (set! const (list 'quote const)))
    (map-set (macro-environment-constants self) symbol (cons const #f)))
  ;; (display "\n\n  ### set-macro ")(write symbol)(write transformer)(display "\n\n")
  self)
(define (macro-environment-get-constant self expr)
  (let ((x (map-get (macro-environment-constants self) expr)))
    (if (null? x)
      (if (macro-environment-parent self)
        (macro-environment-get-constant (macro-environment-parent self) expr)
        x)
      x)))
(define (macro-environment-define-transformer self symbol transformer)
  (if (macro-environment-parent self)
    (macro-environment-define-transformer (macro-environment-parent self) symbol transformer)
    (macro-environment-set-transformer self symbol transformer)))
(define (macro-environment-apply-transformer self transformer e)
  (if *macro-expand-trace* (begin (display "  apply-macro ")(write transformer)(display " to ")(write e)(newline)))
  (apply transformer (cdr e)))
(define (macro-environment-skip-first-arg? self e)
  (let ((head (car e)))
    (if (eq? 'lambda head) #t
      (if (pair? (cdr e))
        (if (symbol? (car (cdr e)))
          (if (eq? 'set! head) #t
            (if (eq? 'define head) #t
              #f)
            #f)
          #f)
        #f)
      #f)
    ))
(define (macro-environment-expand-body self b)
  (if *macro-expand-trace*
    (begin (display "      expand-body ")(write b)(newline)))
  (cdr
    (macro-environment-expand-expr self
      (cons '&body 
        (macro-environment-expand-list self b)))
    )
  )
(define (macro-environment-expand-expr self e)
  (if *macro-expand-trace*
    (begin (display "    expand-expr ")(write e)(newline)))
  (if (pair? e)
    (let ((head (car e)))
      (if (eq? 'quote head)
        e
        (if (macro-environment-skip-first-arg? self e)
          (cons (car e) 
            (cons
              (car (cdr e))
              (macro-environment-expand-body self (cdr (cdr e)))))
          (if (eq? 'let head)
            (if (symbol? (car (cdr e)))
              (let ((transformer (macro-environment-get-transformer self head)))
                    (if (null? transformer)
                      (macro-environment-expand-list self e)
                      (macro-environment-apply-transformer self transformer e)))
            (cons (car e)
              (cons
                (map (lambda (b) (cons
                                   (car b)
                                   (macro-environment-expand-list self (cdr b))))
                  (car (cdr e)))
                (macro-environment-expand-body self (cdr (cdr e))))))
            (if (eq? '&macro-scope head) ;; (&macro-scope (quote env) . body)
              (let ((args (macro-environment-expand-list self (cdr e))))
                (cons '&macro-scope
                  (cons (car args)
                    (macro-environment-expand-list (car (cdr (car args))) (cdr args)))))
              (if (eq? '&macro-environment head) ;; (&macro-environment)
                (cons 'quote (cons self '()))
                (if (eq? 'begin head)
                  (let ((body (macro-environment-expand-body self (cdr e))))
                    (if (null? (cdr body)) (car body) (cons 'begin body)))
                  (let ((transformer (macro-environment-get-transformer self head)))
                    ;; (display "  macro for ")(display (car e))(display " = ")(write transformer)(newline)
                    (if (null? transformer)
                      (macro-environment-expand-list self e)
                      (macro-environment-apply-transformer self transformer e))))))))))
    (let ((const (macro-environment-get-constant self e)))
      (if (null? const)
        e 
        (car const)))
    ))
(define (macro-environment-expand-list self e)
  (if (null? e) e
    (cons
      (macro-environment-expand-expr self (car e))
      (macro-environment-expand-list self (cdr e)))))

(define (macro-environment-expand self e)
  (let ((e-next (macro-environment-expand-expr self e)))
    (if (equal? e-next e)
      (begin
        ;; (display " e      = ")(write e)(newline)
        ;; (display " e-next = ")(write e-next)(newline)
        (if *macro-expand-trace*
          (begin (display " result = ")(write e-next)(newline)))
        e-next)
      (begin
        (if *macro-expand-trace*
          (begin
            (display " e      = ")(write e)(newline)
            (display " e-next = ")(write e-next)(newline)
            ))
        (macro-environment-expand self e-next))
      )))
(define *macro-expand-verbose* #f)
(define (macro-environment-expand-top-level self e)
  (let ((e-prime (macro-environment-expand self e)))
    (if *macro-expand-verbose*
      (begin
        (display " expr   = ")(write e)(newline)
        (display " result = ")(write e-prime)(newline)))
    e-prime))
(define *top-level-macro-environment* (macro-environment-new))
(define (&macro-environment) *top-level-macro-environment*)
(define (%define-macro name transformer)
  (macro-environment-define-transformer (&macro-environment) name transformer)
  name)
(define (%define-constant name value)
  (macro-environment-define-constant (&macro-environment) name value)
  name)


(%define-macro 'define-macro
  (lambda (name . body)
    (if *macro-define-trace*
      (begin
        (display "  ;; define-macro ")(write name)(newline)))
    (if (pair? name)
      (list '%define-macro (list 'quote (car name)) (cons 'lambda (cons (cdr name) body)))
      (cons '%define-macro (cons (list 'quote name) body)))))

(%define-macro 'define-constant
  (lambda (name . body)
    (if *macro-define-trace*
      (begin
        (display "  ;; define-constant ")(write name)(newline)))
    (if (pair? name)
      (list '%define-constant (list 'quote (car name)) (cons 'lambda (cons (cdr name) body)))
      (cons '%define-constant (cons (list 'quote name) body)))))

'ok
