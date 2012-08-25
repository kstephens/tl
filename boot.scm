((lambda (a b) (tl_cons a b)) 1 2)

(define *env* &env)
(define *word-size* (tl_tlw_sizeof))
(define environment-vars (lambda (x) (car (car x))))
(define &eos eos)
(define eos? (lambda (x) (eq? x &eos)))
(define eq? tl_eqQ)
(define eqv? tl_eqvQ)
(define car tl_car)
(define cdr tl_cdr)
(define cons tl_cons)
(define apply tl_apply)
(define eval tl_eval)
(define repl tl_repl)
(define + tl_fixnum_ADD)
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

(define make-type 
  (lambda (n)
    (tl_m_type (->char* n))))

(define ->char* (lambda (s) (tl_ivar s 0)))

(define <port> (make-type "port"))
(define make-port
  (lambda (fp info)
    (tl_set_type (cons fp info) <port>)))
(define port-info cdr)
(define <-FILE*
  (lambda (f . rest)
    (make-port f rest)))
(define ->FILE* tl_car)
(define open-file 
  (lambda (f m)
    (<-FILE* (fopen (->char* f) (->char* m)) f)))
(define close-file
  (lambda (f)
    (fclose (->FILE* f))))
(define *stdin*  (<-FILE* _stdin '*stdin*))(set! _stdin #f)
(define *stdout* (<-FILE* _stdout '*stdout*))(set! _stdout #f)
(define *stderr* (<-FILE* _stderr '*stdin*))(set! _stderr #f)

(define null? (lambda (x) (eq? x '())))
(define display (lambda (obj . port)
  (tl_void (tl_write_2 obj (->FILE* (if (null? port) *stdout* (car port))) (tl_I 0)))))
(define write (lambda (obj . port)
  (tl_void (tl_write_2 obj (->FILE* (if (null? port) *stdout* (car port))) (tl_I 1)))))
(define newline (lambda port
  (tl_void (fputc (tl_I 10) (->FILE* (if (null? port) *stdout* (car port)))))))
(define read (lambda port
  (tl_read (->FILE* (if (null? port) *stdin* (car port))))))
(define io-flush (lambda port
  (tl_void (fflush (->FILE* (if (null? port) *stdout* (car port)))))))

(define <fixnum> (tl_type 0))
(define <character> (tl_type #\a))
(define <symbol> (tl_type 'symbol))
(define <string> (tl_type "string"))
(define %string-ptr (lambda (s) (tl_tlw_get s)))
(define %make-string
  (lambda (ptr size)
    ((lambda (o)
       (tl_set_ivar o 0 ptr)
       (tl_set_ivar o 1 (tl_I size))
       o
       ) (tl_allocate <string> (tl_I (* 2 *word-size*))))))
(define tl_S %string-ptr)
(define tl_s
  (lambda (ptr)
    (%make-string ptr (strlen ptr))))
(define %string-len (lambda (s) (tl_ivar s 1)))
(define %string-ref (lambda (s i) (tl_word_ADD (%string-ptr s) (tl_I i))))
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
    ((lambda (o)
       (memset (%string-ptr o) (tl_I 0) (tl_I (+ size 1)))
       o
       ) (%make-string (GC_malloc (tl_I (+ size 1))) size))))

(define %string-set
  (lambda (ptr strs)
    (if (null? strs) strs
      (begin
        (memcpy ptr (%string-ptr (car strs)) (%string-len (car strs)))
        (%string-set (tl_word_ADD ptr (%string-len (car strs))) (cdr strs))))))
(define string-append
  (lambda strs
    ((lambda (s)
       (%string-set (%string-ptr s) strs)
       s)
      (make-string (reduce + (map string-length strs))))))

(define <null> (tl_type '()))
(define <pair> (tl_type '(a b)))
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
(define <environment> (tl_type *env*))
(define <vector> (make-type "vector"))
(define make-vector
  (lambda (size)
    ((lambda (o)
       (tl_set_ivar o 0 size)
       o
       ) (tl_allocate <vector> (tl_I (* (+ size 1) *word-size*))))))
(define vector-length
  (lambda (o)
    (tl_ivar o 0)))
(define vector-ref
  (lambda (o i)
    (tl_ivar o (+ i 1))))
(define vector-set!
  (lambda (o i v)
    (tl_set_ivar o (+ i 1) v)))
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
    ((lambda (v)
       ;; (&debug 2)
       (list->vector-2 l v 0)
       ;; (&debug 0)
       v)
      (make-vector (list-length l)))))
(define list->vector-2 
  (lambda (l v i)
    (if (not (null? l))
      (begin
        (vector-set! v i (car l))
        (list->vector-2 (cdr l) v (+ i 1))))))
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
(define tl_object_write
  ((lambda (f)
     (lambda (o p op)
       (if (eq? (tl_type o) <vector>)
         (tl_vector_write o p op)
         (f o p op))))
    tl_object_write))

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

(list->vector '(1 2 3 4))
