
(define (repl env in out prompt)
  (define (read-eval-print)
    (%with-error-handler 
      (lambda ()
        (let ((expr #f) (result #f))
          (if prompt (display "> " prompt))
          (set! expr (read in))
          (if (eq? expr %eos)
            (cons #f result)
            (begin
              (set! result (eval expr env))
              (if out
                (begin (write result out)(newline out)))
              (cons #t result)))))))
  (define (read-eval-print-loop last-result)
    (let ((result (read-eval-print)))
      (if (car result)
        (read-eval-print-loop (cdr result))
        last-result)))
  (if (null? in)        (set! in tl_stdin))
  (if (null? out)       (set! out tl_stdout))
  (if (null? prompt)    (set! prompt tl_stdout))
  (if (tl_b (isatty 0)) (set! prompt tl_stdout))
  (read-eval-print-loop #f))

