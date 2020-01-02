false CONSTANT <FALSE>
true CONSTANT <TRUE>

testing 7.3.3.1 Memory access

\ the unaligned- words are not tested here because they are
\ aliases to the standard version of the words since OF816
\ has no alignment restrictions

\ the words are tested somewhat out of order from how they
\ appear in IEEE 1275-1994 7.3.3.1

\ not tested yet: COMP, DUMP, WBFLIPS, LBFLIPS, LWFLIPS

HERE 1 ,
HERE 2 ,
CONSTANT 2ND
CONSTANT 1ST
T{ 1ST 2ND U< -> <TRUE> }T         \ HERE MUST GROW WITH ALLOT
T{ 1ST CELL+ -> 2ND }T         \ ... BY ONE CELL
T{ 1ST 1 CELLS + -> 2ND }T
T{ 1ST @ 2ND @ -> 1 2 }T
T{ 5 1ST ! -> }T
T{ 1ST @ 2ND @ -> 5 2 }T
T{ 6 2ND ! -> }T
T{ 1ST @ 2ND @ -> 5 6 }T
T{ 1ST 2@ -> 6 5 }T
T{ 2 1 1ST 2! -> }T
T{ 1ST 2@ -> 2 1 }T
T{ 1S 1ST !  1ST @ -> 1S }T      \ CAN STORE CELL-WIDE VALUE
t{ 1st off -> }t
t{ 1st @ -> <false> }t
t{ 1st on -> }t
t{ 1st @ -> <true> }t

HERE 1 C,
HERE 2 C,
CONSTANT 2NDC
CONSTANT 1STC
T{ 1STC 2NDC U< -> <TRUE> }T      \ HERE MUST GROW WITH ALLOT
T{ 1STC CHAR+ -> 2NDC }T         \ ... BY ONE CHAR
T{ 1STC 1 CHARS + -> 2NDC }T
T{ 1STC C@ 2NDC C@ -> 1 2 }T
T{ 3 1STC C! -> }T
T{ 1STC C@ 2NDC C@ -> 3 2 }T
T{ 4 2NDC C! -> }T
T{ 1STC C@ 2NDC C@ -> 3 4 }T

HERE 1 w,
HERE 2 w,
CONSTANT 2NDw
CONSTANT 1STw
T{ 1STw 2NDw U< -> <TRUE> }T      \ HERE MUST GROW WITH ALLOT
T{ 1STw wa1+ -> 2NDw }T         \ ... BY ONE CHAR
T{ 1STw 1 /w* + -> 2NDw }T
T{ 1STw w@ 2NDw w@ -> 1 2 }T
T{ 3 1STw w! -> }T
T{ 1STw w@ 2NDw w@ -> 3 2 }T
T{ 4 2NDw w! -> }T
T{ 1STw w@ 2NDw w@ -> 3 4 }T

\ test sign extension of <w@
t{ ffff 1stw w! -> }t
t{ 1stw <w@ -> -1 }t

HERE 1 l,
HERE 2 l,
CONSTANT 2NDl
CONSTANT 1STl
T{ 1STl 2NDl U< -> <TRUE> }T      \ HERE MUST GROW WITH ALLOT
T{ 1STl la1+ -> 2NDl }T         \ ... BY ONE CHAR
T{ 1STl 1 /l* + -> 2NDl }T
T{ 1STl l@ 2NDl l@ -> 1 2 }T
T{ 3 1STl l! -> }T
T{ 1STl w@ 2NDl l@ -> 3 2 }T
T{ 4 2NDl l! -> }T
T{ 1STl w@ 2NDl l@ -> 3 4 }T

ALIGN 1 ALLOT HERE ALIGN HERE 3 CELLS ALLOT
CONSTANT A-ADDR  CONSTANT UA-ADDR
T{ UA-ADDR ALIGNED -> A-ADDR }T
T{    1 A-ADDR C!  A-ADDR C@ ->    1 }T
T{ 1234 A-ADDR  !  A-ADDR  @ -> 1234 }T
T{ 123 456 A-ADDR 2!  A-ADDR 2@ -> 123 456 }T
T{ 2 A-ADDR CHAR+ C!  A-ADDR CHAR+ C@ -> 2 }T
T{ 3 A-ADDR CELL+ C!  A-ADDR CELL+ C@ -> 3 }T
T{ 1234 A-ADDR CELL+ !  A-ADDR CELL+ @ -> 1234 }T
T{ 123 456 A-ADDR CELL+ 2!  A-ADDR CELL+ 2@ -> 123 456 }T

T{ 0 1ST ! -> }T
T{ 1 1ST +! -> }T
T{ 1ST @ -> 1 }T
T{ -1 1ST +! 1ST @ -> 0 }T

CREATE FBUF 00 C, 00 C, 00 C,
CREATE SBUF 12 C, 34 C, 56 C,
: SEEBUF FBUF C@  FBUF CHAR+ C@  FBUF CHAR+ CHAR+ C@ ;

T{ FBUF 0 20 FILL -> }T
T{ SEEBUF -> 00 00 00 }T

T{ FBUF 1 20 FILL -> }T
T{ SEEBUF -> 20 00 00 }T

T{ FBUF 3 20 FILL -> }T
T{ SEEBUF -> 20 20 20 }T

T{ FBUF FBUF 3 CHARS MOVE -> }T      \ BIZARRE SPECIAL CASE
T{ SEEBUF -> 20 20 20 }T

T{ SBUF FBUF 0 CHARS MOVE -> }T
T{ SEEBUF -> 20 20 20 }T

T{ SBUF FBUF 1 CHARS MOVE -> }T
T{ SEEBUF -> 12 20 20 }T

T{ SBUF FBUF 3 CHARS MOVE -> }T
T{ SEEBUF -> 12 34 56 }T

T{ FBUF FBUF CHAR+ 2 CHARS MOVE -> }T
T{ SEEBUF -> 12 12 34 }T

T{ FBUF CHAR+ FBUF 2 CHARS MOVE -> }T
T{ SEEBUF -> 12 34 34 }T

84 CONSTANT CHARS/PAD      \ Minimum size of PAD in chars
CHARS/PAD CHARS CONSTANT AUS/PAD
: CHECKPAD  ( caddr u ch -- f )  \ f = TRUE if u chars = ch
   SWAP 0
   ?DO
      OVER I CHARS + C@ OVER <>
      IF 2DROP UNLOOP FALSE EXIT THEN
   LOOP
   2DROP TRUE
;

T{ PAD DROP -> }T
T{ 0 INVERT PAD C! -> }T
T{ PAD C@ CONSTANT MAXCHAR -> }T
T{ PAD CHARS/PAD 2DUP MAXCHAR FILL MAXCHAR CHECKPAD -> TRUE }T
T{ PAD CHARS/PAD 2DUP CHARS ERASE 0 CHECKPAD -> TRUE }T
T{ PAD CHARS/PAD 2DUP MAXCHAR FILL PAD 0 ERASE MAXCHAR CHECKPAD -> TRUE }T
T{ PAD 43 CHARS + 9 CHARS ERASE -> }T
T{ PAD 43 MAXCHAR CHECKPAD -> TRUE }T
T{ PAD 43 CHARS + 9 0 CHECKPAD -> TRUE }T
T{ PAD 52 CHARS + CHARS/PAD 52 - MAXCHAR CHECKPAD -> TRUE }T

t{ pad chars/pad 2dup blank bl checkpad -> true }t

\ Check that use of WORD and pictured numeric output do not corrupt PAD
\ Minimum size of buffers for these are 33 chars and (2*n)+2 chars respectively
\ where n is number of bits per cell

PAD CHARS/PAD ERASE
2 BASE !
MAX-UINT MAX-UINT <# #S CHAR 1 DUP HOLD HOLD #> 2DROP
DECIMAL
BL WORD 12345678123456781234567812345678 DROP
T{ PAD CHARS/PAD 0 CHECKPAD -> TRUE }T


testing 7.3.3.2 Memory allocation

\ todo: adapt alloc/free tests

t{ 100 alloc-mem debug-mem 100 free-mem -> }t


