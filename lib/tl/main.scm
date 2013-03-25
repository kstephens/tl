(define *command-line* (cons #f '()))
(define (command-line) *command-line*) ;; r6rs
(define *program-directory* #f)
(define *command-line-load-files* '())
(define *command-line-prog-files* '())
(define (tl_main argc argv)
  (define (fill-args tail i)
    (if (< i argc)
      (begin
        (set-cdr! tail (cons (tl_s+ (tl_get argv i)) '()))
        (fill-args (cdr tail) (+ i 1)))))
  (define (process-args args)
    (if (null? args)
      (begin
        (set! *command-line-load-files* (reverse *command-line-load-files*))
        (set! *command-line-prog-files* (reverse *command-line-prog-files*)))
      (case (car args)
        (("-l")
          (set! *command-line-load-files* (cons (cddr args) *command-line-load-files*))
          (process-args (cddr args)))
        (else
          (set! *command-line-prog-files* (cons (car args) *command-line-prog-files*))
          (process-args (cdr args))))
      ))
  (set! argc (tl_i argc))
  (fill-args *command-line* 0)

  (set! *command-line* (cdr *command-line*))
  (set! *program-directory* (path-directory (car *command-line*)))

  (process-args (cdr *command-line*))
  (if (null? *command-line-prog-files*) (set! *command-line-prog-files* '("-p")))

  (map (lambda (file)
              (display "TL: loading ")(display file)(newline)
              (load file)) *command-line-load-files*)
  (map
    (lambda (file)
      (if (string-equal? file "-p")
        (begin
          (display "TL: Ready!")(newline)
          (let ((in tl_stdin) (output tl_stdout) (prompt '()))
            (repl %env in output prompt)))
        (begin
          (display "TL: running")(display file)(newline)
          (load file))))
    *command-line-prog-files*)
)
