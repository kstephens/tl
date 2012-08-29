(define o1 '(a . b))
(define o2 '(a . c))
(define o3 '(b . b))
(define o4 '(a . b))

(write (pair-equal? o1 o1))(newline)
(write (pair-equal? o1 o2))(newline)
(write (pair-equal? o1 o3))(newline)
(write (pair-equal? o1 o4))(newline)

(define o1 '(a b c))
(define o2 '(a b))
(define o3 '(b b c))
(define o4 '(a b c))

(write (pair-equal? o1 o1))(newline)
(write (pair-equal? o1 o2))(newline)
(write (pair-equal? o1 o3))(newline)
(write (pair-equal? o1 o4))(newline)
