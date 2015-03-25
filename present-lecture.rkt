#lang racket

(require command-line-ext
         racket/runtime-path)


(command-line-ext
 #:program "present"
 #:args (lecture-name)
 (define lecture-path (format "./~a/main.rkt" lecture-name))
 (dynamic-require lecture-path #f))
