#lang slideshow

(define (title-slide . elements)
  (slide (apply para #:align 'center elements)))

(title-slide (t "Functions and Composition in Javascript"))

(topics
 "pure functions"
 "simple composition with monadic functions"
 "currying as a way of making multi-argument functions composable"
 "data last"
 "dyadic functions - first argument config for action, specializing to mondac"
 "thunks"
 "const functions"
 "method composition - composition of dyadic functions all operating on the same data"
 "predicates"
 "monoids"
 "concat"
 "tryadic functions where first argument often config for concat of some sort")
