(define *macro-expand-trace* #f)
(define <macro-environment> (send 'new_class <mtable> <vector>))
(let ((id 0))
  (send 'add_method (send '_mtable <macro-environment>) 'new 
    (lambda (mtable)
      (set! id (+ id 1))
      (let ((instance (vector '<struct> #f #f id #f (send 'new <map>))))
	(send '_mtable= instance mtable)
	instance))))
(send 'add_method <macro-environment> 'id
  (lambda (self)
    (vector-ref self 3)))
(send 'add_method <macro-environment> 'parent
  (lambda (self)
    (vector-ref self 4)))
(send 'add_method <macro-environment> 'parent=
  (lambda (self v)
    (vector-set! self 4 v) self))
(send 'add_method <macro-environment> 'bindings
  (lambda (self)
    (vector-ref self 5)))
(send 'add_method <macro-environment> 'bindings=
  (lambda (self v)
    (vector-set! self 5 v) self))
(send 'add_method <macro-environment> 'lisp_write 
  (lambda (self port)
    (send '_write port "#<macro-environment ")
    (send '_inspect (send 'id self) port)
    (send '_write port " >")))
(send 'add_method <macro-environment> 'set-transformer 
  (lambda (self symbol transformer)
    (send 'set (send 'bindings self) symbol transformer)
    ;; (display "\n\n  ### set-macro ")(write symbol)(write transformer)(display "\n\n")
    self
    ))
(send 'add_method <macro-environment> 'get-transformer
  (lambda (self car-expr)
    (let ((x (send 'get (send 'bindings self) car-expr)))
      (if (null? x) 
	(if (send 'parent self)
	  (send 'get-transformer (send 'parent self) car-expr)
	  x)
	x))))
(send 'add_method <macro-environment> 'define-transformer
  (lambda (self symbol transformer)
    (if (send 'parent self)
      (send 'define-transformer (send 'parent self) symbol transformer)
      (send 'set-transformer self symbol transformer))))
(send 'add_method <macro-environment> 'apply-transformer
  (lambda (self transformer e)
    ;; (display "  apply-macro ")(write transformer)(display " to ")(write e)(newline)
    (set! e (cdr e))
    ;; (set! &trace 1)
    (set! e (transformer . e))
    ;; (display "  apply-macro => ")(write e)(newline)
    ;; (set! &trace 0)
    e))
(send 'add_method <macro-environment> 'expand-expr
  (lambda (self e)
    (if *macro-expand-trace*
      (let ()
	(display "    expand-expr ")(write e)(newline)))
    (if (pair? e)
      (let ((head (car e)))
	(if (eq? 'quote head) 
	  e
	  (if (or (eq? 'set! head) (eq? 'lambda head))
	    (cons (car e) (cons (car (cdr e)) (send 'expand-args self (cdr (cdr e)))))
	    (if (eq? 'let head)
	      (cons (car e) (cons
			      (map (lambda (b) (cons (car b) (send 'expand-args self (cdr b))))
				(car (cdr e)))
			      (send 'expand-args self (cdr (cdr e)))))
	      (if (eq? '&macro-scope head) ;; (&macro-scope (quote env) . body)
		(let ((args (send 'expand-args self (cdr e))))
		  (cons '&macro-scope
		    (cons (car args) 
		      (send 'expand-args (car (cdr (car args))) (cdr args)))))
		(if (eq? '&macro-environment head) ;; (&macro-environment)
		  (cons 'quote (cons self '()))
		  (let ((transformer (send 'get-transformer self head)))
		    ;; (display "  macro for ")(display (car e))(display " = ")(write macro)(newline)
		    (if (null? transformer)
		      (send 'expand-args self e)
		      (send 'apply-transformer self transformer e)))))))))
      e)))
(send 'add_method <macro-environment> 'expand-args
  (lambda (self e)
    (if (pair? e) 
      (let ()
	;; (display "      expand-args ")(write (car e))(newline)
	(cons 
	  (send 'expand-expr self (car e)) 
	  (send 'expand-args self (cdr e))))
      e)))

(send 'add_method <macro-environment> 'expand
  (lambda (self e)
    (let ((e-last #f) (e-next e))
      (while (not (equal? e-next e-last))
	(set! e-last e-next)
	(set! e-next (send 'expand-expr self e-last))
	(if *macro-expand-trace*
	  (let ()
	    (display " e-last = ")(write e-last)(newline)	  
	    (display " e-next = ")(write e-next)(newline)	  
	    ))
	)
      (if *macro-expand-trace*
	(let ()
	  (display " result = ")(write e-next)(newline)))	  
      e-next)))

(define *top-level-macro-environment* (send 'new <macro-environment>))
(define (&macro-environment) *top-level-macro-environment*)
(define (%define-macro name transformer)
  (send 'define-transformer (&macro-environment) name transformer))

(%define-macro 'define-macro 
  (lambda (name . body)
    (if (pair? name)
      (list '%define-macro (list 'quote (car name)) (cons 'lambda (cons (cdr name) body)))
      (cons '%define-macro (cons (list 'quote name) body)))))


