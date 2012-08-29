(define <map> (make-type "map"))
(define (map-new) (cons '() '()))
(define (map-lookup self key) (assq key (car self)))
(define (map-get self key)
  (let ((slot (map-lookup self key)))
    (if slot (cdr slot) '())))
(define (map-set self key value)
  (let ((slot (map-lookup self key)))
    (if slot
      (set-cdr! slot value)
      (set-car! self (cons (cons key value) (car self)))
      )))

'ok
