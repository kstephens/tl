;; http://matt.might.net/articles/cps-conversion/
(load "tl/match")

#|
The naive transformation

The naive transformation likely dates to Plotkin's earliest work.

It is the transformation that newcomers often discover for themselves.

In this transformation, we have two functions, M and T:

    M : expr => aexp converts an atomic value (a variable or a lambda term) into an atomic CPS value; and
    T : expr × aexp => cexp takes an expression and a syntactic continuation, and applies the continuation to a CPS-converted version of the expression. 

The expression (T expr cont) might be read "the transformation of expr into continuation-passing style, such that cont will be invoked on its result."

The M function only has to watch for lambda terms. When it sees a lambda term, it adds a fresh continuation parameter, $k, and then transforms the body of the lambda term into continuation passing style, asking it to invoke $k on the result. Variables are unchanged: 
|#

(define (M expr)
  (match expr
    [`(λ (,var) ,expr)
      ; =>
      (define $k (gensym '$k))
     `(λ (,var ,$k) ,(T expr $k))]
    
    [(? symbol?)  #;=>  expr]))

#|
The transform (T expr cont) will transform expr into a CPS value, and then construct a call site that applies the term cont to that value:
|#

(define (T expr cont)
  (match expr
    [`(λ . ,_)     `(,cont ,(M expr))]
    [ (? symbol?)  `(,cont ,(M expr))]
    [`(,f ,e)      
      ; =>
      (define $f (gensym '$f))
      (define $e (gensym '$e))
      (T f `(λ (,$f)
              ,(T e `(λ (,$e)
                       (,$f ,$e ,cont)))))
      ]))

'ok
