#lang racket

(require command-line-ext
         raco/command-name)


(define-syntax-rule (raco-command-line form ...)
  (command-line-ext
   #:program (short-program+command-name)
   form ...))

(raco-command-line
 #:args (lecture-name)
 (define lecture-path (format "./~a/main.rkt" lecture-name))
 (dynamic-require lecture-path #f))
