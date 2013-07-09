(define (null? o)
  (tl_eqQ o '()))
(define (cadr o) (car (cdr o)))
(define (cddr o) (cdr (cdr o)))
(define (caddr o) (car (cdr (cdr o))))
(define (cdddr o) (cdr (cdr (cdr o))))

(define (show o . port)
  (set! port
    (if (null? port) (&c:var stdout) (car port)))
  ((&c:func tl_write) o port)
  ((&c:func tl_display) "\n" port)
  )
(define (list . l) l)
(show 1)
(show 2 (&c:var stdout))
(show (list 1 2 3 4))

(define (a f l)
  (cond
    ((null? l)          (f))
    ((null? (cdr l))    (f (car l)))
    ((null? (cddr l))   (f (car l) (cadr l)))
    ((null? (cdddr l))  (f (car l) (cadr l) (caddr l)))
    ))
(a show (list 3 (&c:var stdout)))


