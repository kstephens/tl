(load "tl-to-c.scm")

(define (read-list port)
  (define (r a)
    (let ((x (read port)))
      (if (not (eof-object? x))
        (begin
          (set-cdr! a (cons x '()))
          (r (cdr a))))))
  (define l (list #f))
  (r l)
  (cdr l))

(let ((the-program (cons 'begin (read-list tl_stdin))))
  ;; (tl_eval_debug #t)
  (c-compile-and-emit emit the-program))


