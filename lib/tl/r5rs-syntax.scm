#|
(define-macro (begin . body)
  (if (null? body) ''() ; undef
    (if (null? (cdr body)) (car body)
      `(let () ,@body))))
|#

;; requires (%gensym BASENAME), %unspec
(define-macro (define n . b)
  (if (pair? n)
    `(define ,(car n) (lambda ,(cdr n) ,@b))
    `(define ,n ,@b)))

(define-macro (letrec bindings . body)
  `(let ,(map (lambda (b) `(,(car b) ',%unspec)) bindings)
     ,@(map (lambda (b) `(set! ,(car b) ,@(cdr b))) bindings)
     ,@body))

(define-macro (let bindings-or-loop-name . body)
  (if (symbol? bindings-or-loop-name)
    (let ((loop-name bindings-or-loop-name)
           (bindings (car body)))
    `(letrec ((,loop-name (lambda ,(map car bindings) ,@(cdr body))))
       (,loop-name ,@(map cadr bindings))))
    `(let ,bindings-or-loop-name ,@body)
    ))

(define-macro (do var-init-steps test-expressions . commands)
  (let ((loop (%gensym 'do-loop))
        (test (car test-expressions))
        (expressions (cdr test-expressions)))
    `(let ,loop ,(map (lambda (vis) (list (car vis) (cadr vis))) var-init-steps)
       (if ,test
         (begin ,@expressions)
         (begin
           ,@commands
           (,loop
             ,@(map (lambda (vis)
                      (let ((var  (car vis))
                             (step (cddr vis)))
                        (if (null? step) var (car step))))
                 var-init-steps)))
         ))))

(define-macro (cond . cases)
  (letrec ((%cond 
             (lambda (cases)
               (if (null? cases) `',%unspec
                 (let ((case (car cases)))
                   (if (eq? 'else (car case))
                     `(begin ,@(cdr case))
                     (if (eq? '=> (cadr case))
                       (let ((tmp (%gensym 'cond)))
                         `(let ((,tmp ,(car case)))
                            (if ,tmp (,(caddr case) ,tmp)
                              ,(%cond (cdr cases)))))
                       `(if ,(car case)
                          (begin ,@(cdr case))
                          ,(%cond (cdr cases))))))))))
    (%cond cases)))

(define-macro (let* bindings . body)
  (letrec ((%let* 
             (lambda (bindings body)
               (cond
                 ((null? bindings) `(begin ,@body))
                 ((pair? bindings)
                   `(let (,(car bindings)) ,(%let* (cdr bindings) body)))
                 (else (error "let*: invalid bindings" bindings))))))
    (%let* bindings body)))

(define-macro (or . cases)
  (letrec ((%or
             (lambda (tmp cases)
               (if (null? cases) #f
                 `(begin
                    (set! ,tmp ,(car cases))
                    (if ,tmp ,tmp ,(%or tmp (cdr cases))))))))
    (cond
      ((null? cases)       #f)
      ((null? (cdr cases)) (car cases))
      (else 
        (let ((tmp (%gensym 'or-)))
          `(let ((,tmp #f))
             ,(%or tmp cases)))))))

(define-macro (and . cases)
  (let ((%and #f))
    (set! %and
      (lambda (cases)
        (cond
          ((null? cases)       #t)
          ((null? (cdr cases)) (car cases))
          (else
            `(if ,(car cases) ,(%and (cdr cases)) #f)))))
    (%and cases)))

(define-macro (case val-expr . cases)
  (letrec ((val (%gensym 'case))
	   (%case 
	     (lambda (cases)
	       (if (null? cases) `',%unspec
		 (let ((c (car cases)))
		   (if (eq? (car c) 'else)
		     `(begin ,@(cdr c))
		     `(if (or ,@(map (lambda (e) `(eqv? ',e ,val)) (car c)))
			(begin ,@(cdr c))
			,(%case (cdr cases)))))))))
    `(let ((,val ,val-expr))
       ,(%case cases))))

(define (%body-defines b c)
  (if (null? b) c
    (let ((stmt (car b)))
      (if (and (pair? stmt) (eq? 'define (car stmt)))
        (let ((var (cadr stmt)) (val (caddr stmt)))
          (set-car! c (cons `(,var ',%unspec) (car c)))
          (set! stmt `(set! ,var ,val))))
      (set-cdr! c (cons stmt (cdr c)))
      (%body-defines (cdr b) c))))
(define-macro (&body . b) ;; must return a (begin ...) expr.
  (let* ((defines-and-stmts (%body-defines b (cons '() '())))
          (defines (car defines-and-stmts))
          (stmts (cdr defines-and-stmts)))
    (if (null? defines)
      (cons 'begin b)
      `(begin (let ,(reverse defines) ,@(reverse stmts))))))

;; MISC.
(define-macro (macro-bind bindings . body)
  (let ((anon-bindings (map (lambda (b) (cons (%gensym 'macro-bind) b)) bindings)))
   `(let ,(map (lambda (b) `(,(cadr b) ,(car b))) anon-bindings)
     (let ,(map (lambda (b) `(,(car b) ,(caddr b))) anon-bindings)
       ,@body))))

