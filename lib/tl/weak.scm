(define <weak> (make-type "weak"))
(define (make-weak val)
  (let ((w (%malloc-atomic (* %word-size 2))))
    (tl_set w 0 <weak>)
    (tl_set w 1 val)
    (set! w (%+ w (tl_I %word-size)))
    (GC_general_register_disappearing_link w val)
    w))
(define (weak-value w) (tl_car w))

(define s #f)
(define w
  (let ((ss "string"))
    (set! s ss)
    (make-weak ss)))

'ok

