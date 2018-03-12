List list ;/* ; (keeps this readable by both versions of the test runner)
;;; The above works because List is both a Scheme built-in and a Dart type
;;; (Scheme is case insensitive, so we can capitalize it however we want)
;;;*/var tests_scm = r""" ;;;"

;;;; Preamble for dart_scheme:
;;;; This file consists of the following
;;;; - tests.scm from the Fall 2014 61A Scheme project
;;;; - additional tests Jen added when taking the course
;;;; - additional tests added specific to this interpreter.
;;;; It is designed to be run with scm_test.dart.

;;; Test cases for Scheme.
;;;
;;; In order to run only a prefix of these examples, add the line
;;;
;;; ; (exit)
;;;
;;; after the last test you wish to run.

;;; **********************************
;;; *** Add more of your own here! ***
;;; **********************************

;;; These are examples from several sections of "The Structure
;;; and Interpretation of Computer Programs" by Abelson and Sussman.

;;; License: Creative Commons share alike with attribution

;;; 1.1.1

10
; expect 10
(+ 137 349)
; expect 486

(- 1000 334)
; expect 666

(* 5 99)
; expect 495

(/ 10 5)
; expect 2

(+ 2.7 10)
; expect 12.7

(+ 21 35 12 7)
; expect 75

(* 25 4 12)
; expect 1200

(+ (* 3 5) (- 10 6))
; expect 19

(+ (* 3 (+ (* 2 4) (+ 3 5))) (+ (- 10 7) 6))
; expect 57

(+ (* 3
      (+ (* 2 4)
         (+ 3 5)))
   (+ (- 10 7)
      6))
; expect 57


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Move the following ; (exit) line to run additional tests. ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; (exit)


;;; 1.1.2

(define size 2)
; expect size
size
; expect 2

(* 5 size)
; expect 10

(define pi 3.14159)
(define radius 10)
(* pi (* radius radius))
; expect 314.159

(define circumference (* 2 pi radius))
circumference
; expect 62.8318

;;; 1.1.4

(define (square x) (* x x))
; expect square
(square 21)
; expect 441

(define square (lambda (x) (* x x))) ; See Section 1.3.2
(square 21)
; expect 441

(square (+ 2 5))
; expect 49

(square (square 3))
; expect 81

(define (sum-of-squares x y)
  (+ (square x) (square y)))
(sum-of-squares 3 4)
; expect 25

(define (f a)
  (sum-of-squares (+ a 1) (* a 2)))
(f 5)
; expect 136

;;; 1.1.6

(define (abs x)
  (cond ((> x 0) x)
        ((= x 0) 0)
        ((< x 0) (- x))))
(abs -3)
; expect 3

(abs 0)
; expect 0

(abs 3)
; expect 3

(define (a-plus-abs-b a b)
  ((if (> b 0) + -) a b))
(a-plus-abs-b 3 -2)
; expect 5

;;; 1.1.7

(define (sqrt-iter guess x)
  (if (good-enough? guess x)
      guess
      (sqrt-iter (improve guess x)
                 x)))
(define (improve guess x)
  (average guess (/ x guess)))
(define (average x y)
  (/ (+ x y) 2))
(define (good-enough? guess x)
  (< (abs (- (square guess) x)) 0.001))
(define (sqrt x)
  (sqrt-iter 1.0 x))
(sqrt 9)
; expect 3.00009155413138

(sqrt (+ 100 37))
; expect 11.704699917758145

(sqrt (+ (sqrt 2) (sqrt 3)))
; expect 1.7739279023207892

(square (sqrt 1000))
; expect 1000.000369924366

;;; 1.1.8

(define (sqrt x)
  (define (good-enough? guess)
    (< (abs (- (square guess) x)) 0.001))
  (define (improve guess)
    (average guess (/ x guess)))
  (define (sqrt-iter guess)
    (if (good-enough? guess)
        guess
        (sqrt-iter (improve guess))))
  (sqrt-iter 1.0))
(sqrt 9)
; expect 3.00009155413138

(sqrt (+ 100 37))
; expect 11.704699917758145

(sqrt (+ (sqrt 2) (sqrt 3)))
; expect 1.7739279023207892

(square (sqrt 1000))
; expect 1000.000369924366

;;; 1.3.1

(define (cube x) (* x x x))
(define (sum term a next b)
  (if (> a b)
      0
      (+ (term a)
         (sum term (next a) next b))))
(define (inc n) (+ n 1))
(define (sum-cubes a b)
  (sum cube a inc b))
(sum-cubes 1 10)
; expect 3025

(define (identity x) x)
(define (sum-integers a b)
  (sum identity a inc b))
(sum-integers 1 10)
; expect 55

;;; 1.3.2

((lambda (x y z) (+ x y (square z))) 1 2 3)
; expect 12

(define (f x y)
  (let ((a (+ 1 (* x y)))
        (b (- 1 y)))
    (+ (* x (square a))
       (* y b)
       (* a b))))
(f 3 4)
; expect 456

(define x 5)
(+ (let ((x 3))
     (+ x (* x 10)))
   x)
; expect 38

(let ((x 3)
      (y (+ x 2)))
  (* x y))
; expect 21

;;; 2.1.1

(define (add-rat x y)
  (make-rat (+ (* (numer x) (denom y))
               (* (numer y) (denom x)))
            (* (denom x) (denom y))))
(define (sub-rat x y)
  (make-rat (- (* (numer x) (denom y))
               (* (numer y) (denom x)))
            (* (denom x) (denom y))))
(define (mul-rat x y)
  (make-rat (* (numer x) (numer y))
            (* (denom x) (denom y))))
(define (div-rat x y)
  (make-rat (* (numer x) (denom y))
            (* (denom x) (numer y))))
(define (equal-rat? x y)
  (= (* (numer x) (denom y))
     (* (numer y) (denom x))))

(define x (cons 1 2))
(car x)
; expect 1

(cdr x)
; expect 2

(define x (cons 1 2))
(define y (cons 3 4))
(define z (cons x y))
(car (car z))
; expect 1

(car (cdr z))
; expect 3

z
; expect ((1 . 2) 3 . 4)

(define (make-rat n d) (cons n d))
(define (numer x) (car x))
(define (denom x) (cdr x))
(define (print-rat x)
  (display (numer x))
  (display '/)
  (display (denom x))
  (newline))
(define one-half (make-rat 1 2))
(print-rat one-half)
; expect 1/2

(define one-third (make-rat 1 3))
(print-rat (add-rat one-half one-third))
; expect 5/6

(print-rat (mul-rat one-half one-third))
; expect 1/6

(print-rat (add-rat one-third one-third))
; expect 6/9

(define (gcd a b)
  (if (= b 0)
      a
      (gcd b (remainder a b))))
(define (make-rat n d)
  (let ((g (gcd n d)))
    (cons (/ n g) (/ d g))))
(print-rat (add-rat one-third one-third))
; expect 2/3

(define one-through-four (list 1 2 3 4))
one-through-four
; expect (1 2 3 4)

(car one-through-four)
; expect 1

(cdr one-through-four)
; expect (2 3 4)

(car (cdr one-through-four))
; expect 2

(cons 10 one-through-four)
; expect (10 1 2 3 4)

(cons 5 one-through-four)
; expect (5 1 2 3 4)

(define (map proc items)
  (if (null? items)
      nil
      (cons (proc (car items))
            (map proc (cdr items)))))
(map abs (list -10 2.5 -11.6 17))
; expect (10 2.5 11.6 17)

(map (lambda (x) (* x x))
     (list 1 2 3 4))
; expect (1 4 9 16)

(define (scale-list items factor)
  (map (lambda (x) (* x factor))
       items))
(scale-list (list 1 2 3 4 5) 10)
; expect (10 20 30 40 50)

(define (count-leaves x)
  (cond ((null? x) 0)
        ((not (pair? x)) 1)
        (else (+ (count-leaves (car x))
                 (count-leaves (cdr x))))))
(define x (cons (list 1 2) (list 3 4)))
(count-leaves x)
; expect 4

(count-leaves (list x x))
; expect 8

;;; 2.2.3

(define (odd? x) (= 1 (remainder x 2)))
(define (filter predicate sequence)
  (cond ((null? sequence) nil)
        ((predicate (car sequence))
         (cons (car sequence)
               (filter predicate (cdr sequence))))
        (else (filter predicate (cdr sequence)))))
(filter odd? (list 1 2 3 4 5))
; expect (1 3 5)

(define (accumulate op initial sequence)
  (if (null? sequence)
      initial
      (op (car sequence)
          (accumulate op initial (cdr sequence)))))
(accumulate + 0 (list 1 2 3 4 5))
; expect 15

(accumulate * 1 (list 1 2 3 4 5))
; expect 120

(accumulate cons nil (list 1 2 3 4 5))
; expect (1 2 3 4 5)

(define (enumerate-interval low high)
  (if (> low high)
      nil
      (cons low (enumerate-interval (+ low 1) high))))
(enumerate-interval 2 7)
; expect (2 3 4 5 6 7)

(define (enumerate-tree tree)
  (cond ((null? tree) nil)
        ((not (pair? tree)) (list tree))
        (else (append (enumerate-tree (car tree))
                      (enumerate-tree (cdr tree))))))
(enumerate-tree (list 1 (list 2 (list 3 4)) 5))
; expect (1 2 3 4 5)

;;; 2.3.1

(define a 1)

(define b 2)

(list a b)
; expect (1 2)

(list 'a 'b)
; expect (a b)

(list 'a b)
; expect (a 2)

(car '(a b c))
; expect a

(cdr '(a b c))
; expect (b c)

(define (memq item x)
  (cond ((null? x) false)
        ((eq? item (car x)) x)
        (else (memq item (cdr x)))))
(memq 'apple '(pear banana prune))
; expect #f

(memq 'apple '(x (apple sauce) y apple pear))
; expect (apple pear)

(define (equal? x y)
  (cond ((pair? x) (and (pair? y)
                        (equal? (car x) (car y))
                        (equal? (cdr x) (cdr y))))
        ((null? x) (null? y))
        (else (eq? x y))))
(equal? '(1 2 (three)) '(1 2 (three)))
; expect #t

(equal? '(1 2 (three)) '(1 2 three))
; expect #f

(equal? '(1 2 three) '(1 2 (three)))
; expect #f

;;; Peter Norvig tests (http://norvig.com/lispy2.html)

(define double (lambda (x) (* 2 x)))
(double 5)
; expect 10

(define compose (lambda (f g) (lambda (x) (f (g x)))))
((compose list double) 5)
; expect (10)

(define apply-twice (lambda (f) (compose f f)))
((apply-twice double) 5)
; expect 20

((apply-twice (apply-twice double)) 5)
; expect 80

(define fact (lambda (n) (if (<= n 1) 1 (* n (fact (- n 1))))))
(fact 3)
; expect 6

(fact 50)
; expect 30414093201713378043612608166064768844377641568960512000000000000

(define (combine f)
  (lambda (x y)
    (if (null? x) nil
      (f (list (car x) (car y))
         ((combine f) (cdr x) (cdr y))))))
(define zip (combine cons))
(zip (list 1 2 3 4) (list 5 6 7 8))
; expect ((1 5) (2 6) (3 7) (4 8))

(define riff-shuffle (lambda (deck) (begin
    (define take (lambda (n seq) (if (<= n 0) (quote ()) (cons (car seq) (take (- n 1) (cdr seq))))))
    (define drop (lambda (n seq) (if (<= n 0) seq (drop (- n 1) (cdr seq)))))
    (define mid (lambda (seq) (/ (length seq) 2)))
    ((combine append) (take (mid deck) deck) (drop (mid deck) deck)))))
(riff-shuffle (list 1 2 3 4 5 6 7 8))
; expect (1 5 2 6 3 7 4 8)

((apply-twice riff-shuffle) (list 1 2 3 4 5 6 7 8))
; expect (1 3 5 7 2 4 6 8)

(riff-shuffle (riff-shuffle (riff-shuffle (list 1 2 3 4 5 6 7 8))))
; expect (1 2 3 4 5 6 7 8)

;;; Additional tests

(apply square '(2))
; expect 4

(apply + '(1 2 3 4))
; expect 10

(apply (if false + append) '((1 2) (3 4)))
; expect (1 2 3 4)

(if 0 1 2)
; expect 1

(if '() 1 2)
; expect 1

(or false true)
; expect #t

(or)
; expect #f

(and)
; expect #t

(or 1 2 3)
; expect 1

(and 1 2 3)
; expect 3

(and false (/ 1 0))
; expect #f

(and true (/ 1 0))
; expect Error

(or 3 (/ 1 0))
; expect 3

(or false (/ 1 0))
; expect Error

(or (quote hello) (quote world))
; expect hello

(if nil 1 2)
; expect 1

(if 0 1 2)
; expect 1

(if (or false false #f) 1 2)
; expect 2

(define (loop) (loop))
(cond (false (loop))
      (12))
; expect 12

((lambda (x) (display x) (newline) x) 2)
; expect 2 ; 2

(define g (mu () x))
(define (high f x)
  (f))

(high g 2)
; expect 2

(define (print-and-square x)
  (print x)
  (square x))
(print-and-square 12)
; expect 12 ; 144

(/ 1 0)
; expect Error

(define addx (mu (x) (+ x y)))
(define add2xy (lambda (x y) (addx (+ x x))))
(add2xy 3 7)
; expect 13


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Scheme Implementations ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; len outputs the length of list s
(define (len s)
  (if (eq? s '())
    0
    (+ 1 (len (cdr s)))))
(len '(1 2 3 4))
; expect 4


;;;;;;;;;;;;;;;;;;;;
;;; Extra credit ;;;
;;;;;;;;;;;;;;;;;;;;

; (exit)

; Tail call optimization tests

(define (sum n total)
  (if (zero? n) total
    (sum (- n 1) (+ n total))))
(sum 1001 0)
; expect 501501

(define (sum n total)
  (cond ((zero? n) total)
        (else (sum (- n 1) (+ n total)))))
(sum 1001 0)
; expect 501501

(define (sum n total)
  (begin 2 3
    (if (zero? n) total
      (and 2 3
        (or false
          (begin 2 3
            (let ((m n))
              (sum (- m 1) (+ m total)))))))))
(sum 1001 0)
; expect 501501


;;;;;;;;;;;;;;
;;; Macros ;;;
;;;;;;;;;;;;;;

(define x 7)
(define-macro (test) (define x 5) (list '+ 'x 4))
(test)
; expect 11

(define-macro (when test . branch)
  (list 'if test (cons 'begin branch)))

(when true
  (define a 1)
  (define b 1)
  (+ a 1))
; expect 2

a
; expect 1
b
; expect 1

(when false
  (define a 2)
  (define b 2))
  
a
; expect 1
b
; expect 1

;;;;;;;;;;;;;;;;
;;;; Vectors ;;; (disabled for now since new interpreter doesn't support it)
;;;;;;;;;;;;;;;;
;
;'#(1 2 3 4 5)
;; expect #(1 2 3 4 5)
;
;(define a 0)
;
;'#(a 1 2 3)
;; expect #(a 1 2 3)
;
;(vector a 1 2 3)
;; expect #(0 1 2 3)
;
;(define test-vector '#(1 2 3 4 5))
;
;(define (vector-map vector fn . index)
;  (define index (if (null? index) 0 (car index)))
;  (if (= (vector-length vector) index) vector
;      (begin (vector-set! vector index (fn (vector-ref vector index)))
;             (vector-map vector fn (+ index 1)))))
;(define (square x) (* x x))
;
;(vector-map test-vector square)
;; expect #(1 4 9 16 25)
;
;test-vector
;; expect #(1 4 9 16 25)
;
;(vector? test-vector)
;; expect #t
;
;(vector? '(1 2 3))
;; expect #f
;
;(vector->list '#(1 2 3))
;; expect (1 2 3)
;
;(list->vector '(1 2 3))
;; expect #(1 2 3)
;
;(make-vector 4)
;; expect #(() () () ())
;
;(make-vector 4 'hi)
;; expect #(hi hi hi hi)

;;;;;;;;;;;;;;;;
;;;; Hashing ;;; (disabled for now since new interpreter doesn't support it)
;;;;;;;;;;;;;;;;
;
;(= (hash-code '(1 2 3)) (hash-code '(1 2 3)))
;; expect #t
;
;(= (hash-code '#(1 2 3)) (hash-code '#(1 2 3)))
;; expect #t
;
;(= (hash-code '(1 2 3)) (hash-code '#(1 2 3)))
;; expect #f
;
;(= (hash-code (lambda () 4)) (hash-code (lambda () 4)))
;; expect #t
;
;(= (hash-code (lambda () 4)) (hash-code (lambda () 5)))
;; expect #f
;
;; This works when compiled to JS, but Dart's bignums
;; overrides my implementation in the VM, so 4 != 4.0 there
;;(= (hash-code 4) (hash-code 4.0))
;;; expect #t
;
;(= (hash-code 4) (hash-code (+ 2 2)))
;; expect #t
;
;(= (hash-code 4.1) (hash-code (/ 41 10)))
;; expect #t

;;;;;;;;;;;;;;;;
;;; Promises ;;;
;;;;;;;;;;;;;;;;

; from lecture 29 fa15

;; Sequence operations

;; Map f over s.
(define (map f s)
  (if (null? s) 
      nil
      (cons (f (car s))
            (map f 
                 (cdr s)))))
  
;; Filter s by f.
(define (filter f s)
  (if (null? s)
      nil
      (if (f (car s))
          (cons (car s) 
                (filter f (cdr s)))
          (filter f (cdr s)))))

;; Reduce s using f and start value.
(define (reduce f s start)
  (if (null? s) 
      start
      (reduce f
              (cdr s)
              (f start (car s)))))

;; Primes

;; List integers from a to b.
(define (range a b)
  (if (>= a b) nil (cons a (range (+ a 1) b))))

;; Sum elements of s
(define (sum s)
  (reduce + s 0))

;; Is x prime?
(define (prime? x)
  (if (<= x 1) 
      false
      (null? 
       (filter (lambda (y) (= 0 (remainder x y)))
               (range 2 x)))))

;; Sum primes from a to b
(define (sum-primes a b)
  (sum (filter prime? (range a b))))


;; Streams 

(define s (cons-stream 1 (cons-stream 2 nil)))

(define t (cons-stream 1 (/ 1 0)))

(define (range-stream a b)
  (if (>= a b) nil (cons-stream a (range-stream (+ a 1) b))))

;; Infinite Streams

(define (int-stream start)
  (cons-stream start (int-stream (+ start 1))))

(define (prefix s k)
  (if (= k 0) 
      nil 
      (cons (car s) 
            (prefix (cdr-stream s) 
                    (- k 1)))))

;; Processing

(define ones (cons-stream 1 ones))

(define (square-stream s)
  (cons-stream (* (car s) (car s))
               (square-stream (cdr-stream s))))

(define (add-streams s t)
  (cons-stream (+ (car s) (car t))
               (add-streams (cdr-stream s)
                            (cdr-stream t))))

(define ints (cons-stream 1 (add-streams ones ints)))

;; Repeat Example

(define a (cons-stream 1 (cons-stream 2 (cons-stream 3 a))))

(define (f s) (cons-stream (car s) 
                           (cons-stream (car s)
                                        (f (cdr-stream s)))))

(define (g s) (cons-stream (car s)
                           (f (g (cdr-stream s)))))

;; Higher-Order

;; Map f over s.
(define (map-stream f s)
  (if (null? s) 
      nil
      (cons-stream (f (car s))
            (map-stream f 
                 (cdr-stream s)))))
  
;; Filter s by f.
(define (filter-stream f s)
  (if (null? s)
      nil
      (if (f (car s))
          (cons-stream (car s) 
                (filter-stream f (cdr-stream s)))
          (filter-stream f (cdr-stream s)))))

;; Reduce s using f and start value.
(define (reduce-stream f s start)
  (if (null? s) 
      start
      (reduce-stream f
              (cdr-stream s)
              (f start (car s)))))

(define (sum-stream s)
  (reduce-stream + s 0))

(define (sum-primes-stream a b)
  (sum-stream (filter-stream prime? (range-stream a b))))

(define (sieve s)
  (cons-stream 
   (car s) 
   (sieve (filter-stream
           (lambda (x) (> (remainder x (car s)) 0))
           (cdr-stream s)))))

(define primes (sieve (int-stream 2)))

(prefix primes 10)
; expect (2 3 5 7 11 13 17 19 23 29)

;;;;;;;;;;;;;;
;;;; Logic ;;; (disabled for now since new interpreter doesn't support it)
;;;;;;;;;;;;;;
;
;(logic-query '(((likes john dogs)) ((likes jack cats))) '((likes ?who ?what)))
;; expect ((("?who" "john") ("?what" "dogs")) (("?who" "jack") ("?what" "cats")))
;
;(logic)
;
;(fact (likes john dogs))
;(query (likes john dogs))
;; expect Success!
;
;(query (likes ?who dogs))
;; expect Success!; who: john
;
;; Dogs
;
;(fact (parent abraham barack))
;(fact (parent abraham clinton))
;(fact (parent delano herbert))
;(fact (parent fillmore abraham))
;(fact (parent fillmore delano))
;(fact (parent fillmore grover))
;(fact (parent eisenhower fillmore))
;
;; Recursive facts
;
;(fact (ancestor ?a ?y) (parent ?a ?y))
;(fact (ancestor ?a ?y) (parent ?a ?z) (ancestor ?z ?y))
;
;; Hierarchical facts
;
;(fact (dog (name abraham) (color white)))
;(fact (dog (name barack) (color tan)))
;(fact (dog (name clinton) (color white)))
;(fact (dog (name delano) (color white)))
;(fact (dog (name eisenhower) (color tan)))
;(fact (dog (name fillmore) (color gray)))
;(fact (dog (name grover) (color tan)))
;(fact (dog (name herbert) (color gray)))
;
;; Building relations
;
;(fact (ancestry ?name) (dog (name ?name) . ?details))
;(fact (ancestry ?child ?parent . ?rest)
;      (parent ?parent ?child)
;      (ancestry ?parent . ?rest))
;
;(query (ancestry barack . ?lineage))
;; expect Success!; lineage: (); lineage: (abraham); lineage: (abraham fillmore); lineage: (abraham fillmore eisenhower)
;
;(query (ancestor ?a clinton)
;       (ancestor ?a ?gray-dog)
;       (dog (name ?gray-dog) (color gray)))
;; expect Success!; a: fillmore	gray-dog: herbert; a: eisenhower	gray-dog: fillmore; a: eisenhower	gray-dog: herbert

;;; end tests.scm. Below keeps this importable in Dart.
;;;""";
