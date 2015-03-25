#lang racket

(require command-line-ext
         raco/command-name
         racket/runtime-path)


(define-runtime-path source-dir ".")

(define-syntax-rule (raco-command-line form ...)
  (command-line-ext
   #:program (short-program+command-name)
   form ...))


(raco-command-line
 #:args (lecture-name)
 (define lecture-path (build-path source-dir lecture-name "main.rkt"))
 (dynamic-require lecture-path #f))
