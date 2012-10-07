(define (weaken-car! p)
  (set-car! p (make-weak (car p)))
  p)
(define (weaken-cdr! p)
  (set-cdr! p (make-weak (cdr p)))
  p)

(define p
  (let ((s "string"))
    (weaken-car! (cons s 1))))

'ok
