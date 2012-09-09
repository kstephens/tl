(define <error> (make-type "error"))

(define (%error-display msg-obj)
  (newline)
  (display "ERROR: ")(display (car msg-obj))
  (display ": ")
  (write (cdr msg-obj))
  (newline))

(define %error-catch #f)
(define *last-error* #f)
(set! tl__error 
  (lambda (msg obj)
    (set! obj (cons msg obj))
    (set! *last-error* obj)
    (if %error-catch
      (throw %error-catch obj)
      (%error-display obj))
    (abort)))

(define (%with-error-handler proc)
  (let ((prev-error-catch %error-catch)
         (result #f))
    (catch 
      (lambda (c) ;; try body
        (set! %error-catch c)
        (set! result (proc))
        (set! %error-catch prev-error-catch)
        result)
      (lambda (c v) ;; catch body
        (set! %error-catch prev-error-catch)
        (%error-display v)
        result
        )
    )))

