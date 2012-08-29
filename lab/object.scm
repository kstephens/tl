(define (make-operation)
  (let ((type-meth-map (make-map)))
    (define (&add type meth)
      (map-set type-meth-map type meth))
    (define (&remove type)
      (map-delete type-meth-map type))
    (define (&lookup type)
      (map-get type-meth-map type))
    (lambda args
      (case (and (pair? args) (car args))
        ((&add)          (&add (cadr args) (caddr args)))
        ((&remove)       (&remove (cadr args)))
        ((&type-meth-map) type-meth-map)
        (else
          (apply 
            (&lookup (if (null? args)
                       <object>
                       (tl_type (car args))))
            args))))))
(define (add-method op type meth)
  (op '&add type meth))

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
  )
