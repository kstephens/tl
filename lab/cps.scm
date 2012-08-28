(define (T-k expr k)
  (cond
    ((and
       (pair? expr)
       (eq? 'lambda (car expr)))
      (k (M expr)))
    ((symbol? expr)
      (k (M expr)))
    ((pair? expr)
      (let* (($rv (genusym '$rv))
              (cont `(x (,$rv) ,(k $rv))))
        (T-k f (lambda ($f)
                 (T-K e (lambda ($e)
                          `(,$f ,$e ,cont))))))))
    ))
       
(define (T-c expr c)
  (cond
    ((and
       (pair? expr)
       (eq? 'lambda (car expr)))
      `(,c ,(M expr)))
    ((symbol? expr)
      `(,c ,(M expr)))
    ((pair? expr)
      (T-k f (lambda ($f)
               (T-k e (lambda ($e)
                        `(,$f ,$e ,c))))))
    ))
     
(define (M expr)
  (cond
    ((and
       (pair? expr)
       (eq? 'lambda (car expr)))
      (let ((var (cadr expr))
             (expr (caddr expr)))
        (let (($k (genksym '$k)))
          `(lambda (,var ,$k)
             ,(T-c expr $k)))))
    ((symbol? expr)
      expr)
    ))
