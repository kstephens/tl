#|
(define-macro (begin . body)
  (if (null? body) ''() ; undef
    (if (null? (cdr body)) (car body)
      `(let () ,@body))))
|#

(define-macro (or . cases)
  (if (null? cases)
    #f
    (let ((tmp (make-symbol #f)))
      `(let ((,tmp ,(car cases)))
         (if ,tmp ,tmp (or ,@(cdr cases)))))))

(define-macro (and . cases)
  (if (null? cases)
    #t
    (if (cdr cases)
      (let ((tmp (make-symbol #f)))
        `(let ((,tmp ,(car cases)))
           (if (not ,tmp) ,tmp (and ,@(cdr cases)))))
      (car cases))))

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

(define-macro (let-and* bindings . body)
  (if (null? bindings)
    `(begin ,@body)
    `(let (,(car bindings))
       (if ,(caar bindings)
	 (let-and ,(cdr bindings) ,@body)
	 #f))))


