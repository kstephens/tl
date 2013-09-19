
(define-macro (jit:++pre var)   `(begin (set! ,var (+ ,var 1)) var))
(define-macro (jit:++post var)  (let ((tmp (%gensym))) `(let ((,tmp ,var)) (set! ,var (+ ,var 1)) ,tmp)))

(define jit:tl_type tl_jit_type_void_ptr)

(define (map-with-index f l)
  (let ((i 0))
    (map (lambda (x)
           (let ((j i))
             (set! i (+ i 1))
             (f x j))) l)))

(define (last l)
  (if (and (pair? l) (null? (cdr l)))
    (car l)
    (last (cdr l))))

; Syntax destructuring
(define (tagged-list? tag l)
  (and (pair? l)
       (eq? tag (car l))
       l))

(define (immediate-const? exp)
  (or (integer? exp)
      (boolean? exp)
      (character? exp)
      (void? exp)))

(define (quote? exp)        (tagged-list? 'quote exp))
(define (quote->value exp)  (cadr exp))

(define (begin? exp)        (tagged-list? 'begin exp))
(define (begin->exps exp)   (cdr exp))

(define (ref? exp) (symbol? exp))

(define (lambda? x)         (tagged-list? 'lambda x))
(define (lambda->formals x) (cadr x))
(define (lambda->body x)    (cddr x))

(define (jit-lambda exp env)
  (let* (
          (nparams 0)
          (formals-index  (map (lambda (n) (cons n (jit:++post nparams))) (lambda->formals exp)))
          (context        (tl_jit_context_create))
          (build-start    (tl_jit_context_build_start context))
          (params         (tl_jit_type_tPv nparams jit:tl_type))
          (signature      (tl_jit_type_create_signature tl_jit_abi_cdecl jit:tl_type params nparams 1))
          (function       (tl_jit_function_create context signature))
          (formals-param  (map (lambda (ni) (cons (car ni) (tl_jit_value_get_param function (cdr ni)))) formals-index))
          )
    (display "formals-index => ")(write formals-index)(newline)
    (display "formals-param => ")(write formals-param)(newline)
    (display "lambda->body => ")(write (lambda->body exp))(newline)

    (begin
      (define (jit-tailpos exp) (write `(return ,exp))(newline) (tl_jit_insn_return function exp) exp)
      (define (jit-other exp)   (write exp)(newline) exp)
      (define (jit-literal val)
        (display "jit-literal ")(write val)(newline)
        (tl_jit_value_create_nint_constant function jit:tl_type (tl_jit_nint_FORCE val)))
      (define (jit-param name)
        (cdr (assq name formals-param)))
      (define (jit-body exps emit)
        (display "jit-body ")(write exps)(write emit)(newline)
        (if (and (pair? exps) (null? (cdr exps)))
          (jit-expr (car exps) emit)
          (begin
            (jit-expr (car exps) jit-other)
            (jit-body (cdr exps) emit))))
      (define (jit-expr exp emit)
        (display "jit-expr ")(write exp)(write emit)(newline)
        (case
          ((immediate-const? exp)   (emit (jit-literal exp)))
          ((ref? exp)               (emit (jit-param exp)))
          ((quote? exp)             (emit (jit-literal (quote->value exp))))
          ((begin? exp)             (jit-body exp emit))
          (else                     (emit (jit-literal exp)))))

      (jit-body (lambda->body exp) jit-tailpos)
      (display "lambda body compile finished")(newline)

      (tl_jit_function_compile function)

      (let* (
              (fp (tl_jit_function_to_closure function))
              (prim (tl_m_prim (tl_voidP_ fp) (tl_S "(jit)")))
              )
        (tl_jit_context_destroy context)
        prim))))

