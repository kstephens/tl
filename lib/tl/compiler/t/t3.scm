(letrec (
          (foo (lambda (a b) 
                 (display (* bar (+ a b)))))
          (bar 1)
          (baz! 2)
          )
  (begin
    (foo 1 2)
    (set! bar 2)
    (foo 3 4))
)
