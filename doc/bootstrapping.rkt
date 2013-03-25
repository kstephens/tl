#lang slideshow

(require slideshow/code)
(require scheme/pretty)
(require racket/draw) ;; color%
(require racket/string) ;; string-split
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

(define (lines str proc)
  (apply vl-append 1.0 (map proc (string-split str "\n"))))
(define (t str)  (lines str (lambda (str) (text str "Helvetica" 30 0))))
(define (tt str) (lines str (lambda (str) (text str (cons 'bold 'modern) 30 0))))
(define p para)
(define (c-code str)
  (lines str (lambda (str) (colorize (tt str) (make-object color% 160 0 0)))))
(define (lisp-code str)
  (lines str (lambda (str) (colorize (tt str) (make-object color% 0 160 0)))))


;; (define gap-size 1.
(define (tl-struct labels)
  (if (and (list? labels) (not (list? (car labels))))
      (set! labels (list labels)) #f)
  (let* ((left "Label:")
         (elems
          `( 
              ,@(map (lambda (r)
                       (let ((h left))
                         (set! left "")
                         `(,(t left) ,@(map (lambda (x) (inset (tt x) 0)) r)))
                       ) labels)
              (,(t "Offset:")
                ,@(let ((i -2))
                  (map (lambda (x) (set! i (+ i 1)) (inset (tt (number->string i)) 0)) (car labels)))
                ))))
    ;; (write labels)(newline)
    ;; (write elems)(newline)
    (frame
     (inset
      (table (length (car elems))
           (flatten elems)
           (list* lc-superimpose)
           cc-superimpose
         gap-size
         gap-size)
    gap-size))))

;;;;;

(slide
 #:title "Bootstrapping A Programming Language"
  (blank 50)
 (vc-append 0
            (t "Kurt Stephens")
            (colorize (t "kurtstephens.com") "blue")))

(slide
 #:title "Agenda"
 (item "Expressiveness")
 (item "Completeness")
 (item "Circularity")
 (item "Layers")
 )

(slide
 #:title "Completeness .vs. Expressiveness"
 (item "How much completeness is needed bootstrap a language?")
 (item "How much expressiveness is needed to implement a language in itself?")
 )

(slide
 #:title "Expressiveness"
 (item "Is the simplicity of an implementation of a language a measure of the language's expressiveness?")
 'next
 (item "What about the simplicity of its meta-circular implementation?")
 'next
 (p "Contrast:")
 'next
 (item "Writing a C compiler in C.")
 'next
 (item "Writing Scheme interpreter in Scheme.")
 'next
 (item "META II."))

(slide
 #:title "Onions and Snakes"
 (item "Peeling the Onion.")
 'next
 (p "    Layers:")
 'next
 (p "    \"There is a center, no matter how small.\"")
 'next
 (item "Snake Eating its Tail.")
 'next
 (p "    Meta-circular:")
 'next
 (p "    \"Turtles all the way down.\"")
 'next
 (p "    \"Class is subclass of Object.")
 'next
 (p "    \"Object is an instance of Class.\"")
 'next
 (p "    \"Class is an instance of Class.\"")
 )

(slide
 #:title "Nails through the Onion"
 'next
 (item "Layer Zero is a subset of Layer One implemented in a lower-level language.")
 'next
 (item "Each layer bootstraps the next.")
 'next
 (item "One layer's safe abstraction is another layer's unsafe primitive.")
 'next
 (item "Reuse, Cut the Snake: Pierce abstraction layers with structural or functional isomorphisms.")
 'next
 (item "Lift and Reconnect the Snake: meta-circular redefinitions.")
 )

(slide
 #:title "Language Constructs"
 (item "Syntax")
 (item "Semantics")
 (item "Data")
 (item "Values")
 (item "State")
 )

(slide
 #:title "Layer One Syntax"
 (item (code (define name value)))
 (item (code (set! name value)))
 (item (code (if pred then else?)))
 (item (code (lambda (names ...) body ...)))
 (item (code (procedure arguments ...)))
 (item "Tail-recursion")
 )

(slide
 #:title "Layer One Semantic Implementation"
 (item "Evaluator - Scheme78 Statemachine Evaluator")
 (item "Closures")
 (item "Primitive Procedures")
 (item "Tail-recursion")
 (item "Enviroments")
 )

(slide
 #:title "Primitive Procedures"
 (item "Unsafe primitives in a lower level are accessible in higher levels.")
 (item "Primitives are temporary implementations in higher levels until safe re-implementations are complete.")
 'next
 (c-code "tl tl_car(tl pair);")
 'next
 (item "Is available as:")
 'next
 (lisp-code "(tl_car pair)")
 'next
 (item "And temporarily reused as:")
 (lisp-code "(define car tl_car)")
 )

(slide
 #:title "Layer Zero Data"
 (item "Layer Zero")
 (p "    Concrete Data Structures")
 'next
 (item "Layer One")
 (p "    Abstract Data Types")
 )

(slide
 #:title "Layer One ADTs"
 (item "Strings")
 (item "Symbols")
 (item "Integers")
 (item "Pairs")
 )

(slide
 #:title "Layer Zero CDSs"
 (item "Values")
 (item "Allocation")
 (item "Layout and Access")
 (item "Typing")
 (item "Boxing")
 (item "Tagging")
 )

(slide
 #:title "Layer Zero Values"
 (t "Machine-level Words:")
 'next
 (c-code "typedef void *tl;")
 'next
 (t "Opaque and wide enough for any address.")
 'next
 (c-code "typedef size_t tlw;")
 (c-code "typedef ssize_t tlsw;")
 'next
 (t "Analogously sized integer values.")
 )

(slide
 #:title "Layer Zero Allocation"
 (item "Word-aligned allocation:")
 (c-code "tl tl_allocate(tl type, size_t size);")
 'next
 (lisp-code "(tl_allocate type size)")
 'next
 (tl-struct (list "type" "slot-0" "slot-1"))
)

(slide
 #:title "Layer Zero Access"
 (tl-struct (list "type" "slot-0" "slot-1"))
 'next
 (item "Get:")
 'next
 (c-code "tl tl_get(tl ref, tl offset);")
 'next
 (lisp-code "(tl_get ref offset)")
 'next
 (item "Set:")
 'next
 (c-code "tl tl_set(tl ref, tl offset, tl value);")
 'next
 (lisp-code "(tl_set ref offset value)")
 )

(slide
 #:title "Primitive Procedures"
 (item "Unsafe primitives in a lower level are accessible in higher levels.")
 'next
 (item "Primitives are temporary implementations in higher levels until safe re-implementations are complete.")
 'next
 (c-code "tl tl_car(tl pair);")
 'next
 (item "Is available as:")
 'next
 (lisp-code "(tl_car pair)")
 'next
 (item "And temporarily reused as:")
 (lisp-code "(define car tl_car)")
 )

(slide
 #:title "Layer Zero Typing"
(item "Distingushes an ADT's dynamic structure.")
(item "Anchors a CDS with a well-known structure.")
'next
(item "How?")
'next
(p "   A CDSs with unused fields.")
)

(define tl_box-table
 (frame
  (inset
   (table 4
          (list (t "Type")              (t "Bit Pattern") (t "Box")              (t "Unbox")
                (lisp-code "'<null>")   (c-code "000...000")  (c-code "v = tl_nil")  (tt "N/A")
                (lisp-code "'<fixnum>") (hb-append (tt "Xxx...xx")(c-code "1"))  (c-code "v = tl_i(x)") (c-code "x = tl_I(v)")
                (c-code "a[-1]")        (hb-append (tt "aaa...aa")(c-code "0"))  (c-code "v = (tl) a")  (c-code "a = (tl*) v")
    )
          lc-superimpose cc-superimpose gap-size gap-size)
   gap-size))
  )

(slide
 #:title "Tagging and Boxing"
 (item "Encode ADT type and representation in a single word.")
 'next
 tl_box-table)

(slide
 #:title "Type Decoding"
 tl_box-table
 (c-code "
#define tl_type(v)                    \\
  (        (v) == 0 ? tl_t_null     : \\
    ((tlw) (v)) & 1 ? tl_t_fixnum   : \\
                      tl_get(v, -1) )
")
 'next
 (lisp-code "(tl_type v)")
 )

(slide
 #:title "Layer Zero CDS"
 (item "Pair CDS Layout")
 (tl-struct (list "'<pair>" "car" "cdr"))
 'next
 (item "Pair CDS Constructor:")
 (c-code "
tl tl_cons(tl car, tl_cdr) {
  tl *o = tl_allocate(tl_t_cons, sizeof(tl) * 2);
  o[0] = car; o[1] = cdr;
  return o;
}")
 )

(slide
 #:title "Layer One ADT"
 (item "ADT Constructor:")
 (lisp-code "
(define (cons car cdr)
  (let ((pair (tl_allocate <pair>
                (tl_I (* 2 %word-size)))))
   (tl_set pair 0 car)
   (tl_set pair 1 cdr)
   pair))
")
 'next
 (item "Unsafe ADT Operations")
 (lisp-code "(define (car p) (tl_get p 0))")
 (lisp-code "(define (cdr p) (tl_get p 1))")
 )

(slide
 #:title "Layer One Environments"
 (item "Names")
 (item "Values")
 (item "Scope"))

(slide
 #:title "Layer One Environments"
 (item "Template:")
 (tt "'((names . values) . outer-scope)")
 (item "Example:")
 (lisp-code "
'(
   ( (foo bar) .   ;; <= names
     (1 2) )       ;; <= values
   .
   ;; outer-scope: e.g. top-level via (define name value)
   ( (cons car cdr) .
     ((%cons (a d) ...) (%car (pair) ...) (%cdr (pair) ...))
   )
  )
")
 )

(slide
  #:title "Layer Two: Extend Syntax"
  (lisp-code "(let ((name val) ...) body ...)")
  )

(slide
 #:title "Layer Two: Syntax Extension"
 (item "Macro expansion of:")
 (lisp-code "(let ((foo 1) (bar 2)) (+ foo bar))")
 (item "... expands to:")
 (lisp-code "((lambda (foo bar) (+ foo bar)) 1 2)")
 )

(slide
 #:title "Layer Two: Syntax Extension Facility"
 (item "Implement a macro expander, without using (let ...) syntax.")
 (item "Hook macro expander into Level Zero Evaluator.")
 (item "Define (let ...) syntax using macro expander.")
 )

(slide
 #:title "Layer Three: Reify type safety."
 (item "Define macro to wrap unsafe primitive with type checking.")
 (lisp-code "(define-macro (add-type-checking proc . arg-predicates) ...)")
 (item "Apply macro to unsafe primitives.")
 (lisp-code "(add-type-checking car pair?)")
 )

(slide
 #:title "Layer Four: Define Additional Data Types."
 (item "Vectors:")
 (lisp-code "
(define <vector> (make-type <object>))
(define (make-vector size)
  (let ((vector (tl_allocate <vector>
                  (tl_I (* %word-size (+ size 1))))))
    (tl_set vector 0 size)
    vector
    ))
(define (vector-ref v i) (tl_get v (+ i 1)))
(add-type-checking (make-vector non-negative-fixnum?))
(add-type-checking (vector-ref vector? non-negative-fixnum?))
")
 )

(slide
 #:title "Layer Five: Extend: Define object system."
 (item "At this level:")
 (item "Use Vectors as a CDS for object slots.")
 (item "Use Closures as a primitive for methods.")
 )

(slide
 #:title "Layer Z: Compilation."
 (item "Implement compiler for Layer One language in Layer Z-1 language.")
 'next
 (item "Compiler recognizes Layer One primitives.")
 'next
 (item "Use compiler to compile itself.")
 'next
 (item "Discard Layer Zero.")
 )

(slide
 #:title "Objects .vs. Lambda"
 (item "Objects")
 (p "    Methods bound in objects by name.")
 (item "Lambdas")
 (p "    Procedures bound in environments by name.")
 )

(slide
 #:title "Pair/Object/Environment Isomorphism"
 (tl-struct (list (list "'<pair>" "car" "cdr")
                  (list "'<environment>" "names-values" "outer-env")
                  (list "'<type>" "selectors-methods" "supertype")))
 'next
 (item "Environments and types could be implemented using typed pairs.")
 'next
 (item "Method lookup could be the same as environment lookup.")
 )

