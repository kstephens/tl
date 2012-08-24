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
(define not 
  (lambda (x) 
    (if (eq? x #f)
      #t #f)))

(define make-type 
  (lambda (n)
    (tl_m_type (->char* n))))

(define ->char* (lambda (s) (tl_ivar s 0)))

(define <port> (make-type "port"))
(define <-FILE*
  (lambda (f)
    (tl_typeSET (cons f #f) <port>)))
(define ->FILE* tl_car)
(define open-file 
  (lambda (f m)
    (<-FILE* (fopen (->char* f) (->char* m)))))
(define close-file
  (lambda (f)
    (fclose (->FILE* f))))
(define *stdin*  (<-FILE* _stdin))(set! _stdin #f)
(define *stdout* (<-FILE* _stdout))(set! _stdout #f)
(define *stderr* (<-FILE* _stderr))(set! _stderr #f)

(define null? (lambda (x) (eq? x '())))
(define display (lambda (obj . port)
  (tl_void (tl__write obj (->FILE* (if (null? port) *stdout* (car port))) (tl_I 0)))))
(define write (lambda (obj . port)
  (tl_void (tl__write obj (->FILE* (if (null? port) *stdout* (car port))) (tl_I 1)))))
(define newline (lambda port)
  (tl_void (tl_fputc (tl_I 10) (->FILE* (if (null? port) *stdout* (car port))))))
(define read (lambda port
  (tl_read (->FILE* (if (null? port) *stdin* (car port))))))
(define io-flush (lambda port
  (tl_void (fflush (->FILE* (if (null? port) *stdout* (car port)))))))

(define <fixnum> (tl_type 0))
(define <character> (tl_type #\a))
(define <symbol> (tl_type 'symbol))
(define <string> (tl_type "string"))
(define %string-ptr (lambda (s) (tl_tlw_get s)))
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

(define <null> (tl_type '()))
(define <pair> (tl_type '(a b)))
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
        (vector-equal?2 a b 0)
        #f)
      #f)))
(define vector-equal?2 
  (lambda (a b i)
    (if (eqv? (vector-length a) i)
      #t
      (if (equal? (vector-ref a i) (vector-ref b i))
        (vector-equal?2 a b (+ i 1))
        #f))))
(define list->vector
  (lambda (l)
    ((lambda (v)
       (list->vector-3 l v 0)
       v)
      (make-vector (list-length l)))))
(define list->vector-3 
  (lambda (l v i)
    (if (not (null? l))
      ((lambda ()
         (vector-set! v i (car l))
         (list->vector-3 (cdr l) v (+ i 1)))))))

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
