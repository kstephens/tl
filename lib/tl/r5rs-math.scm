;; (write (tl_macro_expand '
;; > r5rs?
(define (truncate-quotent n1 n2)   (tl_fixnum_DIV n1 n2))
(define (truncate-remainder n1 n2) (tl_fixnum_MOD n1 n2))

(let ((%+ +) (%* *) (%- -) (%/ /))
  (define (type-check-2 f fn)
    (lambda (x y)
      (if (and (number? x) (number? y))
        (f x y)
        (error "non-numeric arguments" fn x y))))
  (set! + (type-check-2 %+ '+))
  (set! * (type-check-2 %* '*))
  (set! - (type-check-2 %- '-))
  (set! / (type-check-2 %/ '/))
  )
;; %env))

(let ((%+ +) (%* *) (%- -) (%/ /) 
      (%= =) (%< <) (%> >) (%<= <=) (%>= >=))
  (define (%+n l)
    (cond
      ((null? l) 0)
      (else (%+ (car l) (%+n (cdr l))))))
  (define (%*n l)
    (cond
      ((null? l) 1)
      (else (%* (car l) (%*n (cdr l))))))
  (set! + 
    (lambda l
      (cond 
        ((null? l) 0)
        ((null? (cdr l)) (car l))
        ((null? (cddr l)) (%+ (car l) (cadr l)))
        (else (%+ (car l) (%+n (cdr l)))))))
  (set! *
    (lambda l
      (cond 
        ((null? l) 1)
        ((null? (cdr l)) (car l))
        ((null? (cddr l)) (%* (car l) (cadr l)))
        (else (%* (car l) (%*n (cdr l)))))))
  (set! - 
    (lambda (x . l)
      (if (null? l) (%- 0 x)
        (%- x (%+n l)))))
  (set! /
    (lambda (x . l)
      (if (null? l) (%/ 1 x)
        (%/ x (%*n l)))))
  )

