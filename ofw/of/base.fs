true value of-verbose?

\ For some debug output...
: dbexec ( ... xt -  ... ) of-verbose? if execute else drop then ;
: dbcr ( - ) of-verbose? if cr then ;
: dbtype ( addr u - ) of-verbose? if type else 2drop then ;
: db" ( string<"> ) ascii " parse dbtype cr ; immediate

db" OF base"

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

: cell- /n - ;

\ Dictionary helpers 
: lfa>name cell+ dup 1+ swap c@ 7f and ;
: lfa>xt lfa>name + ;
: xt>lfa begin 1- dup c@ 80 and until cell- ;


: 4drop 2drop 2drop ;

: c@+ ( adr -- c adr' )  dup c@ swap char+ ;
: 4c@ ( adr -- c1 c2 c3 c4 )  c@+ c@+ c@+ c@ ;

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

#include <of/preprocessor.fs>
