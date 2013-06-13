(load "tl-to-c.scm")
(load "read-list.scm")

(let ((the-program (cons 'begin (read-list tl_stdin))))
  ;; (tl_eval_debug #t)
  (c-compile-and-emit emit the-program))


