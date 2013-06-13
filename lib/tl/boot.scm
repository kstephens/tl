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
(define %word-size tl_tlw_sizeof)
(define (environment-vars x) (car (car x)))
(define %eos eos)
(define eq? tl_eqQ)
(define eqv? tl_eqvQ)
(define car tl_car)
(define cdr tl_cdr)
(define set-car! tl_set_car)
(define set-cdr! tl_set_cdr)
(define cons tl_cons)
(define (list . l) l)
(define apply tl_apply)
(define (eval expr . env) (tl_eval_top_level expr (if (null? env) %env (car env))))
(define + tl_fixnum_ADD)
(define %+ tl_word_ADD)
(define - tl_fixnum_SUB)
(define * tl_fixnum_MUL)
(define / tl_fixnum_DIV)
(define % tl_fixnum_MOD)
(define %= tl_word_EQ)
(define = tl_fixnum_EQ)
(define < tl_fixnum_LT)
(define > tl_fixnum_GT)
(define >= tl_fixnum_GE)
(define <= tl_fixnum_LE)
(define %NULL (tl_I 0))
(define (%malloc size) (GC_malloc (tl_I size)))
(define (%malloc-atomic size) (GC_malloc_atomic (tl_I size)))
(define (%allocate type size)
  (set! size (* (/ (+ size (- %word-size 1)) %word-size) %word-size))
  (tl_allocate type (tl_I size)))
(define (%register-finalizer obj func)
  (GC_register_finalizer obj (tl_car tl_apply_2) func %NULL %NULL)
  obj)
(define (tl_gc) (%void (GC_gcollect)))

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
    (fprintf p (tl_S "#<port @%p :FILE* @%p ") o (tl_car o))
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
(define (open-output-file f) (open-file f "w+"))
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

(define <null> (tl_type '()))
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
(define (min a b) (if (< a b) a b))
(define (sign a) (if (negative? a) -1 (if (positive? a) 1 0)))
(define number->string tl_fixnum_TO_string)
(define (string->number s . radix)
  (tl_string_TO_number s (tl_I (if (null? radix) 10 (car radix)))))

(define <character> (tl_type #\a))
(define (character? x) (eq? (tl_type x) <character>))
(define (char->integer x) (tl_i (tl_C x)))
(define (integer->char x) (tl_c (tl_I x)))
(define (char<? a b) (< (char->integer a) (char->integer b)))
(define (char=? a b) (= (char->integer a) (char->integer b)))
(define (char<=? a b) (<= (char->integer a) (char->integer b)))
(define (char-alphabetic? c) (tl_b (isalpha (tl_C c))))
(define (char-numeric? c) (tl_b (isdigit (tl_C c))))

(define <symbol> (tl_type 'symbol))
(define (symbol? x) (eq? (tl_type x) <symbol>))
(define (keyword? o) (if (symbol? o) (tl_get o 2) #f))
(define (make-symbol name) ;; not interned.
  (tl_make_symbol (if name (tl_S name) %NULL)))
(define %gensym
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
    (tl_set o 0 ptr)
    (tl_set o 1 (tl_I size))
    o))
(define tl_S %string-ptr)
(define (tl_s ptr) (%make-string ptr (tl_i (strlen ptr))))
(define (tl_s+ ptr) (%make-string (GC_strdup ptr) (tl_i (strlen ptr))))
(define (%string-len s) (tl_get s 1))
(define (%string-ref s i) (%+ (%string-ptr s) (tl_I i)))
(define (%string-set ptr strs)
  (if (null? strs) strs
    (begin
      (memcpy ptr (%string-ptr (car strs)) (%string-len (car strs)))
      (%string-set (%+ ptr (%string-len (car strs))) (cdr strs)))))
(define (string-length o) (tl_i (%string-len o)))
(define (%string-set! s i c) (tl_c (tl_uchar_set (%string-ref s i) (tl_C c))))
(define (%string-truncate! s l)
  (tl_set s 1 (tl_I l))
  s)
(define (string-ref o i)
  (tl_c (tl_uchar_get (%string-ref o i))))
(define string-set! %string-set!)
(define (string->list s)
  (%string->list s (- (string-length s) 1) '()))
(define (%string->list s i l)
  (if (< i 0) l
    (%string->list s (- i 1) (cons (string-ref s i) l))))
(define (%string-cmp a b)
  (if (eq? a b) 0
    (tl_memcmp (%string-ptr a) (%string-ptr b) (string-length a) (string-length b))))
(define (string<? a b) (< (%string-cmp a b) 0))
(define (string>? a b) (> (%string-cmp a b) 0))
(define (string=? a b) (= (%string-cmp a b) 0))
(define (string<=? a b) (<= (%string-cmp a b) 0))
(define (string>=? a b) (>= (%string-cmp a b) 0))
(define (make-string size)
  (let ((o (%make-string (%malloc-atomic (+ size 1)) size)))
    (memset (%string-ptr o) (tl_I 0) (tl_I (+ size 1)))
    o))
(define (string-copy s)
  (let ((o (make-string (string-length s))))
    (memcpy (%string-ptr o) (%string-ptr s) (tl_I (+ (string-length s) 1)))
    o))
(define (substring! s i e)
  (%make-string (%string-ref s i) (- e i)))
(define (substring s i e)
  (let ((l (- e i)))
    (let ((o (%make-string (%malloc-atomic (+ l 1)) l)))
      (memcpy (%string-ptr o) (%+ (%string-ptr s) (tl_I i)) (tl_I l))
      o)))
(define (string-append . strs)
  (let ((s (make-string (tl:reduce + 0 (map string-length strs)))))
    (%string-set (%string-ptr s) strs)
    s))
(define (string-ends-with? a b)
  (if (>= (string-length a) (string-length b))
    (string=? (substring! a (- (string-length a) (string-length b)) (string-length a)) b)
    #f))

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
(define for-each map)
(define (tl:reduce f a l)
  (if (null? l)
    a
    (f (car l) (tl:reduce f a (cdr l)))))
(define (%append-2 a b)
  (if (null? a) b
    (cons (car a) (%append-2 (cdr a) b))))
(define (%append-3 l lists)
  (if (null? lists) l
    (%append-3 (%append-2 l (car lists)) (cdr lists))))
(define (append l . lists) (%append-3 l lists))
(define (assp f l)
  (if (null? l) #f
    (if (f (car (car l)))
      (car l)
      (assp f (cdr l)))))
(define (assq x l) (assp (lambda (y) (eq? x y)) l))
(define (assv x l) (assp (lambda (y) (eqv? x y)) l))
(define (assoc x l) (assp (lambda (y) (equal? x y)) l))
(define (pair-equal? a b)
  (if (equal? (car a) (car b))
    (equal? (cdr a) (cdr b))
    #f))
(define (list-length l) (list-length-2 l 0))
(define (list-length-2 l n)
  (if (null? l) n
    (list-length-2 (cdr l) (+ n 1))))
(define (list-ref l k)
  (if (null? l)
    (error "list-ref: range")
    (if (= k 0)
      (car l)
      (list-ref (cdr l) (- k 1)))))
(define (list-set! l k v)
  (if (null? l)
    (error "list-set!: range")
    (if (= k 0)
      (set-car! l v)
      (list-set! (cdr l) (- k 1) v))))
(define length list-length)
(define (reverse l) (%list-reverse-2 l '()))
(define (%list-reverse-2 l e)
  (if (null? l) e
    (%list-reverse-2 (cdr l) (cons (car l) e))))
(define (list->string l)
  (let ((s (make-string (list-length l))))
    (%list->string l s 0)))
(define (%list->string l s i)
  (if (>= i (string-length s)) s
    (begin
      (string-set! s i (car l))
      (%list->string (cdr l) s (+ i 1)))))

(define <environment> (tl_type %env))
(define <vector> (make-type "vector"))
(define (vector? x) (eq? (tl_type x) <vector>))
(define (make-vector size)
  (let ((o (%allocate <vector> (* (+ size 1) %word-size))))
    (tl_set o 0 size)
    o))
(define (vector . l) (list->vector l))
(define (vector-length v) (tl_get v 0))
(define (vector-ref o i) (tl_get o (+ i 1)))
(define (vector-set! o i v) (tl_set o (+ i 1) v))
(define (vector-equal? a b)
  (if (eq? (tl_type a) (tl_type b))
    (if (= (vector-length a) (vector-length b))
      (vector-equal?-2 a b 0)
      #f)
    #f))
(define (vector-equal?-2 a b i)
  (if (= (vector-length a) i)
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
(define (vector->list v)
  (vector->list-2 v 0))
(define (vector->list-2 v i)
  (if (>= i (vector-length v)) '()
    (cons (vector-ref v i) (vector->list-2 v (+ i 1)))))
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
        (tl_fixnum_EQ a b)
        (if (eq? (tl_type a) <character>)
          (tl_b (tl_word_EQ (tl_C a) (tl_C b)))
          (if (eq? (tl_type a) <string>)
            (string=? a b)
            (if (eq? (tl_type a) <pair>)
              (pair-equal? a b)
              (if (eq? (tl_type a) <vector>)
                (vector-equal? a b)
                #f)))))
      #f)))
(define (eqv? a b)
  (if (tl_eqvQ a b) #t (equal? a b)))

;; ## ;; logical EOF
(set! tl_progpath (tl_s+ tl_progpath))
(set! tl_progdir (tl_s+ tl_progdir))
(set! tl_progname (tl_s+ tl_progname))
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

(define _X_OK 1)(define _W_OK 2)(define _R_OK 4)
(define (file-readable? name)
  (= 0 (tl_i (access (%string-ptr name) (tl_I _R_OK)))))
(define (locate-file name load-path)
  (if (eqv? (string-ref name 0) #\/)
    name
    (locate-file-in-path name load-path)))
(define (locate-file-in-path name path-list) 
  (if (null? path-list) #f
    (let ((path-name (string-append (car path-list) "/" name)))
      (if (file-readable? path-name)
        path-name
        (locate-file-in-path name (cdr path-list))))))

(define (string-scan-right str c i)
  (if (< i 0) #f
    (if (eqv? (string-ref str i) c) i
      (string-scan-right str c (- i 1)))))
(define (string-index-right str c . start)
  (string-scan-right str c (if (pair? start) (car start) (- (string-length str) 1))))

(define (string-scan-left str c i)
  (if (>= i (string-length str)) #f
    (if (eqv? (string-ref str i) c) i
      (string-scan-left str c (+ i 1)))))
(define (string-index-left str c . start)
  (string-scan-left str c (if (pair> start) (car start) 0)))

(define (path-directory path)
  (let ((last-slash (string-index-right path #\/)))
    (if last-slash
      (substring path 0 last-slash)
      ".")))
(define (path-name path)
  (let ((last-slash (string-index-right path #\/)))
    (if last-slash
      (begin
        (set! last-slash (+ last-slash 1))
        (substring path last-slash (- (string-length path) 1)))
      path)))

(define *load-verbose* (getenv "TL_LOAD_VERBOSE"))
(define *load-debug* (getenv "TL_LOAD_DEBUG"))
(define *load-path* (list "." (string-append tl_progdir "/../lib")))
(define *load-current-file* ".")
(define *load-loaded* '())
(define (load-repl env in out prompt)
  (tl_repl env (->FILE* in)
    (if out (->FILE* out) %NULL)
    (if prompt (->FILE* prompt) %NULL)))
(define (load-locate-file name load-path current-file)
  (if current-file
    (set! load-path (cons (path-directory current-file) load-path)))
  (let ((pathname (locate-file name load-path)))
    (if (not pathname)
      (if (not (string-ends-with? name ".scm"))
        (begin
          (set! name (string-append name ".scm"))
          (set! pathname (locate-file name load-path)))))
    pathname))
(define (load name . opts)
  (let ((verbose (not (null? opts))) (pathname name)
         (current-file *load-current-file*))
    (if *load-debug* (set! verbose #t))
    (if *load-verbose* (begin (display "load?: ")(display name)(newline)))
    (set! pathname (load-locate-file name *load-path* current-file))
    (if (not pathname) (error "cannot locate" 'name name 'path *load-path* 'current-file current-file))
    (let ((in (open-file pathname "r"))
           (result #f))
      (if (not in) (error "cannot open" pathname)
        (begin
          (if *load-verbose* (begin
                               (display "load: ")(display name)
                               (display " => ")(display pathname)(newline)))
          (set! *load-current-file* pathname)
          (set! result
            (load-repl %env in
              (if verbose tl_stdout #f)
              (if verbose tl_stdout #f)))
          (if *load-verbose* (begin (display "load: ")(display name)(display " : DONE.")(newline)))
          (set! *load-current-file* current-file)
          (close-port in)
          (set! *load-loaded* (cons (cons name pathname) *load-loaded*))
          result)))))
;; (tl_eval_trace_ 1)

(load "tl/map")
(load "tl/macro-expander")
(define (tl_macro_expand exp env)
  (macro-environment-expand-top-level *top-level-macro-environment* exp))
(let ((f %define-constant))
  (set! %define-constant
    (lambda (name value)
      (tl_define name value %env)
      (f name value))))

(load "tl/constants")
(define (eof-object) %eos)
(define (eof-object? x) (eq? x %eos))
(load "tl/cxr")
(load "tl/quasiquote")
(define-macro quasiquote %quasiquote)
(load "tl/r5rs-syntax")
(load "tl/catch")
(load "tl/error")
(load "tl/r5rs-math")
(load "tl/parameter-safety")
(load "tl/string")
(define tl_string_escape %string-escape)
(define tl_string_unescape %string-unescape)
(load "tl/repl")
(load "tl/main")

'ok
