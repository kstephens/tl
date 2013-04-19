(define (%match-syntax val cases)
  (define (match-cases val cases)
    (let ((val-name (%gensym 'match-val))
           (result-name (%gensym 'match-result)))
      `(let ((,val-name ,val))
         ;; result-name holds a cons containing a match result or #f.
         (let ((,result-name (or ,@(match-cases-list val-name cases))))
           (and ,result-name (cdr ,result-name))
         ))))
  (define (match-cases-list val cases)
    (if (null? cases) '()
      (cons 
        (match-case val (car cases))
        (match-cases-list val (cdr cases)))))
  (define (match-case val case)
    (if (not (pair? case)) (error "case not a pair." case)
      (if (eq? 'else (car case))
        `(cons 'else (begin ,@(cdr case)))
        (match-expr (car case) val
          ;; match result is (cons 'match RESULT).
          `(cons 'match (begin ,@(cdr case)))))))
  (define (match-expr pat val t)
    (cond
      ((quasiquote? pat)  (match-quasiquote      pat  val  t))
      ((predicate? pat)   (match-and (list (cadr pat) val) t))
      ((logical? pat)
        ;; The t expression must be duplicated in each arm of
        ;; the logical operator,
        ;; because each arm may introduce bindings are around t.
        ;; This could be optimized for 'and and 'or forms.
        `(,(car pat)
           ,@(map (lambda (x) (match-expr x val t)) (cdr pat))))
      (else               (match-equal? pat val t))))
  (define (match-quasiquote pat val t)
    (cond
      ((null? pat)        (match-eq?       (quote! pat) val  t))
      ;; ((quasiquote? pat)  (match-quasiquote  (cadr pat) val  t))
      ((unquote? pat)     (match-var         (cadr pat) val  t))
      ((pair? pat)
        (if (unquote-splicing? (car pat))
          (match-var (cadr (car pat)) val t)
          (let ( (car-val (%gensym 'car-))
                 (cdr-val (%gensym 'cdr-)))
            `(and
               (pair? ,val)
               (let ( (,car-val (car ,val))
                      (,cdr-val (cdr ,val))
                      )
                 ,(match-quasiquote (car pat) car-val
                    (match-quasiquote (cdr pat) cdr-val t))))
            )))
      (else               (match-equal? (quote! pat) val t))
      ))
  (define (match-var var val t)
    `(let ((,var ,val)) ,t))
  (define (match-equal? pat val t)
    (match-and (list 'equal? pat val) t))
  (define (match-eq? pat val t f)
    (match-and (list 'eq? pat val) t))
  (define (match-or a b)
    (if (eq? b #f) a
      (if (eq? a #f) b
        `(or ,a ,b))))
  (define (match-and a b)
    (if (eq? a #f) #f
      (if (eq? b #f) a
        (list 'and a b))))
  (define (quote! x)
    (list 'quote x))
  (define (unquote? pat)
    (and 
      (pair? pat)
      (eq? 'unquote (car pat))
      (pair? (cdr pat))
      (symbol? (cadr pat))))
  (define (predicate? pat)
    (and
      (pair? pat)
      (eq? '? (car pat))
      (pair? (cdr pat))))
  (define (unquote-splicing? pat)
    (and
      (pair? pat)
      (eq? 'unquote-splicing (car pat))
      (pair? (cdr pat))
      (symbol? (cadr pat))))
  (define (quasiquote? pat)
    (and 
      (pair? pat)
      (eq? 'quasiquote (car pat))
      (pair? (cdr pat))))
  (define (logical? pat)
    (and
      (pair? pat)
      (or (eq? 'or (car pat)) (eq? 'and (car pat)))))
  (let ((result
          (match-cases val cases)))
    (display "  input => ")(write (list 'match val cases))(newline)
    (display "  result => ")(write result)(newline)
    result
    )
  )
(define-macro (match val . cases)
  (%match-syntax val cases))
(define-macro (match-syntax val . cases)
  `(%match-syntax ',val ',cases))

'ok
