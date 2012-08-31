(define new-thread #f)
(define thread_proc 
  (lambda ()
    ; (&debug)
    (newline)
    (display "In other thread ")
    (newline)(io-flush)
    ;(&debug)
    'OK!
    ))
(newline)(display "In main thread.  ")(newline)(io-flush)
(set! new-thread (tl_pthread_create thread_proc '()))
; (write "Waiting for other thread to finish")(newline)
(define new-thread-result (tl_pthread_join new-thread))
(display "Back in main thread.  ")(newline)(io-flush)
(display "new-thread-result = ")(write new-thread-result)(newline)

