(define new_thread #f)
(define thread_proc 
  (lambda ()
    (&debug)
    (display "In other thread ")
    (newline)
    (&debug)))
(display "In main thread")(newline)
(set! new_thread (tl_pthread_create thread_proc nil))
(write "Waiting for other thread to finish")(newline)
(tl_pthread_join new_thread)
(write "Back in main thread")(newline)

