(load "scheme-to-c.scm")

(define the-program (read))
;; (tl_eval_debug #t)
(c-compile-and-emit emit the-program)

