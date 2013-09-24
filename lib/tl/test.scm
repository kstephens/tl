(define-macro (test-suite desc . body)
  `(let ((asserts '()))
     (display "test-suite: ")(write ',desc)(newline)
     ,@body
     (set! asserts (reverse asserts))
     (let ((pass 0) (fail 0))
       (for-each (lambda (a) (a)) asserts)
       )))

(define-macro (assert-expr expr)
  (let ((value (%gensym 'value)))
    `(let ((,value ,expr))
       (display "  assert: ")(write ',expr)(newline)
       (if ,value ,value
         (error "assert" :expression ',expr)))))

(define-macro (assert expr)
  `(set! asserts (cons (lambda () (assert-expr ,expr)) asserts)))
