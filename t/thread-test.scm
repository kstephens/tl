(load "lib/tl/thread.scm")

(define m (make-mutex))
(display "m = ")(write m)(newline)

(define (count-down n)
  (if (> n 0)
    (begin
      (mutex-lock m)
      (display "In thread ")(write (current-thread))
      (display " ")(write n)(newline)
      (io-flush)
      (mutex-unlock m)
      (count-down (- n 1)))))

(define new-thread #f)
(define thread-proc 
  (lambda ()
    (display "thread_proc thread ")(write (current-thread))(newline)
    (count-down 1000)
    'OK!
    ))
(newline)(display "In main thread.  ")(newline)(io-flush)
(set! new-thread (make-thread thread-proc))
(thread-proc)
; (write "Waiting for other thread to finish")(newline)
(define new-thread-result (thread-join new-thread))
(display "Back in main thread.  ")(newline)(io-flush)
(display "new-thread-result = ")(write new-thread-result)(newline)

'ok
