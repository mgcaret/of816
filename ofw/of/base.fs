true value of-verbose?

\ For some debug output...
: dbexec ( ... xt -  ... ) of-verbose? if execute else drop then ;
: dbcr ( - ) of-verbose? if cr then ;
: dbtype ( addr u - ) of-verbose? if type else 2drop then ;
: db" ( string<"> ) ascii " parse dbtype cr ; immediate

db" OF base"

\ OF816 constants, these should follow macros.include
binary
10000000 constant (f_immed)
01000000 constant (f_conly)
00100000 constant (f_prot)
00010000 constant (f_tempd)
00001000 constant (f_smudg)
hex

\ Reverse engineer the leading JSLs for these words

: (function) ;
defer (defer)
0 value (value)
0 constant (constant)
variable (variable)
create (create)
alias (alias) (function)
/n buffer: (buffer:)

\ Note OF816 xts are 1 less than the address of the code
\ All of these should have 0x22 in the low byte, except ; and ALIAS
\ ALIAS will have 5C in the low byte, and we maybe need to fix that...
\ in SLOF most of these are only used by the debug.fs
\ except the ones needed to support instance values
\ so most of these should be removed since no plans to implement debug.fs
' (function) 1+ @        \ ( <colon> )
' (function) 1+ /n + @ \ ( ... <semicolon> )
' (defer) 1+ @           \ ( ... <defer> )
' (value) 1+ @           \ ( ... <value> )
' (constant) 1+ @	       \ ( ... <constant> )
' (variable) 1+ @        \ ( ... <variable> )
' (create) 1+ @          \ ( ... <create> )
' (alias) 1+ @           \ ( ... <alias> )
' (buffer:) 1+ @         \ ( ... <buffer:> )

\ now clean up the test functions
forget (function)

\ and remember the constants
constant <buffer:>
constant <alias>
constant <create>
constant <variable>
constant <constant>
constant <value>
constant <defer>
constant <semicolon>
constant <colon>

: 2variable create 2 cells allot ;

/n constant cell

: cell- /n - ;

\ Dictionary helpers 
: lfa>name cell+ dup 1+ swap c@ 7f and ;
: lfa>xt lfa>name + ;
: xt>lfa begin 1- dup c@ 80 and until cell- ;
alias xt>name >name

: 4drop 2drop 2drop ;

: isdigit ( char -- true | false )
   30 39 between
;

: //  dup >r 1- + r> / ; \ division, round up

: c@+ ( adr -- c adr' )  dup c@ swap char+ ;
: 2c@ ( adr -- c1 c2 )  c@+ c@ ;
: 4c@ ( adr -- c1 c2 c3 c4 )  c@+ c@+ c@+ c@ ;
: 8c@ ( adr -- c1 c2 c3 c4 c5 c6 c7 c8 )  c@+ c@+ c@+ c@+ c@+ c@+ c@+ c@ ;

\ clever hack
defer voc-find
' search-wordlist 1+ cell+ @ to voc-find

: 0.r  0 swap <# 0 ?DO # LOOP #> type ;

CREATE $catpad 400 allot
: $cat ( str1 len1 str2 len2 -- str3 len3 )
   >r >r dup >r $catpad swap move
   r> dup $catpad + r> swap r@ move
   r> + $catpad swap ;

\ WARNING: The following $cat-space is dirty in a sense that it adds one
\ character to str1 before executing $cat.
\ The ASSUMPTION is that str1 buffer provides that extra space and it is
\ responsibility of the code owner to ensure that
: $cat-space ( str2 len2 str1 len1 -- "str1 str2" len1+len2+1 )
        2dup + bl swap c! 1+ 2swap $cat
;
: $cathex ( str len val -- str len' )
   (u.) $cat
;

: str= ( str len str len )
  2 pick over = if
    drop swap comp 0=
  else
    2drop 2drop false
  then
;

: string=ci ( str len str len )
  2 pick over = if
    drop swap cicomp 0=
  else
    2drop 2drop false
  then
;

: strdup ( str len -- dupstr len ) here over allot swap 2dup 2>r move 2r> ;

: findchar left-parse-string nip nip swap if true else drop false then ;

: find-substr ( basestr-ptr basestr-len substr-ptr substr-len -- pos )
  \ if substr-len == 0 ?
  dup 0 = IF
    \ return 0
    2drop 2drop 0 exit THEN
  \ if substr-len <= basestr-len ?
  dup 3 pick <= IF
    \ run J from 0 to "basestr-len"-"substr-len" and I from 0 to "substr-len"-1
    2 pick over - 1+ 0 DO dup 0 DO
      \ substr-ptr[i] == basestr-ptr[j+i] ?
      over i + c@ 4 pick j + i + c@ = IF
        \ (I+1) == substr-len ?
        dup i 1+ = IF
          \ return J
          2drop 2drop j unloop unloop exit THEN
      ELSE leave THEN
    LOOP LOOP
  THEN
  \ if there is no match then exit with basestr-len as return value
  2drop nip
;

: find-isubstr ( basestr-ptr basestr-len substr-ptr substr-len -- pos )
  \ if substr-len == 0 ?
  dup 0 = IF
    \ return 0
    2drop 2drop 0 exit THEN
  \ if substr-len <= basestr-len ?
  dup 3 pick <= IF
    \ run J from 0 to "basestr-len"-"substr-len" and I from 0 to "substr-len"-1
    2 pick over - 1+ 0 DO dup 0 DO
      \ substr-ptr[i] == basestr-ptr[j+i] ?
      over i + c@ lcc 4 pick j + i + c@ lcc = IF
        \ (I+1) == substr-len ?
        dup i 1+ = IF
          \ return J
          2drop 2drop j unloop unloop exit THEN
      ELSE leave THEN
    LOOP LOOP
  THEN
  \ if there is no match then exit with basestr-len as return value
  2drop nip
;

\ The following get the SLOF file system drivers to quick & dirty compile
\ no guarantees they work...

: #split ( x #bits -- lo hi )  2dup rshift dup >r swap lshift xor r> ;

\ Fake xlspit for 32-bit Forth
: xlsplit 0 ;

\ bxjoin but fail if high 4 bytes are not 0
: bxjoin bljoin bljoin abort" cannot bxjoin" bljoin ;

\ lxjoin but fail if high cell is not 0
: lxjoin abort" cannot lxjoin" ;

: x! 0 swap 2! ;
: x@ 2@ swap abort" x@ high cell not 0" ;

\ of816 is always little-endian
alias l@-le l@
alias w@-le w@
alias l!-le l!
alias w!-le w!
alias x@-le x@

\ TPM ROFLOL
: tpm-gpt-set-lba1 2drop ;
: tpm-gpt-add-entry 2drop ;


#include <of/preprocessor.fs>
