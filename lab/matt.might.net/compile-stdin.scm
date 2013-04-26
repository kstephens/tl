(load "scheme-to-c.scm")

(define the-program (read))
(c-compile-and-emit emit the-program)

