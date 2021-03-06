;; (set! *macro-expand-trace* #t)
(let*
  (
    (e (macro-environment-new))
    (dm (lambda (n f) (macro-environment-define-transformer e n f)))
    (dc (lambda (n v) (macro-environment-define-constant e n v)))
    (de (lambda (expr)
          (display "  expr ")(write expr)(newline)
          (set! *macro-expand-trace* #t)
          (let ((result (macro-environment-expand e expr)))
            (set! *macro-expand-trace* #t)
            (display "  expr ")(write expr)(newline)
            (display "    => ")(write result)(newline)
            )
          ))
    )
  (macro-environment-parent= e (&macro-environment))
  (display "  e => ")(write e)(newline)
  (dm 'foo (lambda args 23))
  (de '(if a b c))
  (de '(if (foo) b c))

  (de '(define x 5))
  (de '(define (x y) (+ y 1)))
  (de '(define (foo y) (+ y 2)))
  (de '(define (foo y) (+ (foo) 3)))
  (dc 'C 5)
  (display "  e => ")(write e)(newline)
  (de '(define (x y) (+ C y 1)))

  (dm 'set!
    (lambda (n . b)
      (if (pair? n)
        `((setter ,(car n)) ,@(cdr n) ,@b)
        `(set! ,n ,@b))))
  (display "  e => ")(write e)(newline)
  (de '(set! a 1))
  (de '(set! (car l) 2))
  
  (de '
(define (f x)
  (define (g x) (+ x 1))
  (define (h x) (* (g x) 2))
  (h x)
))

)
