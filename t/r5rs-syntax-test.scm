(define (f x)
  (define (g y) (+ y 1))
  (define (h z) (* (g z) 3))
  (+ (h x) 5))
(f 3) ;; => 17

