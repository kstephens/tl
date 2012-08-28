(define <catch> (make-type "catch"))
(define (%make-catch) (tl_set_type (make-vector 16) <catch>))
(define (catch k unwind)
  (tl_catch (%make-catch) k unwind))
(define (throw c v)
  (tl_throw c v))

(let ((c #f) (v 'unknown-value))
  (define (g n)
    (display "g ")(write n)(newline)
    (if (= n 50)
      (throw c 'stopping))
    (if (> n 0)
      (g (- n 1))))

  (display "before catch")(newline)

  (set! v
    (catch
      (lambda (_c)
        (set! c _c)
        (display "catch = ")(write c)(newline)
        (g 100))
      (lambda (v)
        (display "aborted with ")(write v)(newline))))

  (display "catch returned ")(write v)(newline)
  )

