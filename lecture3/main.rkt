#lang at-exp slideshow

(require racket/draw
         "../java-code.rkt"
         fancy-app
         "../slide-templates.rkt")


(define-syntax-rule (with-font-size font-size body ...)
  (parameterize ([current-font-size font-size])
    body ...))

(define slide-font
  (make-object font% 48
    'default
    'normal
    'normal
    #f
    'smoothed))

(current-main-font slide-font)

(title-slide (t "Algebra and Monoids"))

(current-gap-size 64)

(slide (center-para "OOP design patterns come from enterprises")
       'next
       (center-para "FP design patterns come from universities"))

(slide (center-para "More specifically, abstract algebra"))

(slide (center-para "Algebra deals with numbers, operations on numbers, and laws those operations obey"))

(slide (center-para "Abstract algebra deals with things, operations on things, and laws those operations obey"))

(slide (center-para "A monoid is a simple algebraic structure")
       'next
       (center-para "A monoid is a set of things, an operation to combine two of them, and an identity element"))

(slide (center-para "The combining operation for a monoid must obey a few laws")
       'next
       (center-para "Law of Closure: a * b must always be in the monoid"))

(slide (center-para "Positive numbers and subtraction don't form a monoid")
       (center-para "4 - 7 = -3")
       'next
       (center-para "Subtraction isn't closed over positive numbers"))

(slide (center-para "The operation must be associative")
       (center-para "a * (b * c) = (a * b) * c"))

(slide (center-para "Lastly, the identity element must \"do nothing\" with the operation")
       (center-para "a * i = a = i * a"))


(slide (center-para "Closure")
       (center-para "Associativity")
       (center-para "Identity"))

(slide (center-para "Monoids are everywhere")
       'next
       'alts
       (alternating-elements
        (center-para "Strings, concatenation, empty string")
        (center-para "Functions, composition, identity function")
        (center-para "Filters, composed filtering, filter nothing")
        (center-para "Predicates, and, always true")
        (center-para "Property getters, nested getting, get self")
        (center-para "Lists, list concatenation, empty list")))

(slide (center-para "With every monoid comes a magic way to combine a list of its elements into a single element")
       @java-code-larger{R.reduce(operation, identity);})

(slide @java-code-large{idPred = R.always(true);
                        allPass = R.reduce(R.both, idPred);})

(slide (center-para "Thinking with monoids can simplify a complex case of \"how can I do X with this list of things\""))

(slide (center-para "Real-world example - finding by precedence")
       'next
       (center-para "I want the first X in a list. If no X, I want the first Y. If no Y, I want the first Z. If no Z..."))

(slide (center-para "We need a monoid over finders - functions that find something in a list or return undefined"))
(slide (center-para "Identity element is easy - it never finds anything")
       @java-code-large{identityFinder = R.always(undefined)})

(slide (center-para "Given two finders, try the first, then try the second if the first fails")
       @java-code{tryFinders = R.curry(function(finder1, finder2, vs) {
                    return finder1(vs) || finder2(vs);
                  };})

(slide (center-para "Now we can combine a list of finders into a single finder that tries each finder in the list")
       @java-code{reduceFinders = R.reduce(tryFinders, identityFinder);})

(slide (center-para "And we can turn any predicate into a finder")
       @java-code{findByPrecedence = R.curry(function(preds, vs) {
                    finders = R.map(R.find, preds);
                    reduced = reduceFinders(finders);
                    return reduced(vs);
                  };})

(slide (center-para "First we try one predicate, then the next, then the next")
       'alts
       (alternating-elements
        @java-code{findStrOrNum = findByPrecedence([
                     R.is(String),
                     R.is(Number)
                   ]);}
        @java-code{findStrOrNum(['a', 1, 'b', 2]); // 'a'}
        @java-code{findStrOrNum([1, 'b', 2]); // 'b'}
        @java-code{findStrOrNum([1, 2]); // 1}))

(define license-logic-code
  @java-code{findIdealLicense = findByPrecedence([
               isPerpetualLicense,
               isSubscriptionLicense,
               isTrialLicense
             ]);})

(slide (center-para "We used this for MindManager license logic")
       license-logic-code)

(slide (center-para "Much nicer than some horrible for loop huh?")
       license-logic-code)

(slide (center-para "Anytime you think \"I could probably do this with reduce...\" try thinking with monoids."))