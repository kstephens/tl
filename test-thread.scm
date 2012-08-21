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
(newline)(display "In main thread")(newline)(io-flush)
(set! new-thread (tl_pthread_create thread_proc nil))
; (write "Waiting for other thread to finish")(newline)
(define new-thread-result (tl_pthread_join new-thread))
(write "Back in main thread")(newline)
(write "new-thread-result = ")(write new-thread-result)(newline)

