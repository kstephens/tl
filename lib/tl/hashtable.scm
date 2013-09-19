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
            (hashtable-set-size! ht (/ (* (hashtable-size ht) 2) 3))
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
    (hashtable-vector-each old-vector
      (lambda (kv)
        (hashtable-set! ht (car kv) (cdr kv)))))
  ht)
(define (hashtable-each ht proc)
  (hashtable-vector-each (hashtable-vector ht) proc))
(define (hashtable-vector-each v proc)
  (vector-each 
    (lambda (slot) (for-each proc slot))
    v))
(define (hashtable-map ht proc)
  (apply append
    (map (lambda (slot) (map proc slot)) 
      (vector->list (hashtable-vector ht)))))
(define (hashtable-keys ht)   (hashtable-map ht car))
(define (hashtable-values ht) (hashtable-map ht cdr))

(define eq?-hash tl_eqQ_hash)
(define eqv?-hash tl_eqvQ_hash)

(define (equal?-hash x)
  (cond
    ((string? x)
      (let ((h 0))
        (string-each (lambda (e) (set! h (tl_hash_mix h e))) x)
        h))
    ((vector? x)
      (let ((h 0))
        (string-each (lambda (e) (set! h (tl_hash_mix h (equal?-hash e)))) x)
        h))
    ((pair? x)
      (tl_hash_mix (equal?-hash (car x)) (equal?-hash (cdr x))))
    (else (eq?-hash x))))

(define (%string-each p s i)
  (if (< i (string-length s))
    (begin
      (p (string-ref s i))
      (%string-each p s (+ i 1)))))
(define (string-each p s) (%string-each p s 0))

(define (%vector-each p v i)
  (if (< i (vector-length v))
    (begin
      (p (vector-ref v i))
      (%vector-each p v (+ i 1)))))
(define (vector-each p v) (%vector-each p v 0))
