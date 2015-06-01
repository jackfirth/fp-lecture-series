#lang at-exp racket

(require pict
         java-lexer
         unstable/gui/scribble)

(provide java-code
         java-code-scaled
         java-code-small
         java-code-smaller
         java-code-large
         java-code-larger)


(define-syntax-rule (java-code code ...)
  (codeblock->pict (java-block code ...)))

(define-syntax-rule (java-code-scaled scaling code ...)
  (scale (java-code code ...) scaling))


(define-syntax-rule (java-code-smaller code ...)
  (java-code-scaled .5 code ...))

(define-syntax-rule (java-code-small code ...)
  (java-code-scaled .75 code ...))

(define-syntax-rule (java-code-large code ...)
  (java-code-scaled 1.25 code ...))

(define-syntax-rule (java-code-larger code ...)
  (java-code-scaled 1.5 code ...))