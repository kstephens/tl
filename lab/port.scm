(define (port? x) #t)
(define (%make-port type id transcoder)
  (vector 
    type        ; 0 
    id          ; 1
    transcoder  ; 2 
    #f          ; 3: get-position
    #f          ; 4: set-position
    #f          ; 5: close
    #f          ; 6: read!
    #f          ; 7: lookahead-char
    #f          ; 8: buffer
    #f          ; 9: buffer-read-pos
    #f          ;10: buffer-write-pos
    #f          ;11: buffer-size
    #f          ;12: buffer-ref
    ))

(define (textual-port? port) #t)
(define (binary-port? port) #t)
(define (transcoded-port binary-port transcoder) binary-port)
(define (port-has-port-position? port) (vector-ref port 3))
(define (port-position port) ((vector-ref port 3)))
(define (port-has-set-port-position!? port) (vector-ref port 4))
(define (set-port-position! port pos) ((vector-ref port 4) pos))
(define (close-port port) ((vector-ref port 5)))
(define (call-with-port port proc)
  (let ((result (proc port)))
    (close-port port)
    result))
(define (input-port? port) #t)
(define (port-eof? port) #f)
(define (open-file-input filename . options)
  )
(define (open-bytevector-input-port bytevector . options)
  )
(define (open-string-input-port string)
  )
(define (standard-input-port)
  )
(define (current-input-port)
  )
(define (with-input-from-file . args)
  )
(define (make-customer-binary-input-port id read! get-position set-position! close)
  (let ((port (%make-port 'binary-input-port id #f)))
    (vector-set! port 3 get-position)
    (vector-set! port 4 set-position!)
    (vector-set! port 5 close)
    (vector-set! port 6 read!)
    port))

(define (%read-1 port)
  (let ( (ref (vector-get port 12))
         (c   (vector-get port 7)))
    (if c (vector-set! port 7 #f)
      (let* ( (buffer (vector-get port 8))
              (count ((vector-get port 6) 
                       buffer
                       (vector-get port 10) ;; buffer-write-pos
                       (- (vector-get port 11) (vector-get port 10)) )))
        (if (= count 0) (set! c (eof-object))
          (let ((buffer-read-pos (vector-get port 9))
                 (buffer-write pos (vector-get port 10)))
            (vector-set! port 10 (+ (vector-get port 10) count))
            (set! c (ref buffer buffer-read-pos))
            (set! buffer-read-pos (+ buffer-read-pos 1))
            (if (>= buffer-read-pos buffer-write-pos)
              (begin
                (set! buffer-write-pos 0)
                (set! buffer-read-pos 0))
            (vector-set! port 9 buffer-read-pos)
            (vector-set! port 10 buffer-write-pos))))))
    c))
  
(define (get-u8 port)
  (%read-1! port))

(define (get-char port)
  (%read-1! port))
