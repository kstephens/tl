(define <catch> (make-type "catch"))
(define (%make-catch) (tl_set_type (make-vector 16) <catch>))
(define (catch k unwind)
  (tl_catch (%make-catch) k unwind))
(define (throw c v)
  (tl_throw c v))

