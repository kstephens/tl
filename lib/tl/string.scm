#|
(define (%tl_string_escape s i t j)
(define (tl_string_escape s) (%tl_string_escape s 0 (make-string (* 4 (string-length s))) 0)
|#

(define (%tl_string_unescape-1 s i j)
  (if (>= i (string-length s))
    (%string-truncate! s j)
    (begin
      (if (and (char=? #\\ (string-ref s i)) (< i (- (string-length s) 1)))
        (begin
          (set! i (+ i 1))
          (let ((c (string-ref s i)))
            (set! c (case c
                      ((#\n) (integer->char 10))
                      ((#\r) (integer->char 13))
                      ((#\t) (integer->char 9))
                      ((#\b) (integer->char 7))
                      ((#\e) (integer->char 27))
                      ((#\x #\X) c)
                      ((#\0)     c)
                      (else      c)
                      ))
            (string-set! s j c)))
        (string-set! s j (string-ref s i)))
      (%tl_string_unescape-1 s (+ i 1) (+ j 1)))))
(define (%tl_string_unescape s) (%tl_string_unescape-1 s 0 0))
(define tl_string_unescape %tl_string_unescape)
