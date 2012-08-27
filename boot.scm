((lambda (a b) (tl_cons a b)) 1 2) ;; test
(let ((a 1) (b 2)) (tl_cons a b))  ;; test
(let ((a 1) (b 2))
  (let ((c (tl_cons a b)))
    c))
(define %void (lambda x tl_v))
(define *env* &env)
(define *word-size* (tl_tlw_sizeof))
(define environment-vars (lambda (x) (car (car x))))
(define &eos eos)
(define eos? (lambda (x) (eq? x &eos)))
(define eq? tl_eqQ)
(define eqv? tl_eqvQ)
(define car tl_car)
(define cdr tl_cdr)
(define set-car! tl_set_carE)
(define set-cdr! tl_set_cdrE)
(define cons tl_cons)
(define list (lambda l l))
(define apply tl_apply)
(define eval tl_eval)
(define repl tl_repl)
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
(define not 
  (lambda (x) 
    (if (eq? x #f)
      #t #f)))
(define %NULL (tl_I 0))
(define %malloc
  (lambda (size)
    (GC_malloc (tl_I size))))
(define %allocate
  (lambda (type size)
    (tl_allocate type (tl_I size))))
(define %register-finalizer
  (lambda (obj func)
    ;; (display "%register-finalizer ")(write obj)(display " ")(write func)(newline)
    ;; (GC_register_finalizer obj tl_apply_2 func %NULL %NULL)
    obj))

(define make-type 
  (lambda (n)
    (tl_m_type (->char* n))))

(define ->char* (lambda (s) (tl_ivar s 0)))

(define <port> (make-type "port"))
(define port? (lambda (x) (eq? (tl_type x) <port>)))
(define %make-port
  (lambda (fp info)
    (tl_set_type (cons fp info) <port>)))
(define port-info cdr)
(define %object-writer
  (lambda (type f)
    (set! tl_object_write
      (let ((old-f tl_object_write))
        (lambda (o p op)
          (if (eq? (tl_type o) type)
            (f o p op)
            (old-f o p op)))))))
(%object-writer <port>
  (lambda (o p op)
    (fprintf p (tl_S "#<port @%p ") o)
    (tl_write_2 (port-info o) p op)
    (fputs (tl_S ">") p)
    p))
(define <-FILE* (lambda (f) (%make-port f '())))
(define ->FILE* tl_car)
(define open-file 
  (lambda (f m)
    (%register-finalizer 
      (%make-port (fopen (->char* f) (->char* m)) (list f m))
      close-port)))
(define close-port
  (lambda (p)
    ;; (display "close-port ")(write p)(newline)
    (if (not (eq? (->FILE* p) #f))
      (begin
        ;; (display "close-port: fclose")(newline)
        (fclose (->FILE* p))))
    (set-car! p #f)
    p))
(set! tl_stdin  (%make-port tl_stdin 'tl_stdin))
(set! tl_stdout (%make-port tl_stdout 'tl_stdout))
(set! tl_stderr (%make-port tl_stderr 'tl_stderr))

(define null? (lambda (x) (eq? x '())))

(define display (lambda (obj . port)
  (%void (tl_write_2 obj (->FILE* (if (null? port) tl_stdout (car port))) (tl_I 0)))))
(define write (lambda (obj . port)
  (%void (tl_write_2 obj (->FILE* (if (null? port) tl_stdout (car port))) (tl_I 1)))))
(define newline (lambda port
  (%void (fputc (tl_I 10) (->FILE* (if (null? port) tl_stdout (car port)))))))
(define read (lambda port
  (tl_read (->FILE* (if (null? port) tl_stdin (car port))))))
(define io-flush (lambda port
  (%void (fflush (->FILE* (if (null? port) tl_stdout (car port)))))))
;; (write (environment-vars *env*))(newline)

(define <fixnum> (tl_type 0))
(define <character> (tl_type #\a))
(define character? (lambda (x) (eq? (tl_type x) <character>)))
(define <symbol> (tl_type 'symbol))
(define symbol? (lambda (x) (eq? (tl_type x) <symbol>)))
(define make-symbol (lambda (s) 
  (let ((o (%allocate <symbol> (* 1 *word-size*))))
    (tl_set_ivar o 0 s)
    o)))
(define <string> (tl_type "string"))
(define string? (lambda (x) (eq? (tl_type x) <string>)))
(define %string-ptr (lambda (s) (tl_tlw_get s)))
(define %make-string
  (lambda (ptr size)
    (let ((o (%allocate <string> (* 2 *word-size*))))
       (tl_set_ivar o 0 ptr)
       (tl_set_ivar o 1 (tl_I size))
       o)))
(define tl_S %string-ptr)
(define tl_s
  (lambda (ptr)
    (%make-string ptr (strlen ptr))))
(define %string-len (lambda (s) (tl_ivar s 1)))
(define %string-ref (lambda (s i) (%+ (%string-ptr s) (tl_I i))))
(define %string-set
  (lambda (ptr strs)
    (if (null? strs) strs
      (begin
        (memcpy ptr (%string-ptr (car strs)) (%string-len (car strs)))
        (%string-set (%+ ptr (%string-len (car strs))) (cdr strs))))))
(define string-length (lambda (o) (tl_i (%string-len o))))
(define string-ref
  (lambda (o i)
    (tl_c (tl_uchar_get (%string-ref o i)))))
(define string-set!
  (lambda (o i c)
    (tl_c (tl_uchar_set (%string-ref o i) (tl_C c)))))
(define string-equal?
  (lambda (a b)
    (if (eq? a b)
      #t
      (if (= (string-length a) (string-length b))
        (not (tl_b (memcmp (%string-ptr a) (%string-ptr b) (%string-len a))))
        #f))))
(define make-string
  (lambda (size)
    (let ((o (%make-string (%malloc (+ size 1)) size)))
       (memset (%string-ptr o) (tl_I 0) (tl_I (+ size 1)))
       o)))
(define string-copy
  (lambda (s)
    (let ((o (make-string (string-length s))))
       (memcpy (%string-ptr o) (%string-ptr s) (tl_I (+ (string-length s) 1)))
       o)))
(define substring
  (lambda (s i n)
    (let ((o (%make-string (%malloc (+ n 1)) n)))
       (memcpy (%string-ptr o) (%+ (%string-ptr s) (tl_I i)) (tl_I n)) 
       o)))
(define string-append
  (lambda strs
    (let ((s (make-string (reduce + (map string-length strs)))))
       (%string-set (%string-ptr s) strs)
       s)))

(define <null> (tl_type '()))
(define <pair> (tl_type '(a b)))
(define pair? (lambda (x) (eq? (tl_type x) <pair>)))
(define %map-1
  (lambda (f l)
    (if (null? l) l
      (cons (f (car l)) (%map-1 f (cdr l))))))
(define %map
  (lambda (f lists)
    (if (null? (car lists)) '()
      (cons 
        (apply f (%map-1 car lists))
        (%map f (%map-1 cdr lists))))))
(define map
  (lambda (f . lists)
    (%map f lists)))
(define reduce 
  (lambda (f l)
    (if (null? (cdr l))
      (car l)
      (f (car l) (reduce f (cdr l))))))
(define %append-2
  (lambda (a b)
    (if (null? a)
      b
      (cons (car a) (%append-2 (cdr a) b)))))
(define %append-3
  (lambda (l lists)
    (if (null? lists)
      l
      (%append-3 (%append-2 l (car lists)) (cdr lists)))))
(define append (lambda (l . lists) (%append-3 l lists)))
(define assf
  (lambda (f x l)
    (if (null? l) #f
      (if (f x (car (car l)))
        (car l)
        (assf f x (cdr l))))))
(define assq 
  (lambda (x l) (assf eq? x l)))
(define assv
  (lambda (x l) (assf eqv? x l)))
(define assoc
  (lambda (x l) (assf equal? x l)))
(define pair-equal?
  (lambda (a b)
    (if (equal? (car a) (car b))
      (equal? (cdr a) (cdr b))
      #f)))
(define list-length
  (lambda (l) (list-length-2 l 0)))
(define list-length-2
  (lambda (l n)
    (if (null? l) n
      (list-length-2 (cdr l) (+ n 1)))))
(define reverse
  (lambda (l) (%list-reverse-2 l '())))
(define %list-reverse-2
  (lambda (l e)
    (if (null? l) e
      (%list-reverse-2 (cdr l) (cons (car l) e)))))
(define <type> (tl_type (tl_type '())))
(define type? (lambda (x) (eq? (tl_type x) <type>)))
(define <environment> (tl_type *env*))
(define <vector> (make-type "vector"))
(define vector? (lambda (x) (eq? (tl_type x) <vector>)))
(define make-vector
  (lambda (size)
    (let ((o (%allocate <vector> (* (+ size 1) *word-size*))))
       (tl_set_ivar o 0 size)
       o)))
(define vector (lambda l (list->vector l)))
(define vector-length (lambda (o) (tl_ivar o 0)))
(define vector-ref (lambda (o i) (tl_ivar o (+ i 1))))
(define vector-set! (lambda (o i v) (tl_set_ivar o (+ i 1) v)))
(define vector-equal?
  (lambda (a b)
    (if (eq? (tl_type a) (tl_type b))
      (if (eqv? (vector-length a) (vector-length b))
        (vector-equal?-2 a b 0)
        #f)
      #f)))
(define vector-equal?-2 
  (lambda (a b i)
    (if (eqv? (vector-length a) i)
      #t
      (if (equal? (vector-ref a i) (vector-ref b i))
        (vector-equal?-2 a b (+ i 1))
        #f))))
(define list->vector
  (lambda (l)
    (let ((v (make-vector (list-length l))))
       ;; (&debug 2)
       (list->vector-2 l v 0)
       ;; (&debug 0)
       v)))
(define list->vector-2 
  (lambda (l v i)
    (if (not (null? l))
      (begin
        (vector-set! v i (car l))
        (list->vector-2 (cdr l) v (+ i 1))))))
(list->vector '(1 2 3 4))
(define tl_vector_write
  (lambda (o p op)
    (fputs (tl_S "#(") p)
    (tl_vector_write-2 o p op 0)
    (fputs (tl_S ")") p)
    p))
(define tl_vector_write-2
  (lambda (o p op i)
    (if (>= i (vector-length o))
      o
      (begin
         (if (> i 0) (fputs (tl_S " ") p))
         (tl_write_2 (vector-ref o i) p op)
         (tl_vector_write-2 o p op (+ i 1))
         ))))
;; (tl_vector_write (list->vector '(1 2 3 4)) (->FILE* *stdout*) (tl_I 0))(newline)
;; (write tl_object_write)(newline)
(%object-writer <vector> tl_vector_write)
;; (write tl_object_write)(newline)

(define equal?
  (lambda (a b)
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
        #f))))


