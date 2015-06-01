#lang at-exp slideshow

(require "../java-code.rkt"
         fancy-app
         "../slide-templates.rkt")


(title-slide (t "Predicates, Domains, and Totality"))


(slide #:title "Predicates"
       (center-para "A predicate is a function of one argument that returns a boolean")
       @java-code{R.isEmpty, R.isNaN, R.isNil}
       'next
       (center-para "Think of them as question answering funcitons"))

(slide #:title "Terminology"
       (center-para "Quick terminology - A value is said to" (it "satisfy")
                    "a predicate if the predicate returns true for that value")
       'next
       (center-para "The value" @java-code{null} "satisfies the" @java-code{R.isNil} "predicate"))

(slide #:title "Predicates and Types"
       (center-para "A type is a set of values.")
       'next
       (center-para "A predicate defines a set of values - all the values that satisfy the predicate")
       'next
       (center-para "Therefore, a predicate defines a type. Note that this type is" (it "dynamic")
                    ", the predicate is used at runtime to determine if values belong in that type"))

(define js-pict-subtype-predicate
  @java-code{function isPositive(x) {
               return x > 0;
             }})

(slide #:title "Subtype predicates"
       (center-para "Some predicates accept all values, they return true or false no matter what you give them")
       'next
       (center-para "However this one does not - it's only defined on numbers")
       js-pict-subtype-predicate
       'next
       (center-para "A predicate accepting all values defines a type, but a predicate accepting only"
                    "some values defines a" (it "subtype")))

(slide #:title "Logical Combinators"
       (center-para "Just as the boolean values true and false can be combined with logical operations"
                    "like and, or, and not, so too can predicates")
       'next
       'alts
       (alternating-elements
        @java-code{// NOT
                   var isNotNil = R.complement(R.isNil);}
        @java-code{// OR
                   var isEmptyOrNil = R.anyPass(
                     R.isEmpty,
                     R.isNil
                   );}
        @java-code{// AND
                   var isPositiveNumber = R.allPass(
                     R.is(Number),
                     isPositive
                   );}))

(slide #:title "Why?"
       (center-para "Okay, theoretically it's pretty cool we can define types at runtime and combine"
                    "them with boolean logic and set theory, if you're into that")
       'next
       (center-para "But really, the reason predicates matter is because" (it "they're so damn useful")))

(slide #:title "Prove it"
       (center-para "Predicates are useful because of how many library functions use them to abstract"
                    "over common tasks for you")
       'next
       'alts
       (alternating-elements
        @java-code{R.filter(isPositiveNumber, [-2, -1, 0, 1, 2]);
                   // [1, 2]}
        @java-code{R.find(isPositiveNumber, [-2, -1, 0, 1, 2]);
                   // 1}
        @java-code{R.dropWhile(isNil, [null, null, 1, null, 2, 3]);
                   // [1, null, 2, 3]}
        @java-code{var flipSign = function(x) {
                     return -x;
                   };
                   var absolute = R.ifElse(
                     isPositive, R.identity, flipSign
                   );}))

(slide #:title "Domains"
       (center-para "More terminology. A function's" (it "domain") "is the set of values it can accept"
                    "as input.")
       'next
       (center-para "The domain of isPositive is the set of numbers, while the domain of isPositiveNumber"
                    "is the set of all values")
       'next
       (center-para "All functions have a domain, and all functions have to decide how to handle values"
                    "outside their domain"))

(slide #:title "Responses to bad input"
       (center-para "Statically typed languages such as Haskell use a type system to prove that its impossible"
                    "for a function to be given a value outside its domain")
       'next
       (center-para "A contract system in a dynamic language lets you wrap a function with predicates that"
                    "define the function's domain, which are checked on every call of the function")
       'next
       (center-para "Languages with neither of these constructs tend to do one of two things: throw strange"
                    "errors out of nowhere or fail silently."))

(slide #:title "Totality"
       (center-para "Functions can be either" (it "total") "or" (it "partial"))
       'next
       (center-para "A total function is defined on all values in its domain. A partial function isn't.")
       'next
       (center-para "Strange errors and silent failure are usually caused by partial functions"))

(slide #:title "Totality Continued"
       (center-para "A partial function" (it "tries") "to do something. It might fail")
       'next
       (center-para "A total function always succeeds - as long as you give it something in its domain")
       'next
       (center-para "Often times a function can be represented as either total or partial. The total"
                    "version has a more restrictive domain, while the partial version allows more values but"
                    "might fail as a result of being more permissive")
       'next
       (center-para "Which is better?"))

(slide #:title "The Wisdom of Yoda"
       (center-para "When it comes to functions:")
       'next
       (center-para "Do or do not. There is no try.")
       'next
       (center-para "Totality should be your default when designing a function. If you really need"
                    "to be more flexible about your input, then make a partial version built on top"
                    "of a core total function")
       'next
       (center-para "A function" @java-code-small{pickRandom} "that picks a random element from a list"
                    "should throw an error yelling at you if you give it an empty list, and checking"
                    "this should be the" (it "first") "thing the function does."))

(slide #:title "Okay. But totality is a pain"
       (center-para "Fine. If you really want a partial version of" @java-code-small{pickRandom}
                    "that returns" @java-code-small{undefined} "when given an empty list, name it"
                    "something else that indicates the potential for failure")
       'next
       @java-code{function maybePickRandom(xs) {
                    if (R.isEmpty(xs)) {
                      return undefined;
                    } else {
                      return pickRandom(xs);
                    }
                  }}
       'next)

(slide #:title "But everyone else uses partial functions!"
       (center-para "I don't care. Everyone else gets it wrong.")
       'next
       (center-para "Even Ramda." @java-code-small{R.find} "returns" @java-code-small{undefined}
                    "if it can't find any elements in the list that satisfy the predicate its given.")
       'next
       (center-para "This means that if you logically never expect there to be a case where"
                    @java-code-small{R.find} "fails, you have no way of knowing when that rule is"
                    "broken other than a rogue" @java-code-small{undefined} "passing around your code"))

(slide #:title "Predicates + Domains + Totality = Proofs"
       (center-para "If you write total functions, if you check their domains, and if you create"
                    "predicates representing those domains, you gain the ability to prove things"
                    "about your code")
       'next
       (center-para "If I have a total function" @java-code-small{frobnicateWidget} "that does"
                    "something to" @java-code-small{widget} "values, and a predicate"
                    @java-code-small{isWidget} ", then I can prove this code will never fail, no"
                    "matter what" @java-code-small{foo} "is")
       @java-code{if (isWidget(foo)) {
                    frobnicateWidget(foo);
                  }})

(slide #:title "Summary"
       (center-para "Predicates are simple but powerful tools for reasoning about code")
       'next
       (center-para "Learning how to use predicates gives you the power to name and define sets of"
                    "values that your code cares about, letting you filter, check, compare, and find"
                    "based on those sets of values.")
       'next
       (center-para "Combining this with domain-checking and totality will vastly reduce the potential"
                    "for bugs in your functions, and makes for more readable and self-documenting code"))
