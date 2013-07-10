(define (f x)
  (define (g y) (+ y 1))
  (define (h z) (* (g z) 3))
  (+ (h x) 5))
(f 3) ;; => 17

(let loop ((a 10) (b 0))
  (if (= a 0) (display "done\n")
    (begin
      (display (list a b))(newline)
      (loop (- a 1) (+ b 1))
      )))
