testing 7.3.8.1 Conditional branches

T{ : GI1 IF 123 THEN ; -> }T
T{ : GI2 IF 123 ELSE 234 THEN ; -> }T
T{ 0 GI1 -> }T
T{ 1 GI1 -> 123 }T
T{ -1 GI1 -> 123 }T
T{ 0 GI2 -> 234 }T
T{ 1 GI2 -> 123 }T
T{ -1 GI1 -> 123 }T

testing 7.3.8.2 Case statement

: CS1 CASE 1 OF 111 ENDOF
           2 OF 222 ENDOF
           3 OF 333 ENDOF
           >R 999 R>
      ENDCASE
;

T{ 1 CS1 -> 111 }T
T{ 2 CS1 -> 222 }T
T{ 3 CS1 -> 333 }T
T{ 4 CS1 -> 999 }T

\ Nested CASE's

: CS2 >R CASE -1 OF CASE R@ 1 OF 100 ENDOF
                            2 OF 200 ENDOF
                           >R -300 R>
                    ENDCASE
                 ENDOF
              -2 OF CASE R@ 1 OF -99  ENDOF
                            >R -199 R>
                    ENDCASE
                 ENDOF
                 >R 299 R>
         ENDCASE R> DROP
;

T{ -1 1 CS2 ->  100 }T
T{ -1 2 CS2 ->  200 }T
T{ -1 3 CS2 -> -300 }T
T{ -2 1 CS2 -> -99  }T
T{ -2 2 CS2 -> -199 }T
T{  0 2 CS2 ->  299 }T

\ Boolean short circuiting using CASE

: CS3  ( N1 -- N2 )
   CASE 1- FALSE OF 11 ENDOF
        1- FALSE OF 22 ENDOF
        1- FALSE OF 33 ENDOF
        44 SWAP
   ENDCASE
;

T{ 1 CS3 -> 11 }T
T{ 2 CS3 -> 22 }T
T{ 3 CS3 -> 33 }T
T{ 9 CS3 -> 44 }T

\ Empty CASE statements with/without default

T{ : CS4 CASE ENDCASE ; 1 CS4 -> }T
T{ : CS5 CASE 2 SWAP ENDCASE ; 1 CS5 -> 2 }T
T{ : CS6 CASE 1 OF ENDOF 2 ENDCASE ; 1 CS6 -> }T
T{ : CS7 CASE 3 OF ENDOF 2 ENDCASE ; 1 CS7 -> 1 }T


testing 7.3.8.3 Conditional loops

T{ : GI3 BEGIN DUP 5 < WHILE DUP 1+ REPEAT ; -> }T
T{ 0 GI3 -> 0 1 2 3 4 5 }T
T{ 4 GI3 -> 4 5 }T
T{ 5 GI3 -> 5 }T
T{ 6 GI3 -> 6 }T

T{ : GI4 BEGIN DUP 1+ DUP 5 > UNTIL ; -> }T
T{ 3 GI4 -> 3 4 5 6 }T
T{ 5 GI4 -> 5 6 }T
T{ 6 GI4 -> 6 7 }T

T{ : GI5 BEGIN DUP 2 >
         WHILE DUP 5 < WHILE DUP 1+ REPEAT 123 ELSE 345 THEN ; -> }T
T{ 1 GI5 -> 1 345 }T
T{ 2 GI5 -> 2 345 }T
T{ 3 GI5 -> 3 4 5 123 }T
T{ 4 GI5 -> 4 5 123 }T
T{ 5 GI5 -> 5 123 }T

T{ : GI6 ( N -- 0,1,..N ) DUP IF DUP >R 1- RECURSE R> THEN ; -> }T
T{ 0 GI6 -> 0 }T
T{ 1 GI6 -> 0 1 }T
T{ 2 GI6 -> 0 1 2 }T
T{ 3 GI6 -> 0 1 2 3 }T
T{ 4 GI6 -> 0 1 2 3 4 }T


testing 7.3.8.4 Counted loops

T{ : GD1 DO I LOOP ; -> }T
T{ 4 1 GD1 -> 1 2 3 }T
T{ 2 -1 GD1 -> -1 0 1 }T
T{ MID-UINT+1 MID-UINT GD1 -> MID-UINT }T

T{ : GD2 DO I -1 +LOOP ; -> }T
T{ 1 4 GD2 -> 4 3 2 1 }T
T{ -1 2 GD2 -> 2 1 0 -1 }T
T{ MID-UINT MID-UINT+1 GD2 -> MID-UINT+1 MID-UINT }T

T{ : GD3 DO 1 0 DO J LOOP LOOP ; -> }T
T{ 4 1 GD3 -> 1 2 3 }T
T{ 2 -1 GD3 -> -1 0 1 }T
T{ MID-UINT+1 MID-UINT GD3 -> MID-UINT }T

T{ : GD4 DO 1 0 DO J LOOP -1 +LOOP ; -> }T
T{ 1 4 GD4 -> 4 3 2 1 }T
T{ -1 2 GD4 -> 2 1 0 -1 }T
T{ MID-UINT MID-UINT+1 GD4 -> MID-UINT+1 MID-UINT }T

T{ : GD5 123 SWAP 0 DO I 4 > IF DROP 234 LEAVE THEN LOOP ; -> }T
T{ 1 GD5 -> 123 }T
T{ 5 GD5 -> 123 }T
T{ 6 GD5 -> 234 }T

t{ : gd7 1 0 do true ?leave false loop ; -> }t
t{ gd7 -> }t


testing 7.3.8.5 Other control flow commands

: GE1 S" 123" ; IMMEDIATE
: GE2 S" 123 1+" ; IMMEDIATE
: GE3 S" : GE4 345 ;" ;
: GE5 EVALUATE ; IMMEDIATE

T{ GE1 EVALUATE -> 123 }T         ( TEST EVALUATE IN INTERP. STATE )
t{ ge1 EVAL -> 123 }t             ( EVAL is an alias of EVALUATE )
T{ GE2 EVALUATE -> 124 }T
T{ GE3 EVALUATE -> }T
T{ GE4 -> 345 }T

T{ : GE6 GE1 GE5 ; -> }T         ( TEST EVALUATE IN COMPILE STATE )
T{ GE6 -> 123 }T
T{ : GE7 GE2 GE5 ; -> }T
T{ GE7 -> 124 }T

T{ : GT1 123 ; -> }T
T{ ' GT1 EXECUTE -> 123 }T

\ EXIT
T{ : GD6  ( PAT: T{0 0},{0 0}{1 0}{1 1},{0 0}{1 0}{1 1}{2 0}{2 1}{2 2} )
   0 SWAP 0 DO
      I 1+ 0 DO I J + 3 = IF I UNLOOP I UNLOOP EXIT THEN 1+ LOOP
    LOOP ; -> }T
T{ 1 GD6 -> 1 }T
T{ 2 GD6 -> 3 }T
T{ 3 GD6 -> 4 1 2 }T

testing 7.3.8.6 Error handling

\ not really tested:
t{ ' quit 0> -> true }t

DECIMAL

: T1 9 ;
: C1 1 2 3 ['] T1 CATCH ;
T{ C1 -> 1 2 3 9 0 }T         \ No THROW executed

: T2 8 0 THROW ;
: C2 1 2 ['] T2 CATCH ;
T{ C2 -> 1 2 8 0 }T            \ 0 THROW does nothing

: T3 7 8 9 99 THROW ;
: C3 1 2 ['] T3 CATCH ;
T{ C3 -> 1 2 99 }T            \ Restores stack to CATCH depth

: T4 1- DUP 0> IF RECURSE ELSE 999 THROW -222 THEN ;
: C4 3 4 5 10 ['] T4 CATCH -111 ;
T{ C4 -> 3 4 5 0 999 -111 }T   \ Test return stack unwinding

: T5 2DROP 2DROP 9999 THROW ;
: C5 1 2 3 4 ['] T5 CATCH            \ Test depth restored correctly
   DEPTH >R DROP 2DROP 2DROP R> ;   \ after stack has been emptied
T{ C5 -> 5 }T

-1  CONSTANT EXC_ABORT
-2  CONSTANT EXC_ABORT"
-13 CONSTANT EXC_UNDEF
: T6 ABORT ;

\ The 77 in T10 is necessary for the second ABORT" test as the data stack
\ is restored to a depth of 2 when THROW is executed. The 77 ensures the top
\ of stack value is known for the results check

: T10 77 SWAP ABORT" This should not be displayed" ;
: C6 CATCH
   >R   R@ EXC_ABORT  = IF 11
   ELSE R@ EXC_ABORT" = IF 12
   ELSE R@ EXC_UNDEF  = IF 13
   THEN THEN THEN R> DROP
;

T{ 1 2 ' T6 C6  -> 1 2 11 }T     \ Test that ABORT is caught
T{ 3 0 ' T10 C6 -> 3 77 }T       \ ABORT" does nothing
T{ 4 5 ' T10 C6 -> 4 77 12 }T    \ ABORT" caught, no message

: T7 S" 333 $$QWEQWEQWERT$$ 334" EVALUATE 335 ;
: T8 S" 222 T7 223" EVALUATE 224 ;
: T9 S" 111 112 T8 113" EVALUATE 114 ;

T{ 6 7 ' T9 C6 3 -> 6 7 13 3 }T         \ Test unlinking of sources

\ Housekeeping to tell coverage tool that we got these
t{ ' ABORT 0= -> false }t
t{ ' ABORT" 0= -> false }t
