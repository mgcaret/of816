\ Adapted from: https://raw.githubusercontent.com/gerryjackson/forth2012-test-suite/master/src/tester.fr

\ From: John Hayes S1I
\ Subject: tester.fr
\ Date: Mon, 27 Nov 95 13:10:09 PST  

\ (C) 1995 JOHNS HOPKINS UNIVERSITY / APPLIED PHYSICS LABORATORY
\ MAY BE DISTRIBUTED FREELY AS LONG AS THIS COPYRIGHT NOTICE REMAINS.
\ VERSION 1.2

\ 24/11/2015 Replaced Core Ext word <> with = 0=
\ 31/3/2015 Variable #ERRORS added and incremented for each error reported.
\ 22/1/09 The words { and } have been changed to T{ and }T respectively to
\ agree with the Forth 200X file ttester.fs. This avoids clashes with
\ locals using { ... } and the FSL use of } 

version1

headerless

defer >in s" ' >in" eval to >in
defer source s" ' source" eval to source

HEX

headers

\ SET THE FOLLOWING FLAG TO TRUE FOR MORE VERBOSE OUTPUT; THIS MAY
\ ALLOW YOU TO TELL WHICH TEST CAUSED YOUR SYSTEM TO HANG.
VARIABLE VERBOSE
   FALSE VERBOSE !
\   TRUE VERBOSE !

\ : EMPTY-STACK   \ ( ... -- ) EMPTY STACK: HANDLES UNDERFLOWED STACK TOO.
\    DEPTH ?DUP IF DUP 0< IF NEGATE 0 DO 0 LOOP ELSE 0 DO DROP LOOP THEN THEN ;
\ THE IEEE-1275 CLEAR word works the same but the standard does not define
\ an FCode for it...
defer EMPTY-STACK s" ' clear" eval to EMPTY-STACK

VARIABLE #ERRORS 0 #ERRORS !

: ERROR      \ ( C-ADDR U -- ) DISPLAY AN ERROR MESSAGE FOLLOWED BY
      \ THE LINE THAT HAD THE ERROR.
   CR TYPE SOURCE TYPE       \ DISPLAY LINE CORRESPONDING TO ERROR
   EMPTY-STACK               \ THROW AWAY EVERY THING ELSE
   #ERRORS @ 1 + #ERRORS !
\   QUIT  \ *** Uncomment this line to QUIT on an error
;

VARIABLE ACTUAL-DEPTH         \ STACK RECORD
CREATE ACTUAL-RESULTS 20 CELLS ALLOT

: T{      \ ( -- ) SYNTACTIC SUGAR.
   ;

\ FCode tokenizer will issue a warning for this
\ it can be ignored
: ->      \ ( ... -- ) RECORD DEPTH AND CONTENT OF STACK.
   DEPTH DUP ACTUAL-DEPTH !      \ RECORD DEPTH
   ?DUP IF            \ IF THERE IS SOMETHING ON STACK
      0 DO ACTUAL-RESULTS I CELLS + ! LOOP \ SAVE THEM
   THEN ;

: }T      \ ( ... -- ) COMPARE STACK (EXPECTED) CONTENTS WITH SAVED
      \ (ACTUAL) CONTENTS.
   DEPTH ACTUAL-DEPTH @ = IF      \ IF DEPTHS MATCH
      DEPTH ?DUP IF         \ IF THERE IS SOMETHING ON THE STACK
         0  DO            \ FOR EACH STACK ITEM
           ACTUAL-RESULTS I CELLS + @   \ COMPARE ACTUAL WITH EXPECTED
           = 0= IF S" INCORRECT RESULT: " ERROR LEAVE THEN
         LOOP
      THEN
   ELSE               \ DEPTH MISMATCH
      S" WRONG NUMBER OF RESULTS: " ERROR
   THEN ;

: TESTING   \ ( -- ) TALKING COMMENT.
  SOURCE VERBOSE @
   IF DUP >R TYPE CR R> >IN !
   ELSE >IN ! DROP [CHAR] * EMIT
   THEN ;

fcode-end

