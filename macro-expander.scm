(load "map.scm")

;; Hack
(define or (lambda x (%or x)))
(define %or 
  (lambda (l)
    (if (null? l) #f
      (if (car l) (car l)
        (%or (cdr l))))))

(define *macro-define-trace* #f)
(define *macro-expand-trace* #f)
(define <macro-environment> (make-type "macro-environment"))
(let ((id 0))
  (define macro-environment-new
    (lambda ()
      (set! id (+ id 1))
      ;; (tl_set_type 
        (vector '<struct> #f #f id #f (map-new))
      ;; <vector>) ;; fixme
      )))
(define macro-environment-id
  (lambda (self)
    (vector-ref self 3)))
(define macro-environment-parent
  (lambda (self)
    (vector-ref self 4)))
(define macro-environment-parent=
  (lambda (self v)
    (vector-set! self 4 v) self))
(define macro-environment-bindings
  (lambda (self)
    (vector-ref self 5)))
(define macro-environment-bindings=
  (lambda (self v)
    (vector-set! self 5 v) self))
(define macro-environment-write 
  (lambda (self port op)
    (display "#<macro-environment " port)
    (write (macro-environment-id self) port)
    (display" >" port)))
; (%object-writer <macro-environment> macro-environment-write)
(define macro-environment-set-transformer
  (lambda (self symbol transformer)
    (map-set (macro-environment-bindings self) symbol transformer)
    ;; (display "\n\n  ### set-macro ")(write symbol)(write transformer)(display "\n\n")
    self
    ))
(define macro-environment-get-transformer
  (lambda (self car-expr)
    (let ((x (map-get (macro-environment-bindings self) car-expr)))
      (if (null? x)
	(if (macro-environment-parent self)
	  (macro-environment-get-transformer (macro-environment-parent self) car-expr)
	  x)
	x))))
(define macro-environment-define-transformer
  (lambda (self symbol transformer)
    (if (macro-environment-parent self)
      (macro-environment-define-transformer (macro-environment-parent self) symbol transformer)
      (macro-environment-set-transformer self symbol transformer))))
(define macro-environment-apply-transformer
  (lambda (self transformer e)
    ;; (display "  apply-macro ")(write transformer)(display " to ")(write e)(newline)
    (apply transformer (cdr e))))
(define macro-environment-expand-expr
  (lambda (self e)
    (if *macro-expand-trace*
      (let ()
	(display "    expand-expr ")(write e)(newline)))
    (if (pair? e)
      (let ((head (car e)))
	(if (eq? 'quote head) 
	  e
	  (if (or (eq? 'set! head) (eq? 'lambda head))
	    (cons (car e) (cons (car (cdr e)) (macro-environment-expand-args self (cdr (cdr e)))))
	    (if (eq? 'let head)
	      (cons (car e) (cons
			      (map (lambda (b) (cons (car b) (macro-environment-expand-args self (cdr b))))
				(car (cdr e)))
			      (macro-environment-expand-args self (cdr (cdr e)))))
	      (if (eq? '&macro-scope head) ;; (&macro-scope (quote env) . body)
		(let ((args (macro-environment-expand-args self (cdr e))))
		  (cons '&macro-scope
		    (cons (car args) 
		      (macro-environment-expand-args (car (cdr (car args))) (cdr args)))))
		(if (eq? '&macro-environment head) ;; (&macro-environment)
		  (cons 'quote (cons self '()))
		  (let ((transformer (macro-environment-get-transformer self head)))
		    ;; (display "  macro for ")(display (car e))(display " = ")(write transformer)(newline)
		    (if (null? transformer)
		      (macro-environment-expand-args self e)
		      (macro-environment-apply-transformer self transformer e)))))))))
      e)))
(define macro-environment-expand-args
  (lambda (self e)
    (if (pair? e) 
      (let ()
	;; (display "      expand-args ")(write (car e))(newline)
	(cons 
	  (macro-environment-expand-expr self (car e)) 
	  (macro-environment-expand-args self (cdr e))))
      e)))

(define macro-environment-expand
  (lambda (self e)
    (let ((e-next (macro-environment-expand-expr self e)))
      (if (not (equal? e-next e))
        (let ()
          (if *macro-expand-trace*
            (let ()
              (display " e      = ")(write e)(newline)	  
              (display " e-next = ")(write e-next)(newline)
              ))
          (macro-environment-expand self e-next))
        (let ()
          (if *macro-expand-trace*
            (let ()
              (display " result = ")(write e-next)(newline)))	  
          e-next)))))

(define *top-level-macro-environment* (macro-environment-new))
(define &macro-environment (lambda () *top-level-macro-environment*))
(define %define-macro (lambda (name transformer)
  (macro-environment-define-transformer (&macro-environment) name transformer)))

(%define-macro 'define-macro
  (lambda (name . body)
    (if *macro-define-trace*
      (begin
        (display "  ;; define-macro ")(write name)(newline)))
    (if (pair? name)
      (list '%define-macro (list 'quote (car name)) (cons 'lambda (cons (cdr name) body)))
      (cons '%define-macro (cons (list 'quote name) body)))))

'ok
