(define (%string-escape-1 s i t j)
  (define (ac c)
    (string-set! t j c)
    (set! j (+ j 1)))
  (define (ao i)
    (ac (integer->char (+ (char->integer #\0) (truncate-remainder i 8)))))
  (if (>= i (string-length s))
    (%string-truncate! t j)
    (let ((k (char->integer (string-ref s i))))
      (case k
        ((10) (ac #\\) (ac #\n))
        ((13) (ac #\\) (ac #\r))
        ((9)  (ac #\\) (ac #\t))
        ((7)  (ac #\\) (ac #\b))
        ((27) (ac #\\) (ac #\e))
        ((92 34) (ac #\\) (ac (integer->char k)))
        (else
          (if (and (>= k 32) (< k 127))
            (ac (integer->char k))
            (begin
              (ac #\\)
              (ao (truncate-quotient k 64))
              (ao (truncate-quotient k 8))
              (ao k)
              ))))
      (%string-escape-1 s (+ i 1) t j))))
(define (%string-escape s)
  (%string-escape-1 s 0 (make-string (* 4 (string-length s))) 0))

(define (%string-unescape-1 s i j)
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
                      ((#\x #\X) c) ;; FIXME
                      ((#\0)     c) ;; FIXME
                      (else      c)
                      ))
            (string-set! s j c)))
        (string-set! s j (string-ref s i)))
      (%string-unescape-1 s (+ i 1) (+ j 1)))))
(define (%string-unescape s) (%string-unescape-1 s 0 0))

