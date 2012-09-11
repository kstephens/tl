(define (match-expr val cases)
  (define (match-cases val cases f)
    (let ((val-name (gensym 'match-val)))
      `(let ((,val-name ,val))
         ,(match-cases-list val-name cases f))))
  (define (match-cases-list val cases f)
    (if (null? cases) f
      (match-case val (car cases)
        (match-cases-list val (cdr cases) f))))
  (define (match-case val case f)
    (if (not (pair? case)) (error "case not a pair." case))
    (match-datum (car case) val (list 'begin (cdr case)) f))
  (define (match-datum pat val t f)
    (if (quasiquote? pat)
      (match-sequence (cadr pat) val t f)
      (match-item pat val t f)))
  (define (match-sequence pat val t f)
    (if (null? pat) (match-item pat val t f)
      (if (and (pair? pat) (unquote-splicing? (car pat)))
        (match-var (cadr (car pat)) val t f)
        (let ( (car-val (gensym 'car-))
               (cdr-val (gensym 'cdr-)))
          `(if
             (pair? ,val)
             (let ( (,car-val (car ,val))
                    (,cdr-val (cdr ,val))
                    )
               ,(match-item (car pat) car-val
                  (match-sequence (cdr pat) cdr-val t f) f)) 
             #f)))))
  (define (match-item pat val t f)
    (cond
      ((unquote? pat) (match-var      (cadr pat)   val t f))
      ((predicate? pat) (match-if (list (cadr pat) val) t f))
      ((pair? pat)    (match-sequence pat          val t f))
      (else           (match-atom     (quote! pat) val t f))))
  (define (match-var var val t f)
    `(let ((,var ,val)) ,t))
  (define (match-atom pat val t f)
    (match-if (list 'equal? pat val) t f))
  (define (match-if test t f)
    (if (and (eq? t #t) (eq? f #f))
      test
      (list 'if test t f)))
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
      (eq? 'quasiquote (car pat))))
  (match-cases val cases #f)
)
(define-macro (match val . cases)
  (match-expr val cases))

'ok
