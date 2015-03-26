#lang at-exp racket

(require pict
         java-lexer
         unstable/gui/scribble)

(provide java-code
         java-code-scaled
         java-code-small
         java-code-smaller)


(define-syntax-rule (java-code code ...)
  (codeblock->pict (java-block code ...)))

(define-syntax-rule (java-code-scaled scaling code ...)
  (scale (java-code code ...) scaling))


(define-syntax-rule (java-code-smaller code ...)
  (java-code-scaled .5 code ...))

(define-syntax-rule (java-code-small code ...)
  (java-code-scaled .75 code ...))
