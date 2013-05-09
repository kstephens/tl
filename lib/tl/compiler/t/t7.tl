(define (null? o)
  (tl_eqQ o '()))
(define (cadr o) (car (cdr o)))
(define (cddr o) (cdr (cdr o)))
(define (caddr o) (car (cdr (cdr o))))
(define (cdddr o) (cdr (cdr (cdr o))))

(define (show o . port)
  (if (null? port)
    (set! port (&c:var stdout))
    (set! port (car port)))
  ((&c:func tl_write) o port)
  ((&c:func tl_display) "\n" port)
  )
(define (list . l) l)
(define (apply f l)
  (cond
    ((null? l)          (f))
    ((null? (cdr l))    (f (car l)))
    ((null? (cddr l))   (f (car l) (cadr l)))
    ((null? (cdddr l))  (f (car l) (cadr l) (caddr l)))
    ))

(show 1)
(show 2 (&c:var stderr))
(show (list 1 2 3 4))
(apply show (list 3 (&c:var stderr)))


