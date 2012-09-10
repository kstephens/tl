(define *argc* #f)
(define *arg0* #f)
(define *args* #())
(define (tl_main argc argv)
  (set! argc (tl_i argc))
  (set! *argc* argc)
  (set! *arg0* (tl_s+ (tl_get argv 0)))
  (set! argc (- argc 1))
  (set! *args* (make-vector argc))
  (define (fill-args i)
    (if (< i argc)
      (begin
        (vector-set! *args* i (tl_s+ (tl_get argv (+ i 1))))
        (fill-args (+ i 1)))))
  (fill-args 0)
  (display "TL: Ready!")(newline)
  (let ((in tl_stdin) (output tl_stdout) (prompt '()))
    (repl %env in output prompt)))
