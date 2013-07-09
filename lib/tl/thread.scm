(define (main-thread) *main-thread*)
(define *main-thread* (tl_pthread_self))
(tl_set *main-thread* 3 '(:name (main-thread)))
(define (current-thread) (tl_pthread_self))
(define (make-thread proc . opts)
  (tl_pthread_create proc opts))
(define (thread-join t) (tl_pthread_join t))
(define (thread-exit v) (pthread_exit v))
(define (thread-cancel t) (pthread_cancel t))

(define <pthread_mutex_t> (make-type "pthread_mutex_t"))
(define (make-pthread_mutex_t)
  (let ((o (%allocate <pthread_mutex_t> tl_pthread_mutex_t_sizeof)))
    (tl_i (pthread_mutex_init o %NULL))
    (%register-finalizer o pthread_mutex_destroy)
    o))

(define <mutex> (make-type "mutex"))
(define (make-mutex . opts)
  (let ( (o (%allocate <mutex> (* %word-size 4))))
    (tl_set_car o (make-pthread_mutex_t))
    (tl_set_cdr o opts)
    o))
(define (mutex-destroy o)
  (if (tl_car o)
    (tl_i (pthread_mutex_destroy (tl_car o))))
  (tl_set_car o #f))
(define (mutex-lock o)
  (tl_i (pthread_mutex_lock (tl_car o))))
(define (mutex-unlock o)
  (tl_i (pthread_mutex_unlock (tl_car o))))

'ok
