(define (show x)
  ((&c:func tl_write) x (&c:var stdout))
  ((&c:func tl_display) "\n" (&c:var stdout))
  )
(define (f x)
  (cond
    ((eq? 'x x)          1)
    ((eq? 'y x)          2)
    ((eq? '5 x)          3)
    (else 'unknown)))

(show (f 'x))
(show (f 'y))
(show (f 5))
(show (f 123))

#|
;; after bind-literals:
((lambda (%lit$5 %lit$4 %lit$3 %lit$2 %lit$1)
   ((lambda (f)
      (begin
        (set! f
          (lambda (x)
            (if (eq? %lit$1 x) 1
              (if (eq? %lit$2 x) 2
                (if (eq? %lit$3 x) 3 %lit$4)))))
        (f x)
        (f y)))
     %lit$5))
  #<void @0x104176ff8>
  ((&c:func tl_m_symbol) ((&c:func tl_S) "unknown"))
  5
  ((&c:func tl_m_symbol) ((&c:func tl_S) "y"))
  ((&c:func tl_m_symbol) ((&c:func tl_S) "x")))
|#