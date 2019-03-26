(define (cons x y)
  (define (set-x! v) (set! x v))
  (define (set-y! v) (set! y v))
  (define (dispatch m)
    (cond ((eq? m 'car) x)
          ((eq? m 'cdr) y)
          ((eq? m 'set-car!) set-x!)
          ((eq? m 'set-cdr!) set-y!)
          (else (error "Undefined operation -- CONS" m))))
  dispatch)
(define (car z) (z 'car))
(define (cdr z) (z 'cdr))
(define (set-car! z new-value)
  ((z 'set-car!) new-value)
  z)
(define (set-cdr! z new-value)
  ((z 'set-cdr!) new-value)
  z)
; __________________________________________________________________________
;
; global env: cons -------------------------------------+
;             car ---------------------------+          |
;             cdr -------------------+       |          |
;             set-car! --------+     |       |          |
;             set-cdr! --+     |     |       |          |
; _______________________|_____|_____|_______|__________|___________________
;                        |     |     |  ^    |  ^       |  ^
;                        ........    |  |    |  |       |  |
;                                    |  |    o  o       o  o
;                                    |  |    |          |
;                                    |  |params: z     params: x y 
;                                    |  |body:(z 'car) body: (define set-x! ...
;                                    |  |                    (define set-y! ...
;                                    o  o                    (define dispatch ...
;                                params: z                   dispatch
;                                body:(z 'cdr)



(define x (cons 1 2))
; for (cons 1 2) part, create a new env E1, with initial binding x=1, y=2
; And eval body of cons, which will further creates binding set-x!, set-y!, dispatch
;
; ________________________________________________________________________________________________________
;
; global env: cons -------------------------------------+
;             car ---------------------------+          |
;             cdr -------------------+       |          |
;             set-car! --------+     |       |          |
;             set-cdr! --+     |     |       |          |
; _______________________|_____|_____|_______|__________|_________________________________________________
;                        |     |     |  ^    |  ^       |  ^                           ^
;                        ........    |  |    |  |       |  |                           |
;                                    |  |    o  o       o  o                           |
;                                    |  |    |          |                              |
;                                    |  |params: z     params: x y                     |
;                                    |  |body:(z 'car) body: (define set-x! ...        |
;                                    |  |                    (define set-y! ...        |
;                                    o  o                    (define dispatch ...      |
;                                params: z                   dispatch                  |
;                                body:(z 'cdr)                              ___________|_____________
;                                                                            
;                                                                           E1: x: 1               <-------+----+---+
;                                                                               y: 2                       |    |   |
;                                                                               set-x!: lambda ...  ----o  o    |   |
;                                                                               set-y!: lambda ...  ----o  o----+   |
;                                                                               dispatch: lambda ...----o  o--------+
;                                                                           _________________________
;                                                                           
;
; disatch as ret, which in turn be bound to global env as x:
;
; ________________________________________________________________________________________________________
;
; global env: cons -------------------------------------+
;             car ---------------------------+          |
;             cdr -------------------+       |          |
;             set-car! --------+     |       |          |
;             set-cdr! --+     |     |       |          |
;             x --+      |     |     |       |          |
; ________________|______|_____|_____|_______|__________|_________________________________________________
;                 |      |     |     |  ^    |  ^       |  ^                           ^
;                 |      ........    |  |    |  |       |  |                           |
;                 |                  |  |    o  o       o  o                           |
;                 |                  |  |    |          |                              |
;                 |                  |  |params: z     params: x y                     |
;                 |                  |  |body:(z 'car) body: (define set-x! ...        |
;                 |                  |  |                    (define set-y! ...        |
;                 |                  o  o                    (define dispatch ...      |
;                 |              params: z                   dispatch                  |
;                 |              body:(z 'cdr)                              ___________|_____________
;                 |
;                 |                                                         E1: x: 1               <-------+----+---+
;                 |                                                             y: 2                       |    |   |
;                 |                                                             set-x!: lambda ...  ----o  o    |   |
;                 |                                                             set-y!: lambda ...  ----o  o----+   |
;                 +-------------------------------------------------------->    dispatch: lambda ...----o  o--------+
;                                                                           _________________________
;





(define z (cons x x))
;
; _____________________________________________________________________________________________________________
;
; global env: cons -------------------------------------+
;             car ---------------------------+          |
;             cdr -------------------+       |          |
;             set-car! --------+     |       |          |
;             set-cdr! --+     |     |       |          |
;             x --+      |     |     |       |          |
;             z   |      |     |     |       |          |
; ____________|___|______|_____|_____|_______|__________|_______________________________________________________
;             |   |      |     |     |  ^    |  ^       |  ^                           ^                   ^
;             |   |      ........    |  |    |  |       |  |                           |                   |
;             |   |                  |  |    o  o       o  o                           |                   |
;             |   |                  |  |    |          |                              |                   |
;             |   |                  |  |params: z     params: x y                     |                   |
;             |   |                  |  |body:(z 'car) body: (define set-x! ...        |                   |
;             |   |                  |  |                    (define set-y! ...        |                   |
;             |   |                  o  o                    (define dispatch ...      |                   |
;             |   |              params: z                   dispatch                  |                   |
;             |   |              body:(z 'cdr)                              ___________|_____________      |
;             |   |                                                                                        |
;             |   |                                                         E1: x: 1                 <-+   |
;             |   |                                                             y: 2                   |   |
;             |   |                                                             set-x!: lambda ...   o o   |
;             |   |                                                             set-y!: lambda ...   o o   |
;             |   +-----------------------------------------------------------> dispatch: lambda ... o o   |
;             |                                                             _________________________      |
;             |                                                                                            |
;             |                                                                                 ___________|_____________
;             |                                                                                  
;             |                                                                                 E2: x: x                 <-+
;             |                                                                                     y: x                   |
;             |                                                                                     set-x!: lambda ...   o o
;             |                                                                                     set-y!: lambda ...   o o
;             +-----------------------------------------------------------------------------------> dispatch: lambda ... o o
;                                                                                               _________________________
;


(set-car! (cdr z) 17)

; for (cdr z), at first, a new env E3 will be created to eval { z 'cdr } with initial binding z=z
;
; _____________________________________________________________________________________________________________
;
; global env: cons -------------------------------------+
;             car ---------------------------+          |
;             cdr -------------------+       |          |
;             set-car! --------+     |       |          |
;             set-cdr! --+     |     |       |          |
;             x --+      |     |     |       |          |
;             z   |      |     |     |       |          |
; ____________|___|______|_____|_____|_______|__________|_______________________________________________________
;             |   |      |     |     |  ^    |  ^   ^   |  ^                           ^                   ^
;             |   |      ........    |  |    |  |   |   |  |                           |                   |
;             |   |                  |  |    o  o   |   o  o                           |                   |
;             |   |                  |  |    |      |   |                              |                   |
;             |   |                  |  |params: z  |  params: x y                     |                   |
;             |   |                  |  |body:(z 'car) body: (define set-x! ...        |                   |
;             |   |                  |  |           |        (define set-y! ...        |                   |
;             |   |                  o  o           |        (define dispatch ...      |                   |
;             |   |              params: z          |        dispatch                  |                   |
;             |   |              body: (z 'cdr)     |                       ___________|_____________      |
;             |   |                                 |                                                      |
;             |   |                                 |                       E1: x: 1                <-+    |
;             |   |                                 |                           y: 2                  |    |
;             |   |                                 |                           set-x!: lambda ...  o o    |
;             |   |                                 |                           set-y!: lambda ...  o o    |
;             |   +---------------------------------|-------------------------> dispatch: lambda ...o o    |
;             |                                     |                       _________________________      |
;             |                                     |                                                      |
;             |                                     |                                           ___________|_____________
;             |                                     |                                            
;             |                                     |                                           E2: x: x                 <-+
;             |                                     |                                               y: x                   |
;             |                                     |                                               set-x!: lambda ...   o o
;             |                                     |                                               set-y!: lambda ...   o o
;             +-------------------------------------|---------------------------------------------> dispatch: lambda ... o o
;                                                   |                                           _________________________
;                                                   |                                                  ^
;                                          _________|___________                                _______|_________
;                                            
;                                            E3: z: z                                           E4: m: 'cdr
;                                                eval (z 'cdr), will create another env:            eval body of dispatch lambda gives var x, as ret
;                                          _____________________                                _________________
;
;
;
; for (set-car! x 17) part, a new env E5 will be created, with initial binding z=x, new-value=17
;
; _____________________________________________________________________________________________________________
;
; global env: cons -------------------------------------+
;             car ---------------------------+          |
;             cdr -------------------+       |          |
;             set-car! --------+     |       |          |
;             set-cdr! --+     |     |       |          |
;             x --+      |     |     |       |          |
;             z   |      |     |     |       |          |
; ____________|___|______|_____|_____|_______|__________|_______________________________________________________
;             |   |      |     |     |  ^    |  ^   ^   |  ^                           ^                   ^
;             |   |      ........    |  |    |  |   |   |  |                           |                   |
;             |   |                  |  |    o  o   |   o  o                           |                   |
;             |   |                  |  |    |      |   |                              |                   |
;             |   |                  |  |params: z  |  params: x y                     |                   |
;             |   |                  |  |body:(z 'car) body: (define set-x! ...        |                   |
;             |   |                  |  |           |        (define set-y! ...        |                   |
;             |   |                  o  o           |        (define dispatch ...      |                   |
;             |   |              params: z          |        dispatch                  |                   |
;             |   |              body: (z 'cdr)     |                       ___________|_____________      |
;             |   |                                 |                                                      |
;             |   |                                 |                       E1: x: 1                <-+    |
;             |   |                                 |                           y: 2                  |    |
;             |   |                                 |                           set-x!: lambda ...  o o    |
;             |   |                                 |                           set-y!: lambda ...  o o    |
;             |   +---------------------------------|-------------------------> dispatch: lambda ...o o    |
;             |                                     |                       _________________________      |
;             |                                     |                                      ^               |
;             |                                     |                                      |    ___________|_____________
;             |                                     |                                      |     
;             |                                     |                                      |    E2: x: x                 <-+
;             |                                     |                                      |        y: x                   |
;             |                                     |                                      |        set-x!: lambda ...   o o
;             |                                     |                                      |        set-y!: lambda ...   o o
;             +-------------------------------------|--------------------------------------|------> dispatch: lambda ... o o
;                                                   |                                      |    _________________________
;                                                   |                                      |
;                                          _________|___________                           |     
;                                                                                          |
;                                            E5: z: x                             _________|__________
;                                                new-value: 17 
;                                                eval: ((x 'set-car!) 17)         E6: m: 'set-car!
;                                                      x                                  eval body of lambda dispatch returns another lambda (set-x! ... and returns
;                                                will create E6:                  ____________________
;                                          _____________________                  
;
;
;
; Then E5, to eval (set-x! ... ) with 17, it will create E7, since set-x! illustrates env E1, so enclosing env of E7 is E1 like E6
;
;
; _____________________________________________________________________________________________________________
;
; global env: cons -------------------------------------+
;             car ---------------------------+          |
;             cdr -------------------+       |          |
;             set-car! --------+     |       |          |
;             set-cdr! --+     |     |       |          |
;             x --+      |     |     |       |          |
;             z   |      |     |     |       |          |
; ____________|___|______|_____|_____|_______|__________|_______________________________________________________
;             |   |      |     |     |  ^    |  ^   ^   |  ^                           ^                   ^
;             |   |      ........    |  |    |  |   |   |  |                           |                   |
;             |   |                  |  |    o  o   |   o  o                           |                   |
;             |   |                  |  |    |      |   |                              |                   |
;             |   |                  |  |params: z  |  params: x y                     |                   |
;             |   |                  |  |body:(z 'car) body: (define set-x! ...        |                   |
;             |   |                  |  |           |        (define set-y! ...        |                   |
;             |   |                  o  o           |        (define dispatch ...      |                   |
;             |   |              params: z          |        dispatch                  |                   |
;             |   |              body: (z 'cdr)     |                       ___________|_____________      |
;             |   |                                 |                                                      |
;             |   |                                 |                       E1: x: 1                <-+    |
;             |   |                                 |                           y: 2                  |    |
;             |   |                                 |                           set-x!: lambda ...  o o    |
;             |   |                                 |                           set-y!: lambda ...  o o    |
;             |   +---------------------------------|-------------------------> dispatch: lambda ...o o    |
;             |                                     |                       _________________________      |
;             |                                     |                                      ^               |
;             |                                     |                                      |    ___________|_____________
;             |                                     |                                      |     
;             |                                     |                                      |    E2: x: x                 <-+
;             |                                     |                                      |        y: x                   |
;             |                                     |                                      |        set-x!: lambda ...   o o
;             |                                     |                                      |        set-y!: lambda ...   o o
;             +-------------------------------------|--------------------------------------|------> dispatch: lambda ... o o
;                                                   |                                      |    _________________________
;                                                   |                                      |
;                                          _________|___________                           |     
;                                                                                          |
;                                            E5: z: x                            __________|_________
;                                                new-value: 17 
;                                                eval: (set-x! 17)               E7: v: 17
;                                                      x                             eval the body set x to 17
;                                                creates E7:                     ____________________
;                                          _____________________                  
;
;
; Then value of x1 in E1 changed into 17, E6 returns x, then E5 E7 become irrelevant
;
; _____________________________________________________________________________________________________________
;
; global env: cons -------------------------------------+
;             car ---------------------------+          |
;             cdr -------------------+       |          |
;             set-car! --------+     |       |          |
;             set-cdr! --+     |     |       |          |
;             x --+      |     |     |       |          |
;             z   |      |     |     |       |          |
; ____________|___|______|_____|_____|_______|__________|_______________________________________________________
;             |   |      |     |     |  ^    |  ^       |  ^                           ^                   ^
;             |   |      ........    |  |    |  |       |  |                           |                   |
;             |   |                  |  |    o  o       o  o                           |                   |
;             |   |                  |  |    |          |                              |                   |
;             |   |                  |  |params: z     params: x y                     |                   |
;             |   |                  |  |body:(z 'car) body: (define set-x! ...        |                   |
;             |   |                  |  |                    (define set-y! ...        |                   |
;             |   |                  o  o                    (define dispatch ...      |                   |
;             |   |              params: z                   dispatch                  |                   |
;             |   |              body: (z 'cdr)                             ___________|_____________      |
;             |   |                                                                                        |
;             |   |                                                         E1: x: 17               <-+    |
;             |   |                                                             y: 2                  |    |
;             |   |                                                             set-x!: lambda ...  o o    |
;             |   |                                                             set-y!: lambda ...  o o    |
;             |   +-----------------------------------------------------------> dispatch: lambda ...o o    |
;             |                                                             _________________________      |
;             |                                                                                            |
;             |                                                                                 ___________|_____________
;             |                                                                                  
;             |                                                                                 E2: x: x                 <-+
;             |                                                                                     y: x                   |
;             |                                                                                     set-x!: lambda ...   o o
;             |                                                                                     set-y!: lambda ...   o o
;             +-----------------------------------------------------------------------------------> dispatch: lambda ... o o
;                                                                                               _________________________
;                                                                                           
;


(car x)
; (car x) creates new env E8
;
; _____________________________________________________________________________________________________________
;
; global env: cons -------------------------------------+
;             car ---------------------------+          |
;             cdr -------------------+       |          |
;             set-car! --------+     |       |          |
;             set-cdr! --+     |     |       |          |
;             x --+      |     |     |       |          |
;             z   |      |     |     |       |          |
; ____________|___|______|_____|_____|_______|__________|_______________________________________________________
;             |   |      |     |     |  ^    |  ^   ^   |  ^                           ^                   ^
;             |   |      ........    |  |    |  |   |   |  |                           |                   |
;             |   |                  |  |    o  o   |   o  o                           |                   |
;             |   |                  |  |    |      |   |                              |                   |
;             |   |                  |  |params: z  |  params: x y                     |                   |
;             |   |                  |  |body:(z 'car) body: (define set-x! ...        |                   |
;             |   |                  |  |           |        (define set-y! ...        |                   |
;             |   |                  o  o           |        (define dispatch ...      |                   |
;             |   |              params: z          |        dispatch                  |                   |
;             |   |              body: (z 'cdr)     |                       ___________|_____________      |
;             |   |                                 |                                                      |
;             |   |                                 |                       E1: x: 17               <-+    |
;             |   |                                 |                           y: 2                  |    |
;             |   |                                 |                           set-x!: lambda ...  o o    |
;             |   |                                 |                           set-y!: lambda ...  o o    |
;             |   +---------------------------------|-------------------------> dispatch: lambda ...o o    |
;             |                                     |                       _________________________      |
;             |                                     |                              ^                       |
;             |                                     |                              |            ___________|_____________
;             |                                     |                              |             
;             |                                     |                              |            E2: x: x                 <-+
;             |                                     |                              |                y: x                   |
;             |                                     |                              |                set-x!: lambda ...   o o
;             |                                     |                              |                set-y!: lambda ...   o o
;             +-------------------------------------|------------------------------|--------------> dispatch: lambda ... o o
;                                                   |                              |            _________________________
;                                                   |                              |                   
;                                          _________|___________            _______|_________
;                                            
;                                            E8: z: x                        E9: m: 'cdr
;                                                eval (x 'car), creates E9       eval body of dispatch lambda gives value of binding x, which is 17 <== Q.E.D.
;                                          _____________________            _________________
;
;
