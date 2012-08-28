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
        (display "catch = ")(write _c)(newline)
        (g 100))
      (lambda (_c v)
        (display "catch ")(write _c)(display " aborted with ")(write v)(newline)
        v)))

  (display "catch returned ")(write v)(newline)
  )

