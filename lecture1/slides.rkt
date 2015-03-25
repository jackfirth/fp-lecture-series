#lang slideshow

(define (title-slide . elements)
  (slide (apply para #:align 'center elements)))

(title-slide (t "Functions and Composition in Javascript"))

(define topics void)

(topics
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


(define (bullet-slide title init-para-text . items)
  (apply slide
         #:title title
         #:layout 'center
         (para (t init-para-text))
         (add-nexts (map item items))))


(define (add-nexts elements)
  (if (empty? elements)
      '()
      (list* 'next (first elements) (add-nexts (rest elements)))))


(bullet-slide "Pure functions"
              "A pure function must only depend on its arguments"
              "Must have no internal state"
              "Must not touch the outside world"
              "Must do the same thing when called twice")


(bullet-slide "So what?"
              "Why bother making a function pure?"
              "No dependency on time"
              "Easy to test"
              "Easy to compose")
