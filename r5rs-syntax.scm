#|
(define-macro (begin . body)
  (if (null? body) ''() ; undef
    (if (null? (cdr body)) (car body)
      `(let () ,@body))))
|#

(define-macro (define n . b)
  (if (pair? n)
    `(define ,(car n) (lambda ,(cdr n) ,@b))
    `(define ,n ,@b)))

(define-macro (or . cases)
  (if (null? cases) #f
    (if (null? (cdr cases)) (car cases)
      (let ((tmp (make-symbol #f)))
        `(let ((,tmp #f))
           (&or-tmp ,tmp ,@cases))))))
(define-macro (&or-tmp tmp . cases)
  (if (null? cases)
    #f
    `(begin
       (set! ,tmp ,(car cases))
       (if ,tmp ,tmp (&or-tmp ,tmp ,@(cdr cases))))))

(define-macro (and . cases)
  (if (null? cases) #t
    (if (null? (cdr cases)) (car cases)
      (let ((tmp (make-symbol #f)))
        `(let ((,tmp ,(car cases)))
           (if (not ,tmp) ,tmp (and ,@(cdr cases))))))))
#|
        `(let ((,tmp #f))
           (&and-tmp ,tmp ,@cases))))))
|#
(define-macro (&and-tmp tmp . cases)
  (if (null? cases)
    #f
    `(begin
       (set! ,tmp ,(car cases))
       (if (not ,tmp) ,tmp (&and-tmp ,tmp ,@(cdr cases))))))

(define-macro (cond case . cases)
  (if (null? cases)
    `(begin ,@(cdr case))
    `(if ,(car case) 
       (begin ,@(cdr case))
       (cond ,@cases))))

(define-macro (let* bindings . body)
  (cond
    ((null? bindings) `(begin ,@body))
    ((pair? bindings)
      `(let (,(car bindings)) (let* (,@(cdr bindings)) ,@body)))))

(define-macro (macro-bind bindings . body)
  (let ((anon-bindings (map (lambda (b) (cons (make-symbol '()) b)) bindings)))
   `(let ,(map (lambda (b) `(,(cadr b) ,(car b))) anon-bindings)
     (let ,(map (lambda (b) `(,(car b) ,(caddr b))) anon-bindings)
       ,@body))))

(define-macro (letrec bindings . body)
  `(let ,(map (lambda (b) `(,(car b) #f)) bindings)
     ,@(map (lambda (b) `(set! ,(car b) ,@(cdr b))) bindings)
     ,@body))

(define (%body-defines b c)
  (if (null? b) c
    (let ((stmt (car b)))
      (if (and (pair? stmt) (eq? 'define (car stmt)))
        (set-car! c (cons (cdr stmt) (car c)))
        (set-cdr! c (cons stmt (cdr c))))
      (%body-defines (cdr b) c))))
(define-macro (&body . b) ;; must return a (begin ...) expr.
  (let* ((defines-and-stmts (%body-defines b (cons '() '())))
          (defines (car defines-and-stmts))
          (stmts (cdr defines-and-stmts)))
    (if (null? defines)
      (cons 'begin b)
      `(begin (letrec ,defines ,@stmts)))))
        
(define-macro (case val-expr . cases)
  (letrec ((val (make-symbol #f))
	   (%case 
	     (lambda (cases)
	       (if (null? cases) ''() ;; undefined
		 (let ((c (car cases)))
		   (if (eq? (car c) 'else)
		     `(begin ,@(cdr c))
		     `(if (or ,@(map (lambda (e) `(eqv? ',e ,val)) (car c)))
			(begin ,@(cdr c))
			,(%case (cdr cases)))))))))
    `(let ((,val ,val-expr))
       ,(%case cases))))

