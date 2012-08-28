(define make-operation
  (lambda ()
    ((lambda (sel-meth-map)
      (lambda (sel . args)
        (if (eq? sel '&add)
          (set! sel-meth-map (cons (cons sel (car args)) sel-meth-map)) 
          (cdr (assq sel sel-meth-map)))
      )) '())))
(define send (lambda sel obj . args)
  (apply (tl_ivar (tl_type obj) 2)