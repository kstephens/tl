;; http://matt.might.net/articles/cps-conversion/
(load "tl/match")

(define (T expr cont)
  (match expr
    [`(λ . ,_)     `(:a-lambda ,_)]
    [ (? symbol?)  '(:a-symbol)]
    [`(,f ,e)      `(:a-comb f e)
      ]))

'ok
