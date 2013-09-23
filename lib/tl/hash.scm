(load "tl/each")

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
        (vector-each (lambda (e) (set! h (tl_hash_mix h (equal?-hash e)))) x)
        h))
    ((pair? x)
      (tl_hash_mix (equal?-hash (car x)) (equal?-hash (cdr x))))
    (else (eq?-hash x))))

