#lang racket

(require slideshow)

(provide title-slide
         bullet-slide)


(define (title-slide . elements)
  (slide (apply para #:align 'center elements)))


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
