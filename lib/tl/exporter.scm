(define (export-expr datum)
  (cond
    ((null? datum)    ''())
    ((symbol? datum)  `(quote ,datum))
    ((pair? datum)    `(cons ,(export-expr (car datum))
                             ,(export-expr (cdr datum))))
    ((vector? datum)  `(vector @,(map export-expr (vector->list datum))))
    (#t                datum)
    ))
