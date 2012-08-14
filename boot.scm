(define *env* &env)
(define &eos eos)
(define eos? (lambda (x) (eq? x &eos)))
(define eq? tl_eqQ)
(define eqv? tl_eqvQ)
(define car tl_car)
(define cdr tl_cdr)
(define cons tl_cons)
(define eval tl_eval)
(define repl tl_repl)
(define + tl_fixnum_ADD)
(define - tl_fixnum_SUB)
(define * tl_fixnum_MUL)
(define / tl_fixnum_DIV)

(define make-type 
  (lambda (n)
    (tl_m_type (->char* n))))

(define ->char* (lambda (s) (tl_ivar s 0)))

(define <port> (make-type "port"))
(define <-FILE*
  (lambda (f)
    (tl_typeSET (cons f #f) <port>)))
(define ->FILE* tl_car)
(define open-file 
  (lambda (f m)
    (<-FILE* (fopen (->char* f) (->char* m)))))
(define close-file
  (lambda (f)
    (fclose (->FILE* f))))
(define *stdin*  (<-FILE* _stdin))(set! _stdin #f)
(define *stdout* (<-FILE* _stdout))(set! _stdout #f)
(define *stderr* (<-FILE* _stderr))(set! _stderr #f)

(define null? (lambda (x) (eq? x '())))
(define display (lambda (obj . port)
  (tl__write obj (->FILE* (if (null? port) *stdout* (car port))) (tl_I 0))))
(define write (lambda (obj . port)
  (tl__write obj (->FILE* (if (null? port) *stdout* (car port))) (tl_I 1))))
(define newline (lambda port)
  (fputc (tl_I 10) (->FILE* (if (null? port) *stdout* (car port))))
  #t)
(define read (lambda port
  (tl_read (->FILE* (if (null? port) *stdin* (car port))))))

