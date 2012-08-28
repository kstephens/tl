(define (match-if pat val k)
  `(if ,(match-1 pat val k) ,k))

(define (match-atom pat val k)
  `(equal? ,pat ,val))
(define match-1 match-atom)

(write (match-if 'x 'x '(write 'matched!)))(newline)

(define (match-var var val k)
  `(let ((,var ,val))
     ,k))

(define (match-unquote pat val k)
  (if (and (pair? pat) (eq? 'unquote (car pat)))
    (match-var (cadr pat) val k)
    (match-atom pat val k)
    ))
(define match-1 match-unquote)

(write (match-if 'x ''x '(write 'matched!)))(newline)
(write (match-if ',x ''x '(write (list 'matched! x))))(newline)

(define (match-sequence pat val k)
  (if (pair? pat)
    `((and (pair? ,val)
          ,(match-1 (car pat) `(car ,val)
             ,(match-sequence (cdr pat) `(cdr ,val) k))))
    (match-unquote pat val k)))
(define match-1 match-sequence)

(write (match-if '(a b) 'x '(write 'matched!)))(newline)

