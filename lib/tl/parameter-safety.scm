;; (set! *quasiquote-debug* #t)
(define-macro (check-args f-constraints)
  ;; (display "  check-args ")(write f-constraints)(newline)
  (let ((result 
          (%check-args (car f-constraints) (cdr f-constraints))))
    ;; (display "  => ")(write result)(newline)
    result))

(define (%check-args f constraints)
  (let ((g     (gensym))
         (args (gensym)))
    ;; (set! *quasiquote-debug* #t)
    `(let ((,g ,f))
       (set! ,f
         (lambda ,args
           ,(%check-args-list f constraints args 0)
           (apply ,g ,args))))
    ))
(define (%check-args-list f constraints args param)
  (if (null? constraints) #t
    (let ((arg '_))
      `(let ((,arg ',%unspec))
         ,(%check-args-list-1 f constraints args arg param)))))
(define (%check-args-list-1 f constraints args arg param)
  (if (null? constraints) #t
    (let ((constraint (car constraints)))
      `(begin 
         (set! ,arg (car ,args))
         (if ,(%check-arg-expr constraint arg)
           ,(%check-args-list-1 f (cdr constraints) (list 'cdr args) arg (+ param 1))
           (error "argument error: " '(:in ,f :parameter ,param :constraint ,constraint)))))))
(define (%check-arg-expr constraint arg)
  (cond
    ((null? constraint)        #t)
    ((symbol? constraint)     `(,constraint ,arg))
    ((procedure? constraint)  `(',constraint ,arg))
    ((pair? constraint)
      `(,(car constraint) 
         ,@(map (lambda (c) (%check-arg-expr c arg)) (cdr constraint))))
    (else (error "%check-arg-expr: invalid constraint expression: " constraint))))

(begin
  (define (t f . args)
    (write f)(write args)(newline)(display " => ")(newline)
    (let ((result (apply f args)))
      (display "  ")(write result)(newline)
      result))
  
  ;;(t %check-args-list '+ '(number? number?) 'args)
  ;;(t %check-args 'car '(pair?) 'args)
  ;;(t %check-args 'car '(pair?))
  )

;; (check-args (car pair?)) ;; infinite regress?
;; (check-args (cdr pair?)) ;; infinite regress?
(define (non-negative-fixnum? x)
  (and (fixnum? x) (not (negative? x))))

(check-args (symbol->string symbol?))

(check-args (string-length string?))
(check-args (string-ref string? non-negative-fixnum?))
(check-args (string-set! string? non-negative-fixnum?))
(check-args (string-equal? string? string?))
(check-args (make-string non-negative-fixnum?))
(check-args (string-copy string?))
(check-args (substring string? non-negative-fixnum? non-negative-fixnum?))

(check-args (list-length list?))
(set! length list-length)
(check-args (reverse list?))
(check-args (append list?))

(check-args (make-vector non-negative-fixnum?))
(check-args (vector-ref vector? non-negative-fixnum?))
(check-args (vector-set! vector? non-negative-fixnum?))
(check-args (vector-equal? vector? vector?))
(check-args (list->vector list?))

(check-args (getenv (or string? symbol?)))

(check-args (open-file string? string?))
(check-args (close-port port?))
(check-args (load string?))

;; (set! *quasiquote-debug* #f)
