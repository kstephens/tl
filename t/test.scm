
(quote a)
(car '(a b))
(cdr '(a b))
(cons 'a 'b)
((lambda (a b)
  (car a)
  (cdr b)
  (cons a b))
  '(1 2) '(3 4))
(if #t 'true 'false)
(if #f 'true 'false)
(if #t 'true)
(if #f 'true)

(define a (lambda (n) 
            (display "a")(display n)(newline)
            (if (> n 0) (b (- n 1)))))
(define b (lambda (n)
            (display "b")(display n)(newline)
            (if (> n 0) (a (- n 1)))))
(a 10)
