(load "tl/test")
(load "tl/hashtable")

(test-suite :hashtable
  (let ((ht (hashtable-new 3 equal? equal?-hash)))
    (assert (equal? 0 (hashtable-length ht)))
    (assert (equal? 3 (hashtable-size ht)))

    (assert (equal? #f (hashtable-ref ht "a" #f)))
    (assert (eq? ht (hashtable-set! ht "a" 1)))
    (assert (equal? 1 (hashtable-ref ht "a" #f)))
    (assert (equal? 1 (hashtable-length ht)))
    (assert (equal? 3 (hashtable-size ht)))

    (assert (equal? #f (hashtable-ref ht "b" #f)))
    (assert (eq? ht (hashtable-set! ht "b" 2)))
    (assert (equal? 2 (hashtable-ref ht "b" #f)))
    (assert (equal? 2 (hashtable-length ht)))
    (assert (equal? 3 (hashtable-size ht)))

    (assert (equal? #f (hashtable-ref ht :c #f)))
    (assert (eq? ht (hashtable-set! ht :c 3)))
    (assert (equal? 3 (hashtable-ref ht :c #f)))
    (assert (equal? 3 (hashtable-length ht)))
    (assert (equal? 5 (hashtable-size ht)))

    (assert (equal? #f (hashtable-ref ht 4 #f)))
    (assert (eq? ht (hashtable-set! ht 4 :d)))
    (assert (equal? :d (hashtable-ref ht 4 #f)))
    (assert (equal? 4 (hashtable-length ht)))
    (assert (equal? 5 (hashtable-size ht)))

    ))
