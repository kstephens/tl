(load "tl/hash")

(define (hashtable-new size equal hash)
  (vector 'hashtable (make-vector size '()) equal hash 0))
(define (hashtable-vector ht) (vector-ref ht 1))
(define (hashtable-size ht)   (vector-length (hashtable-vector ht)))
(define (hashtable-equal ht)  (vector-ref ht 2))
(define (hashtable-hash ht)   (vector-ref ht 3))
(define (hashtable-length ht) (vector-ref ht 4))
(define (hashtable-ref ht key default)
  (let* ((h ((hashtable-hash ht) key))
         (i (truncate-remainder h (vector-length (hashtable-vector ht))))
         (slot (vector-ref (hashtable-vector ht) i))
         (entry (%asseq (hashtable-equal ht) key slot)))
    (if entry (cdr entry) default)))
(define (hashtable-set! ht key value)
  (let* ((h ((hashtable-hash ht) key)))
    (hashtable-set!-hash ht key value h))
  ht)
(define (hashtable-set!-hash ht key value h)
  (let* ((i (truncate-remainder h (vector-length (hashtable-vector ht))))
         (v (hashtable-vector ht))
         (slot (vector-ref v i))
         (entry (%asseq (hashtable-equal ht) key slot)))
    (if entry
      (set-cdr! entry value)
      (let ((new-length (+ (hashtable-length ht) 1)))
        (vector-set! ht 4 new-length)
        (if (>= new-length (hashtable-size ht))
          (begin
            (hashtable-set-size! ht (+ (/ (* (hashtable-size ht) 3) 2) 1))
            (hashtable-set!-hash ht key value h))
          (vector-set! v i (cons (cons key value) slot)))))))
(define (%asseq p x l)
  (if (null? l) #f
    (if (p x (car (car l))) (car l)
      (%asseq p x (cdr l)))))
(define (hashtable-set-size! ht size)
  (let ((old-vector (hashtable-vector ht)))
    (vector-set! ht 1 (make-vector size '()))
    (vector-set! ht 4 0)
    (hashtable-vector-each
      (lambda (kv)
        (hashtable-set! ht (car kv) (cdr kv))) old-vector))
  ht)
(define (hashtable-each proc ht)
  (hashtable-vector-each proc (hashtable-vector ht)))
(define (hashtable-vector-each proc v)
  (vector-each 
    (lambda (slot) (for-each proc slot))
    v))
(define (hashtable-map ht proc)
  (apply append
    (map (lambda (slot) (map proc slot)) 
      (vector->list (hashtable-vector ht)))))
(define (hashtable-keys ht)   (hashtable-map ht car))
(define (hashtable-values ht) (hashtable-map ht cdr))

