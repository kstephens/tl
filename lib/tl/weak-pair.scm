(define (%weaken-ptr ptr)
  (tl_i (GC_register_disappearing_link ptr)))
(define (pair-weaken-car! p)
  (%weaken-ptr p))
(define (pair-weaken-cdr! p)
  (%weaken-ptr (%+ p %word-size)))

(define s "string")
(define p (cons s 1))
(pair-weaken-car! p)

'ok
