#lang slideshow

(require slideshow/code)
(require scheme/pretty)
;; (require (file "compile.rkt"))


;; Library.

(define (large-text txt)
  (text txt (current-main-font) 62))

(define (pretty-syntax sexp . cols)
  (let ((port (open-input-string (apply pretty-format (cons sexp cols)))))
    (port-count-lines! port)
    (read-syntax "<no-name>" port)))

(define-syntax code-reduce
  (syntax-rules ()
    ((_ exp) 
     (let ((t exp))
       (hb-append (code exp) (tt " => ") (code (unsyntax t)))))))

(define t text)

;; (define gap-size 1.
(define (tl-struct labels)
  (frame
   (inset
    (table (+ (length labels) 1)
           `( ,(text "Label:") ,@(map (lambda (x) (inset (text x) 0)) labels)
              ,(text "Offset:") 
              ,@(let ((i -2))
                (map (lambda (x) (set! i (+ i 1)) (inset (text (number->string i)) 0)) labels))
              )
           (list* lc-superimpose)
           cc-superimpose
         gap-size
         gap-size)
    gap-size)))
             
;;;;;

(slide
 #:title "Machine Words"
 (tt "C: typedef void *tl;")
 (t "Opaque and wide enough for any address")
 )

(slide
 #:title "Allocation"
 (item "Word-aligned allocation")
 (tt "C: tl_allocate(tl type, size_t size);")
 (tt "Lisp: (tl_allocate type size)")
 (tl-struct (list "type" "slot-0" "slot-1"))
)

(slide
 #:title "Access"
 (item "Get")
 (tt "C: tl_get(tl ref, tl offset)")
 (tt "Lisp: (tl_get ref offset)")
 (item "Set")
 (tt "C: tl_set(tl ref, tl offset, tl value)")
 (tt "Lisp: (tl_set ref offset value)")
 )

(slide
 #:title "Tagging"
 (item "Encode addresses and literals in a single word.")
 (frame
  (inset
   (table 2
          (list (t "<null>")   (t "000...000")
                (t "<fixnum>") (t "sxx...xx1")
                (t "Other: use aaaa[-1]")    (t "aaa...aa0"))
          lc-superimpose cc-superimpose gap-size gap-size)
   gap-size))
)

;;;;

(slide
 #:title "Bootstrapping Scheme"
  (blank 50)
 (vc-append 0
            (t "Kurt Stephens")
            (colorize (bt "Enova Finanical") "red")
            (colorize (t "kurtstephens.com") "blue")))

(slide
 #:title "Completeness .vs. Expressiveness"
 (item "How much completeness is needed bootstrap a language?")
 (item "How much expressiveness is needed to implement a language in itself?")
 )

(slide
 #:title "Expressiveness"
 (item "Is the ability of a language to express itself a measure of its expressiveness?")
 'next
 (item "Contrast:")
 'next
 (item "Writing a C compiler in C")
 'next
 (item "Writing Scheme in Scheme")
 'next
 (item "META II"))

(slide
 #:title "Onion"
 (item "Layers")
 'next
 (item "There is a center, no matter how small.")
 (item "Meta-circular")
 (item "Turtles all the way down")
 )

(slide
 #:title "Nails through the Onion"
 (item "Layers")
 (item "Pierce layers of abstractions with commonalities")
 (item "Layer one is a subset implemented in a low-level language")
 (item "Each layer bootstraps the next")
 )

(slide
 #:title "Primitives"
 (item "Data")
 (item "Syntax")
 (item "Behavior")
 (item "State")
 )

(slide
 #:title "Layer 1 Syntax"
 (item (code (define name value)))
 (item (code (set! name value)))
 (item (code (lambda (names ...) body ...)))
 (item (code (procedure arguments ...)))
 )

(slide
 #:title "Layer 1 Behavior"
 (item "Evaluator - Scheme78 VLSI Statemachine Evaluator")
 (item "Closures")
 (item "Primitives")
 (item "Enviroments")
 )

(slide
 #:title "Layer 1 Data"
 (item "Abstract Data Types")
 (item "Concrete Data Structures")
 )

(slide
 #:title "Layer 1 ADTs"
 (item "String")
 (item "Symbol")
 (item "Integer")
 (item "Pairs")
 )

(slide
 #:title "Layer 1 CDSs"
 (item "Type")
 (item "Allocation")
 (item "Layout and Access")
 (item "Boxing")
 (item "Tagging")
 )

(slide
 #:title "Type"
(item "A datum that has a name")
(item "Used to distingush ADTs")
)

(slide
 #:title "Layout"
 (item "Pair")
 (tl-struct (list "#<pair>" "car" "cdr"))
 )


(slide
 #:title "Environments"
 (item "Names")
 (item "Values")
 (item "Scope"))

(slide
 #:title "Modeling Environments"
 (item "Template:")
 (tt "'((names . values) . outer-scope)")
 (item "Example:")
 (tt "
'(
   ( (foo bar) .   # <= names
     (1 2)         # <= values
   ) .       
   #  outer-scope: e.g. top-level
   ( (cons car cdr) .
     ((%cons (a d) ...) (%car (pair) ...) (%cdr (pair) ...))
   )
  )
"
  )
 )

(slide
 #:title "Objects .vs. Lambdas"
 (item "Objects"
       (item "Methods bound in objects by name"))
 (item "Lambdas"
       (item "Procedures bound in environments by name")))

