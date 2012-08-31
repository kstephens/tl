#|
;; Basic test.
((lambda (a b) (tl_cons a b)) 1 2) 
(let ((a 1) (b 2)) (tl_cons a b))  ;; test
(let ((a 1) (b 2))
  (let ((c (tl_cons a b)))
    c))
(tl_eval_trace_ 0)
|#

(define (%void . x) tl_v)
(define %unspec tl_v)
(define %env &env)
(define %word-size (tl_tlw_sizeof))
(define (environment-vars x) (car (car x)))
(define %eos eos)
(define (eos? x) (eq? x %eos))
(define eq? tl_eqQ)
(define eqv? tl_eqvQ)
(define car tl_car)
(define cdr tl_cdr)
(define set-car! tl_set_carE)
(define set-cdr! tl_set_cdrE)
(define cons tl_cons)
(define (list . l) l)
(define apply tl_apply)
(define eval tl_eval)
(define + tl_fixnum_ADD)
(define %+ tl_word_ADD)
(define - tl_fixnum_SUB)
(define * tl_fixnum_MUL)
(define / tl_fixnum_DIV)
(define % tl_fixnum_MOD)
(define = tl_word_EQ)
(define < tl_fixnum_LT)
(define > tl_fixnum_GT)
(define >= tl_fixnum_GE)
(define <= tl_fixnum_LE)
(define %NULL (tl_I 0))
(define (%malloc size) (GC_malloc (tl_I size)))
(define (%allocate type size)
  (set! size (* (/ (+ size (- %word-size 1)) %word-size) %word-size))
  (tl_allocate type (tl_I size)))
(define (%register-finalizer obj func)
  ;; (display "%register-finalizer ")(write obj)(display " ")(write func)(newline)
  ;; (GC_register_finalizer obj tl_apply_2 func %NULL %NULL)
  obj)

(define (error msg . args)
  (tl_error (tl_S msg) args))

(define <type> (tl_type (tl_type '())))
(define (type? x) (eq? (tl_type x) <type>))
(define (make-type n) (tl_m_type (->char* n)))

(define <boolean> (tl_type #t))
(define (boolean? x) (eq? (tl_type x) <boolean>))
(define (not x) (if x #f #t))

(define <primitive>    (tl_type tl_car))
(define (primitive? x) (eq? (tl_type x) <primitive>))
(define <closure>      (tl_type primitive?))
(define (closure? x)   (eq? (tl_type x) <closure>))
(define (procedure? x)
  (if (primitive? x) #t (closure? x)))

(define ->char* tl_car)
(define tl_S tl_car)

(define <port> (make-type "port"))
(define (port? x) (eq? (tl_type x) <port>))
(define (%make-port fp info)
  (tl_set_type (cons fp info) <port>))
(define port-info cdr)
(define (%object-writer type f)
  (set! tl_object_write
    (let ((old-f tl_object_write))
      (lambda (o p op)
        (if (eq? (tl_type o) type)
          (f o p op)
          (old-f o p op))))))
(%object-writer <port>
  (lambda (o p op)
    (fprintf p (tl_S "#<port @%p :FILE* @%p") o (tl_car o))
    (tl_write_2 (port-info o) p op)
    (fputs (tl_S ">") p)
    p))
(define (<-FILE* f) (%make-port f '()))
(define ->FILE* tl_car)
(define (open-file f m)
  (let ((fp (fopen (->char* f) (->char* m))))
    (if (eq? fp %NULL) #f
      (%register-finalizer
        (%make-port fp (list f m))
        close-port))))
(define (close-port p)
  ;; (display "close-port ")(write p)(newline)
  (if (not (eq? (->FILE* p) #f))
    (begin
      ;; (display "close-port: fclose ")(write p)(newline)
      (fclose (->FILE* p))))
  (set-car! p #f)
  p)
(set! tl_stdin  (%make-port tl_stdin 'tl_stdin))
(set! tl_stdout (%make-port tl_stdout 'tl_stdout))
(set! tl_stderr (%make-port tl_stderr 'tl_stderr))

(define (null? x) (eq? x '()))

(define (display obj . port)
  (%void (tl_write_2 obj (->FILE* (if (null? port) tl_stdout (car port))) (tl_I 0))))
(define (write obj . port)
  (%void (tl_write_2 obj (->FILE* (if (null? port) tl_stdout (car port))) (tl_I 1))))
(define (newline . port)
  (%void (fputc (tl_I 10) (->FILE* (if (null? port) tl_stdout (car port))))))
(define (read . port)
  (tl_read (->FILE* (if (null? port) tl_stdin (car port)))))
(define (io-flush . port)
  (%void (fflush (->FILE* (if (null? port) tl_stdout (car port))))))
;; (write (environment-vars %env))(newline)

(define <fixnum> (tl_type 0))
(define (fixnum? x) (eq? (tl_type x) <fixnum>))
(define integer? fixnum?)
(define rational? integer?)
(define real? integer?)
(define complex? rational?)
(define number? fixnum?)
(define (positive? x) (> x 0))
(define (negative? x) (< x 0))
(define (zero? x) (= x 0))
(define number->string tl_fixnum_TO_string)
(define (string->number s . radix)
  (tl_string_TO_number s (tl_I (if (null? radix) 10 (car radix)))))

(define <character> (tl_type #\a))
(define (character? x) (eq? (tl_type x) <character>))

(define <symbol> (tl_type 'symbol))
(define (symbol? x) (eq? (tl_type x) <symbol>))
(define (keyword? o) (if (symbol? o) (tl_ivar o 2) #f))
(define (make-symbol name) ;; not interned.
  (tl_make_symbol (if name (tl_S name) %NULL)))
(define (gensym . args) (make-symbol #f))
(define *gensym-counter* 0)
(define gensym
  (let ((counter 0))
    (lambda args
      (let ((name (if (null? args) #f (car args))))
        (if (not name) (set! name "g"))
        (if (symbol? name) (set! name (symbol->string name)))
        (set! counter (+ counter 1))
        (set! name (string-append name (number->string counter)))
        (make-symbol name)))))
(define (string->symbol str) (tl_m_symbol (tl_S str))) ;; interned.
(define (symbol->string s) (tl_car s))

(define <string> (tl_type "string"))
(define (string? x) (eq? (tl_type x) <string>))
(define (%string-ptr s) (tl_tlw_get s))
(define (%make-string ptr size)
  (let ((o (%allocate <string> (* 2 %word-size))))
    (tl_set_ivar o 0 ptr)
    (tl_set_ivar o 1 (tl_I size))
    o))
(define tl_S %string-ptr)
(define (tl_s ptr) (%make-string ptr (strlen ptr)))
(define (tl_s+ ptr) (%make-string (GC_strdup ptr) (strlen ptr)))
(define (%string-len s) (tl_ivar s 1))
(define (%string-ref s i) (%+ (%string-ptr s) (tl_I i)))
(define (%string-set ptr strs)
  (if (null? strs) strs
    (begin
      (memcpy ptr (%string-ptr (car strs)) (%string-len (car strs)))
      (%string-set (%+ ptr (%string-len (car strs))) (cdr strs)))))
(define (string-length o) (tl_i (%string-len o)))
(define (string-ref o i)
  (tl_c (tl_uchar_get (%string-ref o i))))
(define (string-set! o i c)
  (tl_c (tl_uchar_set (%string-ref o i) (tl_C c))))
(define (string-equal? a b)
  (if (eq? a b) #t
    (if (= (string-length a) (string-length b))
      (not (tl_b (memcmp (%string-ptr a) (%string-ptr b) (%string-len a))))
      #f)))
(define (make-string size)
  (let ((o (%make-string (%malloc (+ size 1)) size)))
    (memset (%string-ptr o) (tl_I 0) (tl_I (+ size 1)))
    o))
(define (string-copy s)
  (let ((o (make-string (string-length s))))
    (memcpy (%string-ptr o) (%string-ptr s) (tl_I (+ (string-length s) 1)))
    o))
(define (substring s i n)
  (let ((o (%make-string (%malloc (+ n 1)) n)))
    (memcpy (%string-ptr o) (%+ (%string-ptr s) (tl_I i)) (tl_I n)) 
    o))
(define (string-append . strs)
  (let ((s (make-string (reduce + (map string-length strs)))))
    (%string-set (%string-ptr s) strs)
    s))

(define <null> (tl_type '()))
(define <pair> (tl_type '(a b)))
(define (pair? x) (eq? (tl_type x) <pair>))
(define (list? x) (if (null? x) #t (pair? x)))
(define (%map-1 f l)
  (if (null? l) l
    (cons (f (car l)) (%map-1 f (cdr l)))))
(define (%map f lists)
  (if (null? (car lists)) '()
    (cons
      (apply f (%map-1 car lists))
      (%map f (%map-1 cdr lists)))))
(define (map f . lists) (%map f lists))
(define (reduce f l)
  (if (null? (cdr l))
    (car l)
    (f (car l) (reduce f (cdr l)))))
(define (%append-2 a b)
  (if (null? a) b
    (cons (car a) (%append-2 (cdr a) b))))
(define (%append-3 l lists)
  (if (null? lists) l
    (%append-3 (%append-2 l (car lists)) (cdr lists))))
(define (append l . lists) (%append-3 l lists))
(define (assf f x l)
  (if (null? l) #f
    (if (f x (car (car l)))
      (car l)
      (assf f x (cdr l)))))
(define (assq x l) (assf eq? x l))
(define (assv x l) (assf eqv? x l))
(define (assoc x l) (assf equal? x l))
(define (pair-equal? a b)
  (if (equal? (car a) (car b))
    (equal? (cdr a) (cdr b))
    #f))
(define (list-length l) (list-length-2 l 0))
(define (list-length-2 l n)
  (if (null? l) n
    (list-length-2 (cdr l) (+ n 1))))
(define length list-length)
(define (reverse l) (%list-reverse-2 l '()))
(define (%list-reverse-2 l e)
  (if (null? l) e
    (%list-reverse-2 (cdr l) (cons (car l) e))))

(define <environment> (tl_type %env))
(define <vector> (make-type "vector"))
(define (vector? x) (eq? (tl_type x) <vector>))
(define (make-vector size)
  (let ((o (%allocate <vector> (* (+ size 1) %word-size))))
    (tl_set_ivar o 0 size)
    o))
(define (vector . l) (list->vector l))
(define (vector-length v) (tl_ivar v 0))
(define (vector-ref o i) (tl_ivar o (+ i 1)))
(define (vector-set! o i v) (tl_set_ivar o (+ i 1) v))
(define (vector-equal? a b)
  (if (eq? (tl_type a) (tl_type b))
    (if (eqv? (vector-length a) (vector-length b))
      (vector-equal?-2 a b 0)
      #f)
    #f))
(define (vector-equal?-2 a b i)
  (if (eqv? (vector-length a) i)
    #t
    (if (equal? (vector-ref a i) (vector-ref b i))
      (vector-equal?-2 a b (+ i 1))
      #f)))
(define (list->vector l)
  (let ((v (make-vector (list-length l))))
    (list->vector-2 l v 0)
    v))
(define (list->vector-2 l v i)
  (if (not (null? l))
    (begin
      (vector-set! v i (car l))
      (list->vector-2 (cdr l) v (+ i 1)))))
(define (tl_vector_write o p op)
  (fputs (tl_S "#(") p)
  (tl_vector_write-2 o p op 0)
  (fputs (tl_S ")") p)
    p)
(define (tl_vector_write-2 o p op i)
  (if (>= i (vector-length o)) o
    (begin
      (if (> i 0) (fputs (tl_S " ") p))
      (tl_write_2 (vector-ref o i) p op)
      (tl_vector_write-2 o p op (+ i 1))
      )))
(%object-writer <vector> tl_vector_write)

(define (equal? a b)
  (if (eq? a b)
    #t
    (if (eq? (tl_type a) (tl_type b))
      (if (eq? (tl_type a) <fixnum>)
        (eqv? a b)
        (if (eq? (tl_type a) <character>)
          (tl_b (tl_word_EQ (tl_C a) (tl_C b)))
          (if (eq? (tl_type a) <string>)
            (string-equal? a b)
            (if (eq? (tl_type a) <pair>)
              (pair-equal? a b)
              (if (eq? (tl_type a) <vector>)
                (vector-equal? a b)
                #f)))))
      #f)))

;; ## ;; logical EOF

(define %getenv getenv)
(define (getenv v)
  (if (symbol? v) (set! v (tl_car v)))
  (let ((sp (%getenv (tl_S v))))
    (if (eq? sp %NULL) #f (tl_s+ sp))))
(define %setenv setenv)
(define (setenv v s)
  (if (symbol? v) (set! v (tl_car v)))
  (%void (%setenv (tl_S v) (tl_S s))))
(define %system system)
(define (system s)
  (tl_i (%system (tl_S s))))

(list 'display= display)

(define *load-verbose* (getenv "TL_LOAD_VERBOSE"))
(define *load-debug* (getenv "TL_LOAD_DEBUG"))
(list '*load-verbose*= *load-verbose*)
(list '*load-debug*= *load-debug*)
(list 'display= display)
(define (load name . opts)
  (let ((verbose (not (null? opts))))
    (if *load-debug* (set! verbose #t))
    (if *load-verbose* (begin (display "load?: ")(display name)(newline)))
    (let ((in (open-file name "r"))
           (result #f))
      (if (not in) (error "cannot load" name)
        (begin
          (if *load-verbose* (begin (display "load: ")(display name)(newline)))
          (set! result
            (tl_repl %env (->FILE* in) 
              (if verbose (->FILE* tl_stdout) %NULL)
              (if verbose (->FILE* tl_stdout) %NULL)))
          (if *load-verbose* (begin (display "load: ")(display name)(display " : DONE.")(newline)))
          (close-port in)
          result)))))
;; (tl_eval_trace_ 1)

(load "lib/tl/map.scm")
(load "lib/tl/macro-expander.scm")
(define (tl_macro_expand exp env)
  (macro-environment-expand *top-level-macro-environment* exp))
(let ((f %define-constant))
  (set! %define-constant
    (lambda (name value)
      (tl_define name value %env)
      (f name value))))

(define-constant %unspec %unspec)
(define-constant %NULL %NULL)
(define-constant %word-size %word-size)

(load "lib/tl/caxr.scm")
(load "lib/tl/quasiquote.scm")
(define-macro quasiquote &quasiquote)
(load "lib/tl/r5rs-syntax.scm")

(define (closure-parameters x)
  (and (closure? x) (car (car x))))
(define (closure-body x)
  (and (closure? x) (cdr (car x))))

(load "lib/tl/catch.scm")
(load "lib/tl/r5rs-math.scm")
(load "lib/tl/parameter-safety.scm")

(display "Ready!")(newline)

'ok
