(define (%string-each p s i)
  (if (< i (string-length s))
    (begin
      (p (string-ref s i))
      (%string-each p s (+ i 1)))))
(define (string-each p s) (%string-each p s 0))

(define (%vector-each p v i)
  (if (< i (vector-length v))
    (begin
      (p (vector-ref v i))
      (%vector-each p v (+ i 1)))))
(define (vector-each p v) (%vector-each p v 0))

