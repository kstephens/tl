(load "type.scm")
(load "map.scm")

(define (%get-option opts opt)
  (if (pair? opts)
      (if (eq? opt (car opts))
          (cadr opts)
          (%get-option (cddr opts) opt))
      #f))

(define (%make-operation type . opts)
  (letrec ((type-meth-map (make-map))
           (default-method (or (%get-option opts 'default-method)
                               (lambda args (error "method not found"))))
           (&add    (lambda (type meth)
                      (map-set type-meth-map type meth)))
           (&remove (lambda (type)
                      (map-delete type-meth-map type)))
           (&lookup (lambda (type)
                      (if (null? type) #f
                          (or (map-get type-meth-map type)
                              (&lookup (type-supertype type)))))))
    (lambda args
      (case (and (pair? args) (car args))
        ((&add)           (&add (cadr args) (caddr args)))
        ((&remove)        (&remove (cadr args)))
        ((&lookup)        (&lookup (cadr args)))
        ((&default-method) default-method)
        ((&set-default-method!)(set! default-method (cadr args)))
        ((&type-meth-map) type-meth-map)
        (else
         (apply 
          (or
           (&lookup (if (null? args)
                        <object>
                        (object-type (car args))))
           default-method)
          args))))
     ))
(define <operation> (make-type 'operation))
(define (make-operation . args)
  (apply %make-operation <operation> args))
(define (operation-set-default-method! operation method)
  (operation '&set-default-method! method))
(define (add-method op type meth)
  (op '&add type meth)
  op)
(define (operation-lookup op type)
  (op '&lookup type))

(define (make-type-tester type)
  (let ((op (make-operation 'default-method
                            (lambda (obj) #f))))
    (add-method op type (lambda (obj) #t))))

(define (make-type-coercer-operation type)
  (let ((op (make-operation 'default-method
                            (lambda (obj) (error "cannot coerce to" type)))))
    (add-method op type (lambda (obj) obj))))

(define -object? (make-type-tester <object>))
(define -list? (make-type-tester <list>))
(define -pair? (make-type-tester <pair>))
(define -null? (make-type-tester <null>))

(let ((foo (make-operation)))
  (define (t op . args)
    (display "t : ")
    (write op)(display "")(write args)(newline)
    (let ((result (apply op args)))
      (display "  => ")(write result)(newline)
      result))

  (add-method foo <fixnum> (lambda (self) (+ self 1)))
  (add-method foo <pair> (lambda (self) (car self)))
  (t foo '&type-meth-map)

  (t foo 5)
  (t foo (list 'a 'b 'c))
  (t operation-lookup -object? <pair>)
  (t -object? 5)
  (t -pair? 5)
  (t -pair? '(a b))
  (t -null? '(a b))
  )


(define -object? (make-type-test-operation <object>))
(define -list? (make-type-test-operation <list>))
(define -pair? (make-type-test-operation <pair>))
(define -null? (make-type-test-operation <null>))
