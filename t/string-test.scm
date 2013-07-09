(define s1 "abc")
(define s2 "d")
(define s3 "abc")
(define s4 "def")

(write (string=? s1 s1))(newline)
(write (string=? s1 s3))(newline)
(write (string=? s1 s4))(newline)
(write (string<? s1 s2))(newline)

