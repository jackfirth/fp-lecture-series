#lang at-exp slideshow

(require "java-code.rkt"
         fancy-app
         "slide-templates.rkt")

(define (center-para . elements)
  (apply para #:align 'center elements))


(title-slide (t "Functions and Composition in Javascript"))

(define topics void)

(topics
 "thunks"
 "const functions"
 "method composition - composition of dyadic functions all operating on the same data"
 "predicates"
 "monoids"
 "concat"
 "tryadic functions where first argument often config for concat of some sort")


(slide #:title "Pure functions"
       (center-para "A pure function must only depend on its arguments")
       'next
       (center-para "Must have no internal state")
       'next
       (center-para "Must not touch the outside world")
       'next
       (center-para "Must do the same thing when called twice"))


(slide #:title "So what?"
       (center-para "Why bother making a function pure?")
       'next
       (center-para "No dependency on time")
       'next
       (center-para "Easy to test")
       'next
       (center-para "Easy to compose"))

(slide #:title "Composition"
       (center-para "The simplest functions are pure functions of one argument")
       'next
       (center-para "Data goes in, data comes out")
       'next
       (center-para "Functions of one argument are called \"monadic\" (no relation to monads)"))

(slide #:title "Making monadic functions"
       (center-para "Monadic functions aren't powerful alone")
       'next
       (center-para "Dyadic functions (two arguments) are very common")
       'next
       (center-para "We can use currying to turn dyadics into monadics"))

(slide #:title "Currying"
       (center-para "A curried function doesn't need all it's arguments")
       'next
       (center-para "When not given enough arguments, it returns a new function taking the rest")
       'next
       (center-para "By ordering arguments properly, we can design dyadics that curry into useful monadics"))

(slide #:title "Argument order"
       (center-para "The last argument should be the data")
       'next
       (center-para "Initial arguments should be viewed as configuration")
       'next
       (center-para "This lets us configure a dyadic function to get the monadic function we need")
       'next
       @java-code{R.is, R.filter, R.map, R.has})

(slide #:title "Putting dyadics together"
        @java-code-small{var isObject = R.is(Object);
                         var findObjects = R.filter(isObject);
                         var findWithEid = R.filter(R.has("eid"));
                         var findEntities = R.compose(findWithEid, findObjects);})

(define (alternating-elements . elements)
  (map list elements))

(slide #:title "Designing dyadics"
       (center-para "Loading entities is very common. Let's make it a well-designed dyadic")
       'alts
       (alternating-elements
        @java-code-small{function loadEntity(pattern, entity) {
                           return entity.load(pattern);
                         }}
        @java-code-small{var loadEntity = function(pattern, entity) {
                           return entity.load(pattern);
                         }}
        @java-code-small{var loadEntity = R.curry(function(pattern, entity) {
                           return entity.load(pattern);
                         }})
       'next
       (center-para "Now lets use it to load and get a tenant's inquiries")
       'alts
       (alternating-elements
        @java-code-small{var loadInquiries = loadEntity({inquiries: true});
                         var getInquiries = R.get("inquiries");
                         var getTenantInquiries = function(tenant) {
                           return loadInquiries(tenant).then(getInquiries);
                         }}
        @java-code-small{var loadInquiries = loadEntity({inquiries: true});
                         var getInquiries = R.get("inquiries");
                         var getTenantInquiries = R.composeP(loadInquiries, getInquiries);}))

(slide #:title "More dyadics"
       (center-para "Frequently we load only one property to get that property. Let's make that a dyadic helper too.")
       'alts
       (alternating-elements
        @java-code-small{var loadAndGetProperty = R.curry(function(property, entity) {
                           var pattern = {};
                           pattern[property] = true;
                           return loadEntity(pattern, entity).get(property);
                         }}
        @java-code-small{var loadAndGetProperty = R.curry(function(property, entity) {
                           var pattern = R.createMapEntry(property, true);
                           return loadEntity(pattern, entity).get(property);
                         }})
       'next
       (center-para "Now loading and getting a tenant's inquiries looks like this:")
       @java-code-small{var getTenantInquiries = loadAndGetProperty('inquiries');})

(slide #:title "Even more dyadics"
       (center-para "We can load multiple entities, but then we have a bunch of promises.")
       'next
       (center-para "Q.all lets us wait on all promises in an array.")
       'next
       (center-para "Let's compose these ideas.")
       'next
       @java-code-small{var mapPromises = R.curry(function(f, vs) {
                          return Q.all(R.map(f, vs));
                        }
                        var loadAllEntities = R.curry(function(pattern, entities) {
                          return mapPromises(loadEntity(pattern), entities);
                        }}
       'next
       (center-para "With this, it's easy to make a function to load the creators of a set of ideas")
       @java-code-small{var loadAllIdeaCreators = loadAllEntities({ creator: true });})


(define (stagger-lists xs ys)
  (cond [(empty? xs) '()]
        [(= (length xs) 1)
         (if (empty? ys)
             '()
             (list (list (first xs)  (first ys))))]
        [else
         (let ([x1 (first xs)]
               [x2 (second xs)]
               [xs-rest (rest xs)]
               [y (first ys)]
               [ys-rest (rest ys)])
           (list* (list x1 y)
                  (list x2 y)
                  (stagger-lists xs-rest ys-rest)))]))


(define (refactoring-dialogue . dialogue-and-code-picts)
  (define-values (dialogue code-picts)
    (partition string? dialogue-and-code-picts))
  (define dialogue-paras (map center-para dialogue))
  (stagger-lists dialogue-paras code-picts))

(slide #:title "Applying these principles"
       'alts
       (refactoring-dialogue
        "Say you want to get all open inquiries of a challenge. An imperative approach might look like this:"
        @java-code-smaller{function getOpenInquiries(challenge) {
                             return challenge.load({inquiries: {endDate: true}})
                               .then(function() {
                                 var openInquiries = [];
                                 var endDate;
                                 for (var i = 0; i < challenge.inquiries.length; i += 1) {
                                   endDate = new Date(challenge.inquiries[i].endDate);
                                   if (endDate > new Date()) {
                                     openInquiries.push(challenge.inquiries[i]);
                                   }
                                 }
                                 return openInquiries;
                             });
                           }}
        "Extremely gross. Let's pull out that condition for checking if an inquiry is open"
        @java-code-smaller{function isOpenInquiry(inquiry) {
                             var endDate = new Date(inquiry.endDate);
                             return endDate > new Date();
                           }
                                                           
                           function getOpenInquiries(challenge) {
                             return challenge.load({inquiries: {endDate: true}})
                               .then(function() {
                                 var openInquiries = [];
                                 for (var i = 0; i < challenge.inquiries.length; i += 1) {
                                   if (isOpenInquiry(challenge.inquiries[i]) {
                                     openInquiries.push(challenge.inquiries[i])
                                   }
                                 }
                                 return openInquiries;
                             });
                           }}
         "We can do better with that predicate. Let's pull out checking if a date is in the future."
         @java-code-smaller{var isFutureDateString = function(dateString) {
                              return new Date(dateString) > new Date();
                            }
                                                                          
                            var isOpenInquiry = function(inquiry) {
                              return isFutureDateString(inquiry.endDate);
                            }
                            
                            function getOpenInquiries(challenge) {
                              return challenge.load({inquiries: {endDate: true}})
                                .then(function() {
                                  var openInquiries = [];
                                  for (var i = 0; i < challenge.inquiries.length; i += 1) {
                                    if (isOpenInquiry(challenge.inquiries[i]) {
                                      openInquiries.push(challenge.inquiries[i])
                                    }
                                  }
                                  return openInquiries;
                              });
                            }}
         "But wait! Now isOpenInquiry is just isFutureDateString composed with a getter"
         @java-code-smaller{var isFutureDateString = function(dateString) {
                              return new Date(dateString) > new Date();
                            }
                                                                          
                            var isOpenInquiry = R.compose(isFutureDateString. R.get("endDate"));
                            
                            function getOpenInquiries(challenge) {
                              return challenge.load({inquiries: {endDate: true}})
                                .then(function() {
                                  var openInquiries = [];
                                  for (var i = 0; i < challenge.inquiries.length; i += 1) {
                                    if (isOpenInquiry(challenge.inquiries[i]) {
                                      openInquiries.push(challenge.inquiries[i])
                                    }
                                  }
                                  return openInquiries;
                              });
                            }}
         "Cool. Back to the main function. How about replacing our for loop with _.forEach?"
         @java-code-smaller{var isFutureDateString = function(dateString) {
                              return new Date(dateString) > new Date();
                            }
                                                                          
                            var isOpenInquiry = R.compose(isFutureDateString. R.get("endDate"));
                            
                            function getOpenInquiries(challenge) {
                              return challenge.load({inquiries: {endDate: true}})
                                .then(function() {
                                  var openInquiries = [];
                                  _.forEach(challenge.inquiries, function(inquiry) {
                                    if (isOpenInquiry(inquiry) {
                                      openInquiries.push(inquiry)
                                    }
                                  }
                                  return openInquiries;
                              });
                            }}
         "The only thing our loop does is filter the inquiries. Why not just use R.filter?"
         @java-code-smaller{var isFutureDateString = function(dateString) {
                              return new Date(dateString) > new Date();
                            }
                                                                          
                            var isOpenInquiry = R.compose(isFutureDateString. R.get("endDate"));
                            
                            function getOpenInquiries(challenge) {
                              return challenge.load({inquiries: {endDate: true}})
                                .then(function() {
                                  return R.filter(isOpenInquiry, challenge.inquiries);
                              });
                            }}
         "Much better. Note that challenge.load(...) returns the challenge, so our filtering function gets it as an argument"
         @java-code-smaller{var isFutureDateString = function(dateString) {
                              return new Date(dateString) > new Date();
                            }
                                                                          
                            var isOpenInquiry = R.compose(isFutureDateString. R.get("endDate"));
                            
                            function getOpenInquiries(challenge) {
                              return challenge.load({inquiries: {endDate: true}})
                                .then(function(challenge) {
                                  return R.filter(isOpenInquiry, challenge.inquiries);
                              });
                            }}
         "But we don't really need the challenge there. Just the inquiries:"
         @java-code-smaller{var isFutureDateString = function(dateString) {
                              return new Date(dateString) > new Date();
                            }
                                                                          
                            var isOpenInquiry = R.compose(isFutureDateString. R.get("endDate"));
                            
                            function getOpenInquiries(challenge) {
                              return challenge.load({inquiries: {endDate: true}})
                                .then(R.get("inquiries"))
                                .then(function(inquiries) {
                                  return R.filter(isOpenInquiry, inquiries);
                              });
                            }}
         "And R.filter is curried, so there's no need to pass inquiries explicitly"
         @java-code-smaller{var isFutureDateString = function(dateString) {
                              return new Date(dateString) > new Date();
                            }
                                                                          
                            var isOpenInquiry = R.compose(isFutureDateString. R.get("endDate"));
                            
                            function getOpenInquiries(challenge) {
                              return challenge.load({inquiries: {endDate: true}})
                                .then(R.get("inquiries"))
                                .then(R.filter(isOpenInquiry));
                            }}
         "Now we're really getting somewhere. Let's pull out that complex loading too."
         @java-code-smaller{var isFutureDateString = function(dateString) {
                              return new Date(dateString) > new Date();
                            }
                                                                          
                            var isOpenInquiry = R.compose(isFutureDateString. R.get("endDate"));
                            
                            var loadChallengeInquiryDates = loadEntity({inquiries: {endDate: true}});
                            
                            function getOpenInquiries(challenge) {
                              return loadChallengeInquiryDates(challenge)
                                .then(R.get("inquiries"))
                                .then(R.filter(isOpenInquiry));
                            }}
         "Now we have a promise chain of monadic functions. That means we can use R.composeP"
         @java-code-smaller{var isFutureDateString = function(dateString) {
                              return new Date(dateString) > new Date();
                            }
                                                                          
                            var isOpenInquiry = R.compose(isFutureDateString. R.get("endDate"));
                            
                            var loadChallengeInquiryDates = loadEntity({inquiries: {endDate: true}});
                            
                            var getOpenInquiries = R.composeP(
                              R.filter(isOpenInquiry),
                              R.get("inquiries"),
                              loadChallengeInquiryDates
                            );}
         "Still a nontrivial composition. Let's seperate loading and filtering."
         @java-code-smaller{var isFutureDateString = function(dateString) {
                              return new Date(dateString) > new Date();
                            }
                                                                          
                            var isOpenInquiry = R.compose(isFutureDateString. R.get("endDate"));
                            
                            var loadChallengeInquiryDates = loadEntity({inquiries: {endDate: true}});
                            
                            var findOpenChallengeInquiries = R.compose(
                              R.filter(isOpenInquiry),
                              R.get("inquiries"));
                              
                            var getOpenInquiries = R.composeP(
                              findOpenChallengeInquiries,
                              loadChallengeInquiryDates);}
         "Is this better?"))
