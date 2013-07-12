(set! *quasiquote-debug* #t)
(%quasiquote '())
(%quasiquote '(foo bar))
(%quasiquote '(foo ,(+ 1 2) bar))
(set! *quasiquote-debug* #f)

