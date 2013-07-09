(letrec ((bar 5)
         (foo (lambda (a b) 
                (display (* bar (+ a b)))))
          )
  (begin
    (foo 1 2)
    (foo 3 4))
)
