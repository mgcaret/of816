testing 7.3.9.1 Defining words

T{ 123 CONSTANT X123 -> }T
T{ X123 -> 123 }T
T{ : EQU CONSTANT ; -> }T
T{ X123 EQU Y123 -> }T
T{ Y123 -> 123 }T

t{ 123 456 2CONSTANT X123456 -> }t
t{ X123456 -> 123 456 }t
t{ : 2EQU 2CONSTANT ; -> }t
t{ X123456 2EQU Y123456 -> }t
t{ Y123456 -> 123 456 }t

T{ 111 VALUE VAL1 -999 VALUE VAL2 -> }T
T{ VAL1 -> 111 }T
T{ VAL2 -> -999 }T
T{ 222 TO VAL1 -> }T
T{ VAL1 -> 222 }T
T{ : VD1 VAL1 ; -> }T
T{ VD1 -> 222 }T
T{ : VD2 TO VAL2 ; -> }T
T{ VAL2 -> -999 }T
T{ -333 VD2 -> }T
T{ VAL2 -> -333 }T
T{ VAL1 -> 222 }T
T{ 123 VALUE VAL3 IMMEDIATE VAL3 -> 123 }T
T{ : VD3 VAL3 LITERAL ; VD3 -> 123 }T

T{ VARIABLE V1 -> }T
T{ 123 V1 ! -> }T
T{ V1 @ -> 123 }T

T{ 8 BUFFER: BUF:TEST -> }T
T{ BUF:TEST DUP ALIGNED = -> TRUE }T
T{ 111 BUF:TEST ! 222 BUF:TEST CELL+ ! -> }T
T{ BUF:TEST @ BUF:TEST CELL+ @ -> 111 222 }T

t{ : al1 123 ; -> }t
t{ alias al2 al1 -> }t
t{ al2 -> al1 }t

t{ defer df1 -> }t
t{ ' true to df1 -> }t
t{ ' df1 behavior -> ' true }t
t{ df1 -> true }t
t{ ' false to df1 -> }t
t{ ' df1 behavior -> ' false }t
t{ df1 -> false }t

t{ struct -> 0 }t \ is syntactic sugar for zero
t{ struct 2 field fld1 1 field fld2 -> 3 }t
t{ 0 fld1 -> 0 }t
t{ 0 fld2 -> 2 }t

T{ : NOP : POSTPONE ; ; -> }T
T{ NOP NOP1 NOP NOP2 -> }T
T{ NOP1 -> }T
T{ NOP2 -> }T

T{ : DOES1 DOES> @ 1 + ; -> }T
T{ : DOES2 DOES> @ 2 + ; -> }T
T{ CREATE CR1 -> }T
T{ CR1 -> HERE }T
T{ ' CR1 >BODY -> HERE }T
T{ 1 , -> }T
T{ CR1 @ -> 1 }T
T{ DOES1 -> }T
T{ CR1 -> 2 }T
T{ DOES2 -> }T
T{ CR1 -> 3 }T

T{ : WEIRD: CREATE DOES> 1 + DOES> 2 + ; -> }T
T{ WEIRD: W1 -> }T
T{ ' W1 >BODY -> HERE }T
T{ W1 -> HERE 1 + }T
T{ W1 -> HERE 2 + }T

\ todo: $create (but if CREATE works, $CREATE does as well)

: forgetme1 ;
: forgetme2 ;
: forgetme3 ;
t{ forget forgetme3 s" forgetme3" $find nip nip -> 0 }t
t{ forget forgetme1 s" forgetme2" $find nip nip s" forgetme1" $find nip nip -> 0 0 }t

testing 7.3.9.2 Dictionary commands

testing 7.3.9.2.1 Data space allocation

\ also tested in 7.3.3:  here allot align c, w, l, ,

t{ create da1 -> }t
t{ here 0 c, ca1+ -> here }t
t{ here 0 w, wa1+ -> here }t
t{ here 0 l, la1+ -> here }t
t{ here 0 , na1+ -> here }t
t{ here align -> here }t      \ OF816 has no alignment restrictions
t{ 0 c, here align -> here }t \ OF816 has no alignment restrictions
t{ here 2 cells allot 2 na+ -> here }t

testing 7.3.9.2.2 Immediate words

T{ : GT1 123 ; -> }T
T{ ' GT1 EXECUTE -> 123 }T
T{ : GT2 ['] GT1 ; IMMEDIATE -> }T
T{ GT2 EXECUTE -> 123 }T
HERE 3 C, CHAR G C, CHAR T C, CHAR 1 C, CONSTANT GT1STRING
HERE 3 C, CHAR G C, CHAR T C, CHAR 2 C, CONSTANT GT2STRING
T{ GT1STRING FIND -> ' GT1 -1 }T
T{ GT2STRING FIND -> ' GT2 1 }T
( HOW TO SEARCH FOR NON-EXISTENT WORD? )
T{ : GT3 GT2 LITERAL ; -> }T
T{ GT3 -> ' GT1 }T
T{ GT1STRING COUNT -> GT1STRING CHAR+ 3 }T

T{ : GT4 POSTPONE GT1 ; IMMEDIATE -> }T
T{ : GT5 GT4 ; -> }T
T{ GT5 -> 123 }T
T{ : GT6 345 ; IMMEDIATE -> }T
T{ : GT7 POSTPONE GT6 ; -> }T
T{ GT7 -> 345 }T

T{ : GT8 STATE @ ; IMMEDIATE -> }T
T{ GT8 -> 0 }T
T{ : GT9 GT8 LITERAL ; -> }T
T{ GT9 0= -> false }T

variable csr
1 csr !
t{ : cst [ state @ csr ! ] ; -> }t
t{ csr @ -> 0 }t

: ctestword compile true ;
create comptest
ctestword
\ covers:compile
t{ comptest @ -> ' true }t
t{ ' false compile, comptest 1 na+ @ -> ' false }t
t{ [compile] hex comptest 2 na+ @ -> ' hex }t


testing 7.3.9.2.3 Dictionary search

variable wxt
t{ : wxtt ['] find  wxt ! ; -> }t
t{ wxtt wxt @ -> ' find }t
t{ bl word find find -> ' find -1 }t        \ found
t{ bl word postpone find -> ' postpone 1 }t \ found immediate
t{ bl word supercalafrag find nip -> 0 }t   \ not found

testing 7.3.9.2.4 Miscellaneous dictionary

\ to and behavior for defer tested above
\ to for value tested above
\ >body tested above

create bd1
t{ ' bd1 >body body> -> ' bd1 }t

variable rrv1
t{ : rr1 recursive [ bl word rr1 find drop rrv1 ! ] ; -> }t
t{ rrv1 @ -> ' rr1 }t
t{ : rr2 [ bl word rr2 find nip rrv1 ! ] ; -> }t
t{ rrv1 @ -> 0 }t

\ recurse tested in 7.3.8

\ existence checks only (todo)
t{ ' forth 0= -> false }t
t{ ' environment? 0= -> false }t

testing 7.3.9.2.4 Assembler

\ existence checks only (todo)
t{ ' code 0= -> false }t
t{ ' label 0= -> false }t
t{ ' c; 0= -> false }t
t{ ' end-code 0= -> false }t

