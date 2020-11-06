
also forth definitions

true value of-verbose?

: dbexec ( ... xt -  ... ) of-verbose? if execute else drop then ;
: dbcr ( - ) of-verbose? if cr then ;
: dbtype ( addr u - ) of-verbose? if type else 2drop then ;
: db" ( string<"> ) ascii " parse dbtype cr ; immediate

db" OF base"

: (function) ;
defer (defer)
0 value (value)
0 constant (constant)
variable (variable)
create (create)
alias (alias) (function)
/n buffer: (buffer:)

' (function) 1+ @        \ ( <colon> )
' (function) 1+ /n + @ \ ( ... <semicolon> )
' (defer) 1+ @           \ ( ... <defer> )
' (value) 1+ @           \ ( ... <value> )
' (constant) 1+ @	       \ ( ... <constant> )
' (variable) 1+ @        \ ( ... <variable> )
' (create) 1+ @          \ ( ... <create> )
' (alias) 1+ @           \ ( ... <alias> )
' (buffer:) 1+ @         \ ( ... <buffer:> )

forget (function)

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

: lfa>name cell+ dup 1+ swap c@ 7f and ;
: lfa>xt lfa>name + ;
: xt>lfa begin 1- dup c@ 80 and until cell- ;

: 4drop 2drop 2drop ;

: c@+ ( adr -- c adr' )  dup c@ swap char+ ;
: 4c@ ( adr -- c1 c2 c3 c4 )  c@+ c@+ c@+ c@ ;

defer voc-find
' search-wordlist 1+ cell+ @ to voc-find

: 0.r  0 swap <# 0 ?DO # LOOP #> type ;

CREATE $catpad 400 allot
: $cat ( str1 len1 str2 len2 -- str3 len3 )
>r >r dup >r $catpad swap move
r> dup $catpad + r> swap r@ move
r> + $catpad swap ;

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

: ([IF])
BEGIN
BEGIN parse-word dup 0= WHILE
2drop refill
REPEAT

2dup s" [IF]" string=ci IF 1 throw THEN
2dup s" [ELSE]" string=ci IF 2 throw THEN
2dup s" [THEN]" string=ci IF 3 throw THEN
s" \" str= IF ['] \ execute THEN
AGAIN
;

: [IF] ( flag -- )
IF exit THEN
1 BEGIN
['] ([IF]) catch 
CASE
1 OF 1+ ENDOF
2 OF dup 1 = if 1- then ENDOF
3 OF 1- ENDOF
ENDCASE
dup 0 <=
UNTIL drop
; immediate

: [ELSE] 0 [COMPILE] [IF] ; immediate
: [THEN] ; immediate

: [IFDEF] parse-word $search dup 0<> if nip then postpone [IF] ; immediate
: [IFNDEF] parse-word $search dup 0<> if nip then 0= postpone [IF] ; immediate

hex

: $banner
." Open Firmware for OF816 by Michael Guidero" cr
." Portions (c) IBM Corp. (https://github.com/aik/SLOF)"
;

db" OF words and values"

810000 value load-base
0 0 2value boot-device
0 0 2value boot-file
0 0 2value diag-device
0 0 2value diag-file
0 0 2value boot-command
false value diag-switch?
: diagnostic-mode? diag-switch? ;
false value auto-boot?

0 0 2value use-nvramrc
false value use-nvramrc?

0 0 2value input-device
0 0 2value output-device
variable stdin
variable stdout
d# 80 value screen-#columns
d# 25 value screen-#rows

0 value security-mode
0 0 2value security-password
0 value security-#badlogins

0 value selftest-#megs

false value $did-banner?
false value oem-logo?
0 0 2value oem-logo
false value oem-banner?
0 0 2value oem-banner

: help ." Please visit https://github.com/mgcaret/of816 " cr ;

: (unsup) ." (unsup) feature" cr d# -21 throw ;

: boot (unsup) ;
: setenv (unsup) ;
: $setenv (unsup) ;
: printenv (unsup) ;
: set-default (unsup) ;
: set-defaults (unsup) ;
: nodefault-butes (unsup) ;

: nvedit (unsup) ;
: nvstore (unsup) ;
: nvquit (unsup) ;
: nvrecover (unsup) ;
: nvrun (unsup) ;

: install-console ( unsup ) ;
: input (unsup) ;
: output (unsup) ;
: io (unsup) ;

: password (unsup) ;

: test parse-word 2drop ;
: test-all parse-word 2drop ;

: callback (unsup) ;
: $callback (unsup) ;

: banner oem-banner? if oem-banner type else $banner then cr true to $did-banner? ;
: suppress-banner true to $did-banner? ;

db" OF device node support (c) IBM"

false VALUE debug-find-component?

VARIABLE device-tree
VARIABLE current-node
: get-node  current-node @ dup 0= ABORT" No active device tree node" ;

STRUCT
/n FIELD node>peer
/n FIELD node>parent
/n FIELD node>child
/n FIELD node>properties \ points to wid (grep wid>names)
/n FIELD node>words
/n FIELD node>instance-template
/n FIELD node>instance-size
/n FIELD node>space?
/n FIELD node>space
/n FIELD node>addr1
/n FIELD node>addr2
/n FIELD node>addr3
constant (node-size)

: find-method ( str len phandle -- false | xt true )
node>words @ voc-find dup IF true THEN ;

db" OF instance support (c) IBM"

0 VALUE my-self

100 CONSTANT max-instance-size \ MAG: originally 400

STRUCT
/n FIELD instance>node
/n FIELD instance>parent
/n FIELD instance>args
/n FIELD instance>args-len
/n FIELD instance>size
/n FIELD instance>#units
/n FIELD instance>unit1          \ For instance-specific "my-unit"
/n FIELD instance>unit2
/n FIELD instance>unit3
/n FIELD instance>unit4
CONSTANT /instance-header

: >instance  ( offset -- myself+offset )
my-self 0= ABORT" No instance!"
dup my-self instance>size @ >= ABORT" Instance access out of bounds!"
my-self +
;

: (create-instance-var) ( initial-value -- )
get-node
dup node>instance-size @ cell+ max-instance-size
>= ABORT" Instance is bigger than max-instance-size!"
dup node>instance-template @      ( iv phandle tmp-ih )
swap node>instance-size dup @     ( iv tmp-ih *instance-size instance-size )
dup ,                             \ compile current instance ptr
swap 1 cells swap +!              ( iv tmp-ih instance-size )
+ !
;

: create-instance-var ( "name" initial-value -- )
CREATE (create-instance-var) PREVIOUS
;

: (create-instance-buf) ( buffersize -- )
aligned                               \ align size to multiples of cells
dup get-node node>instance-size @ +   ( buffersize' newinstancesize )
max-instance-size > ABORT" Instance is bigger than max-instance-size!"
get-node node>instance-template @  get-node node>instance-size @ +
over erase                            \ clear according to IEEE 1275
get-node node>instance-size @         ( buffersize' old-instance-size )
dup ,                                 \ compile current instance ptr
+ get-node node>instance-size !       \ store new size
;

: create-instance-buf ( "name" buffersize -- )
CREATE (create-instance-buf) PREVIOUS
;

VOCABULARY instance-words  ALSO instance-words DEFINITIONS

: VARIABLE  0 create-instance-var DOES> [ here ] @ >instance ;
: VALUE       create-instance-var DOES> [ here ] @ >instance @ ;
: DEFER     0 create-instance-var DOES> [ here ] @ >instance @ execute ;
: BUFFER:     create-instance-buf DOES> [ here ] @ >instance ;

PREVIOUS DEFINITIONS

CONSTANT <instancebuffer>
CONSTANT <instancedefer>
CONSTANT <instancevalue>
CONSTANT <instancevariable>

: (instance?) ( xt -- xt true|false )
dup 1+ @ dup ff and
22 = IF
8 rshift 3 na+ @ ['] >instance =
ELSE
drop false
THEN
;

: (doito) ( value R:*CFA -- )
r> cell+ dup >r 1+ ( MAG )
@ cell+ cell+ @ >instance !
;
' (doito) CONSTANT <(doito)>

: to ( value wordname<> -- )
' (instance?)
IF ( value xt )
state @ IF
['] (doito) , , \ compile mode handling instance value
ELSE
cell+ cell+ @ >instance ! \ interp mode instance value
THEN EXIT
ELSE
state @ IF ( value xt )
postpone literal compile (to)
ELSE
(to)
THEN
THEN
; IMMEDIATE

: behavior  ( defer-xt -- contents-xt )
dup cell+ @ <instancedefer> = IF   \ Is defer-xt an INSTANCE DEFER ?
2 cells + @ >instance @
ELSE
behavior
THEN
;

: INSTANCE  ALSO instance-words ;

: my-parent  my-self instance>parent @ ;
: my-args    my-self instance>args 2@ swap ;

: set-my-args   ( old-addr len -- )
dup alloc-mem                   \ allocate space for new args ( old-addr len new-addr )
2dup my-self instance>args 2!   \ write into instance struct  ( old-addr len new-addr )
swap move                       \ and copy the args           ( )
;

: create-instance-data ( -- instance )
get-node dup node>instance-template @    ( phandle instance-template )
swap node>instance-size @                ( instance-template instance-size )
dup >r
dup alloc-mem dup >r swap move r>        ( instance )
dup instance>size r> swap !              \ Store size for destroy-instance
dup instance>#units 0 swap !             \ Use node unit by default
;
: create-instance ( -- )
my-self create-instance-data
dup to my-self instance>parent !
get-node my-self instance>node !
;

: destroy-instance ( instance -- )
dup instance>args @ ?dup IF               \ Free instance args?
over instance>args-len @  free-mem
THEN
dup instance>size @  free-mem
;

: ihandle>phandle ( ihandle -- phandle )
dup 0= ABORT" no current instance" instance>node @
;

: push-my-self ( ihandle -- )  r> my-self >r >r to my-self ;
: pop-my-self ( -- )  r> r> to my-self >r ;
: call-package  push-my-self execute pop-my-self ;
: $call-static ( ... str len node -- ??? )
find-method IF execute ELSE -1 throw THEN
;

: $call-my-method  ( str len -- )
my-self ihandle>phandle $call-static
;

: $call-method  ( str len ihandle -- )
push-my-self
['] $call-my-method CATCH ?dup IF
pop-my-self THROW
THEN
pop-my-self
;

0 VALUE calling-child

: $call-parent
my-self ihandle>phandle TO calling-child
my-parent $call-method
0 TO calling-child
;

db" OF - back to device tree"

: create-node ( parent -- new )
max-instance-size alloc-mem        ( parent instance-mem )
dup max-instance-size erase >r     ( parent  R: instance-mem )
align wordlist >r $empty-wl >r      ( parent  R: instance-mem wl wl )
here                               ( parent new  R: instance-mem wl wl )
0 , swap , 0 ,                     \ Set node>peer, node>parent & node>child
r> , r> ,                          \ Set node>properties & node>words to wl
r> , /instance-header ,            \ Set instance-template & instance-size
FALSE , 0 ,                        \ Set node>space? and node>space
0 , 0 , 0 ,                        \ Set node>addr*
;

: peer    node>peer   @ ;
: parent  node>parent @ ;
: child   node>child  @ ;
: peer  dup IF peer ELSE drop device-tree @ THEN ;

: link ( new head -- ) \ link a new node at the end of a linked list
BEGIN dup @ WHILE @ REPEAT ! ;
: link-node ( parent child -- )
swap dup IF node>child link ELSE drop device-tree ! THEN ;

: set-node ( phandle -- )
current-node @ IF previous THEN
dup current-node !
?dup IF node>words @ also context ! THEN
definitions ;
: get-parent  get-node parent ;

: new-node ( -- phandle ) \ active node becomes new node's parent;
current-node @ dup create-node
tuck link-node dup set-node ;

: finish-node ( -- )
get-node parent set-node
;

: device-end ( -- )  0 set-node ;

CREATE $indent 100 allot  VARIABLE indent 0 indent !

db" OF properties (c) IBM" 

true value encode-first?

: decode-int  over >r 4 /string r> 4c@ swap 2swap swap bljoin ;
: decode-string ( prop-addr1 prop-len1 -- prop-addr2 prop-len2 str len )
dup 0= IF 2dup EXIT THEN \ string properties with zero length
over BEGIN dup c@ 0= IF 1+ -rot swap 2 pick over - rot over - -rot 1-
EXIT THEN 1+ AGAIN ;

: prune ( name len -- ) context @ search-wordlist 0= if exit then
dup c@ 20 and if
drop \ protected
else
dup c@ 8 or swap c!
then
;

: set-property ( data dlen name nlen phandle -- )
true to encode-first?
get-current >r  node>properties @ set-current
2dup prune $2VALUE ( $2CONSTANT ) r> set-current ;
: delete-property ( name nlen -- )
get-node get-current >r  node>properties @ set-current
prune r> set-current ;
: property ( data dlen name nlen -- )  get-node set-property ;
: get-property ( str len phandle -- true | data dlen false )
?dup 0= IF cr cr cr ." get-property for " type ."  on zero phandle"
cr cr true EXIT THEN
node>properties @ voc-find dup IF execute false ELSE drop true THEN ;
: get-package-property ( str len phandle -- true | data dlen false )
get-property ;
: get-my-property ( str len -- true | data dlen false )
my-self ihandle>phandle get-property ;
: get-parent-property ( str len -- true | data dlen false )
my-parent ihandle>phandle get-property ;

: get-inherited-property ( str len -- true | data dlen false )
my-self ihandle>phandle
BEGIN
3dup get-property 0= IF
rot drop rot drop rot drop false EXIT
THEN
parent dup 0= IF
3drop true EXIT
THEN
AGAIN
;

20 CONSTANT indent-prop

: .prop-int ( str len -- )
space
400 min 0
?DO
i over + dup                                 ( str act-addr act-addr )
c@ 2 0.r 1+ dup c@ 2 0.r 1+ dup c@ 2 0.r 1+ c@ 2 0.r ( str )
i c and c = IF                           \ check for multipleof 16 bytes
cr indent @ indent-prop + 1+ 0        \ linefeed + indent
DO
space                              \ print spaces
LOOP
ELSE
space space                           \ print two spaces
THEN
4 +LOOP
drop
;

: .prop-bytes ( str len -- )
2dup -4 and .prop-int                       ( str len )

dup 3 and dup IF                            ( str len len%4 )
>r -4 and + r>                           ( str' len%4 )
bounds                                   ( str' str'+len%4 )
DO
i c@ 2 0.r                            \ Print last 3 bytes
LOOP
ELSE
3drop
THEN
;

: .prop-string ( str len )
2dup space type
cr indent @ indent-prop + 0 DO space LOOP   \ Linefeed
.prop-bytes
;

: .propbytes ( xt -- )
execute dup
IF
over cell- @ execute
ELSE
2drop
THEN
;

: .property ( lfa -- )
dup cr indent @ 0 ?do space loop
lfa>name 2dup type nip
indent-prop swap -
dup 0< IF drop 0 THEN 0 ?do space loop
lfa>xt .propbytes
;

: (.properties) ( phandle -- )
node>properties @ @ BEGIN dup WHILE dup .property @ REPEAT drop ;
: .properties ( -- )
get-node (.properties) ;

: next-property ( str len phandle -- false | str' len' true )
?dup 0= IF device-tree @ THEN  \ XXX: is this line required?
node>properties @
>r 2dup 0= swap 0= or IF 2drop r> @ ELSE r> voc-find xt>lfa @ THEN
dup IF lfa>name true THEN ;

: encode-start ( -- prop 0 )
['] .prop-int compile,
false to encode-first?
here 0
;

: encode-int ( val -- prop prop-len )
encode-first? IF
['] .prop-int compile,             \ Execution token for print
false to encode-first?
THEN
here swap lbsplit c, c, c, c, /l
;
: encode-bytes ( str len -- prop-addr prop-len )
encode-first? IF
['] .prop-bytes compile,           \ Execution token for print
false to encode-first?
THEN
here over 2dup 2>r allot swap move 2r>
;
: encode-string ( str len -- prop-addr prop-len )
encode-first? IF
['] .prop-string compile,          \ Execution token for print
false to encode-first?
THEN
encode-bytes 0 c, char+
;

: encode+ ( prop1-addr prop1-len prop2-addr prop2-len -- prop-addr prop-len )
nip + ;
: encode-int+  encode-int encode+ ;

: device-name [: ." Device name: " 2dup type cr ;] dbexec encode-string s" name"        property ;
: device-type  encode-string s" device_type" property ;
: model        encode-string s" model"       property ;
: compatible   encode-string s" compatible"  property ;

db" OF - back to device tree"

: #address-cells  s" #address-cells" rot parent get-property
ABORT" parent doesn't have a #address-cells property!"
decode-int nip nip
;

: my-#address-cells  ( -- #address-cells )
get-node #address-cells
;

: child-#address-cells  ( -- #address-cells )
s" #address-cells" get-node get-property
ABORT" node doesn't have a #address-cells property!"
decode-int nip nip
;

: child-#size-cells  ( -- #address-cells )
s" #size-cells" get-node get-property
ABORT" node doesn't have a #size-cells property!"
decode-int nip nip
;

: encode-phys  ( phys.hi ... phys.low -- prop len )
encode-first?  IF  encode-start  ELSE  here 0  THEN
my-#address-cells 0 ?DO rot encode-int+ LOOP
;

: encode-child-phys  ( phys.hi ... phys.low -- prop len )
encode-first?  IF  encode-start  ELSE  here 0  THEN
child-#address-cells 0 ?DO rot encode-int+ LOOP
;

: encode-child-size  ( size.hi ... size.low -- prop len )
encode-first? IF  encode-start  ELSE  here 0  THEN
child-#size-cells 0 ?DO rot encode-int+ LOOP
;

: decode-phys
my-#address-cells BEGIN dup WHILE 1- >r decode-int r> swap >r REPEAT drop
my-#address-cells BEGIN dup WHILE 1- r> swap REPEAT drop ;
: decode-phys-and-drop
my-#address-cells BEGIN dup WHILE 1- >r decode-int r> swap >r REPEAT 3drop
my-#address-cells BEGIN dup WHILE 1- r> swap REPEAT drop ;
: reg  >r encode-phys r> encode-int+ s" reg" property ;

: >space    node>space @ ;
: >space?   node>space? @ ;
: >address  dup >r #address-cells dup 3 > IF r@ node>addr3 @ swap THEN
dup 2 > IF r@ node>addr2 @ swap THEN
1 > IF r@ node>addr1 @ THEN r> drop ;
: >unit     dup >r >address r> >space ;

: (my-phandle)  ( -- phandle )
my-self ?dup IF
ihandle>phandle
ELSE
get-node dup 0= ABORT" no active node"
THEN
;

: my-space ( -- phys.hi )
(my-phandle) >space
;
: my-address  (my-phandle) >address ;

: my-unit
my-self instance>#units @ IF
0 my-self instance>#units @ 1- DO
my-self instance>unit1 i cells + @
-1 +LOOP
ELSE
my-self ihandle>phandle >unit
THEN
;

: my-unit-64 ( -- phys.lo+1|phys.lo )
my-unit                                ( phys.lo ... phys.hi )
(my-phandle) #address-cells            ( phys.lo ... phys.hi #ad-cells )
CASE
1   OF EXIT ENDOF
ENDCASE
;

: set-space    get-node dup >r node>space ! true r> node>space? ! ;
: set-address  my-#address-cells 1 ?DO
get-node node>space i cells + ! LOOP ;
: set-unit     set-space set-address ;

: set-args ( arg-str len unit-str len -- )
s" decode-unit" get-parent $call-static set-unit set-my-args
;

: $cat-unit
dup parent 0= IF drop EXIT THEN
dup >space? not IF drop EXIT THEN
dup >r >unit s" encode-unit" r> parent $call-static
dup IF
dup >r here swap move s" @" $cat here r> $cat
ELSE
2drop
THEN
;

: $cat-instance-unit
dup parent 0= IF drop EXIT THEN
dup instance>#units @ 0= IF
ihandle>phandle $cat-unit
EXIT
THEN
dup >r push-my-self
['] my-unit CATCH IF pop-my-self r> drop EXIT THEN
pop-my-self
s" encode-unit"
r> ihandle>phandle parent
$call-static
dup IF
dup >r here swap move s" @" $cat here r> $cat
ELSE
2drop
THEN
;

: node>name  dup >r s" name" rot get-property IF r> (u.) ELSE 1- r> drop THEN ;
: node>qname dup node>name rot ['] $cat-unit CATCH IF drop THEN ;
: node>path
here 0 rot
BEGIN dup WHILE dup parent REPEAT
2drop
dup 0= IF [char] / c, THEN
BEGIN
dup
WHILE
[char] / c, node>qname here over allot swap move
REPEAT
drop here 2dup - allot over -
;

: interposed? ( ihandle -- flag )
dup instance>parent @ dup 0= IF 2drop false EXIT THEN
ihandle>phandle swap ihandle>phandle parent <> ;

: instance>qname
dup >r interposed? IF s" %" ELSE 0 0 THEN
r@ dup ihandle>phandle node>name
rot ['] $cat-instance-unit CATCH IF drop THEN
$cat r> instance>args 2@ swap
dup IF 2>r s" :" $cat 2r> $cat ELSE 2drop THEN
;

: instance>qpath \ With interposed nodes.
here 0 rot BEGIN dup WHILE dup instance>parent @ REPEAT 2drop
dup 0= IF [char] / c, THEN
BEGIN dup WHILE [char] / c, instance>qname here over allot swap move
REPEAT drop here 2dup - allot over - ;
: instance>path \ Without interposed nodes.
here 0 rot BEGIN dup WHILE
dup interposed? 0= IF dup THEN instance>parent @ REPEAT 2drop
dup 0= IF [char] / c, THEN
BEGIN dup WHILE [char] / c, instance>qname here over allot swap move
REPEAT drop here 2dup - allot over - ;

: .node  node>path type ;
: pwd  get-node .node ;

: .instance instance>qpath type ;
: .chain    dup instance>parent @ ?dup IF recurse THEN
cr dup . instance>qname type ;

defer find-node
: set-alias ( alias-name len device-name len -- )
encode-string
2swap s" /aliases" find-node ?dup IF
set-property
ELSE
4drop
THEN
;

: find-alias ( alias-name len -- false | dev-path len )
s" /aliases" find-node dup IF
get-property 0= IF 1- dup 0= IF nip THEN ELSE false THEN
THEN
;

: .alias ( alias-name len -- )
find-alias dup IF type ELSE ." no alias available" THEN ;

: (.print-alias) ( lfa -- )
dup >name
2dup s" name" string=ci IF 2drop drop
ELSE cr type space ." : " execute type
THEN ;

: (.list-alias) ( phandle -- )
node>properties @ cell+ @ BEGIN dup WHILE dup (.print-alias) @ REPEAT drop ;

: list-alias ( -- )
s" /aliases" find-node dup IF (.list-alias) THEN ;

d# 10 CONSTANT MAX-ALIAS
1 VALUE alias-ind
: get-next-alias ( $alias-name -- $next-alias-name|FALSE )
2dup find-alias IF
drop
1 TO alias-ind
BEGIN
2dup alias-ind $cathex 2dup find-alias
WHILE
drop 2drop
alias-ind 1 + TO alias-ind
alias-ind MAX-ALIAS = IF
2drop FALSE EXIT
THEN
REPEAT
strdup 2swap 2drop
THEN
;

: devalias ( "{alias-name}<>{device-specifier}<cr>" -- )
parse-word parse-word dup IF set-alias
ELSE 2drop dup IF .alias
ELSE 2drop list-alias THEN THEN ;

: sub-alias ( arg-str arg-len -- arg' len' | false )
2dup
2dup [char] / findchar ?dup IF ELSE 2dup [char] : findchar THEN
( a l a l [p] -1|0 ) IF nip dup ELSE 2drop 0 THEN >r
( a l l p -- R:p | a l -- R:0 )
find-alias ?dup IF ( a l a' p' -- R:p | a' l' -- R:0 )
r@ IF
2swap r@ - swap r> + swap $cat strdup ( a" l-p+p' -- )
ELSE
( a' l' -- R:0 ) r> drop ( a' l' -- )
THEN
ELSE
( a l -- R:p | -- R:0 ) r> IF 2drop THEN
false ( 0 -- )
THEN
;

: de-alias ( arg-str arg-len -- arg' len' )
BEGIN
over c@ [char] / <> dup IF drop 2dup sub-alias ?dup THEN
WHILE
2swap 2drop
REPEAT
;

: +indent ( not-last? -- )
IF s" |   " ELSE s"     " THEN $indent indent @ + swap move 4 indent +! ;
: -indent ( -- )  -4 indent +! ;

: ls-phandle ( node -- )  . ." :  " ;

: ls-node ( node -- )
cr dup ls-phandle
$indent indent @ type
dup peer IF ." |-- " ELSE ." +-- " THEN
node>qname type
;

: (ls) ( node -- )
child BEGIN dup WHILE dup ls-node dup child IF
dup peer +indent dup recurse -indent THEN peer REPEAT drop ;

: ls ( -- )
get-node cr
dup ls-phandle
dup node>path type
(ls)
0 indent !
;

: show-devs ( {device-specifier}<eol> -- )
parse-word dup IF de-alias ELSE 2drop s" /" THEN   ( str len )
find-node dup 0= ABORT" No such device path" (ls)
;

VARIABLE interpose-node
2VARIABLE interpose-args
: interpose ( arg len phandle -- )  interpose-node ! interpose-args 2! ;

0 VALUE user-instance-#units
CREATE user-instance-units 4 cells allot

: copy-instance-unit  ( -- )
user-instance-#units IF
user-instance-#units my-self instance>#units !
user-instance-units my-self instance>unit1 user-instance-#units cells move
0 to user-instance-#units
THEN
;

: open-node ( arg len phandle -- ihandle|0 )
current-node @ >r  my-self >r            \ Save current node and instance
set-node create-instance set-my-args
copy-instance-unit
s" open" get-node find-method IF execute ELSE TRUE THEN
0= IF
my-self destroy-instance 0 to my-self
THEN
my-self                                  ( ihandle|0 )
r> to my-self  r> set-node               \ Restore current node and instance
interpose-node @ IF
my-self >r to my-self
interpose-args 2@ interpose-node @
interpose-node off recurse
r> to my-self
THEN
;

: close-node ( ihandle -- )
my-self >r to my-self
s" close" ['] $call-my-method CATCH IF 2drop THEN
my-self destroy-instance r> to my-self ;

: close-dev ( ihandle -- )
my-self >r to my-self
BEGIN my-self WHILE my-parent my-self close-node to my-self REPEAT
r> to my-self ;

: new-device ( -- )
[: ." New device: " ;] dbexec \ OF816 debug
my-self new-node                     ( parent-ihandle phandle )
node>instance-template @             ( parent-ihandle ihandle )
dup to my-self                       ( parent-ihanlde ihandle )
instance>parent !
get-node my-self instance>node !
max-instance-size my-self instance>size !
;

: finish-device ( -- )
get-node >space? 0= IF
s" reg" get-node get-property 0= IF
decode-int set-space 2drop
THEN
THEN
finish-node my-parent to my-self
;

: extend-device  ( phandle -- )
my-self >r
dup set-node
node>instance-template @
dup to my-self
r> swap instance>parent !
;

: split ( str len char -- left len right len )
>r 2dup r> findchar IF >r over r@ 2swap r> 1+ /string ELSE 0 0 THEN ;
: generic-decode-unit ( str len ncells -- addr.lo ... addr.hi )
dup >r -rot BEGIN r@ WHILE r> 1- >r [char] , split 2swap
$number IF 0 THEN r> swap >r >r REPEAT r> 3drop
BEGIN dup WHILE 1- r> swap REPEAT drop ;
: generic-encode-unit ( addr.lo ... addr.hi ncells -- str len )
0 0 rot ?dup IF 0 ?DO rot (u.) $cat s" ," $cat LOOP 1- THEN ;
: hex-decode-unit ( str len ncells -- addr.lo ... addr.hi )
base @ >r hex generic-decode-unit r> base ! ;
: hex-encode-unit ( addr.lo ... addr.hi ncells -- str len )
base @ >r hex generic-encode-unit r> base ! ;

: handle-leading-/ ( path len -- path' len' )
dup IF over c@ [char] / = IF 1 /string device-tree @ set-node THEN THEN ;
: match-name ( name len node -- match? )
over 0= IF 3drop true EXIT THEN
s" name" rot get-property IF 2drop false EXIT THEN
1- string=ci ; \ XXX should use decode-string

0 VALUE #search-unit
CREATE search-unit 4 cells allot

: match-unit ( node -- match? )
dup >space? IF
node>space search-unit #search-unit 0 ?DO 2dup @ swap @ <> IF
2drop false UNLOOP EXIT THEN cell+ swap cell+ swap LOOP 2drop true
ELSE drop true THEN
;
: match-node ( name len node -- match? )
dup >r match-name r> match-unit and ; \ XXX e3d
: find-kid ( name len -- node|0 )
dup -1 = IF \ are we supposed to stay in the same node? -> resolve-relatives
2drop get-node
ELSE
get-node child >r BEGIN r@ WHILE 2dup r@ match-node
IF 2drop r> EXIT THEN r> peer >r REPEAT
r> 3drop false
THEN ;

: set-search-unit ( unit len -- )
0 to #search-unit
0 to user-instance-#units
dup 0= IF 2drop EXIT THEN
s" #address-cells" get-node get-property THROW
decode-int to #search-unit 2drop
s" decode-unit" get-node $call-static
( ) #search-unit 0 ?DO search-unit i cells + ! LOOP
;

: resolve-relatives ( path len -- path' len' )
2dup 2 = swap s" .." comp 0= and IF
get-node parent ?dup IF
set-node drop -1
ELSE
s" Already in root node." type
THEN
THEN
2dup 1 = swap c@ [CHAR] . = and IF
drop -1
THEN
;

: set-instance-unit  ( unitaddr len -- )
dup 0= IF 2drop  0 to user-instance-#units  EXIT THEN
2dup 0 -rot bounds ?DO
i c@ [char] , = IF 1+ THEN      \ Count the commas
LOOP
1+ dup to user-instance-#units
hex-decode-unit
user-instance-#units 0 ?DO
user-instance-units i cells + !
LOOP
;

: split-component  ( path. -- path'. args. name. unit. )
[char] / split 2swap     ( path'. component. )
[char] : split 2swap     ( path'. args. name@unit. )
[char] @ split           ( path'. args. name. unit. )
;

: find-component  ( path len -- path' len' args len node|0 )
debug-find-component? IF
." find-component for " 2dup type cr
THEN
split-component           ( path'. args. name. unit. )
debug-find-component? IF
." -> unit  =" 2dup type cr
." -> stack =" .s cr
THEN
['] set-search-unit CATCH IF
." WARNING: Obsolete old wildcard hack " .s cr
set-instance-unit
THEN
resolve-relatives find-kid        ( path' len' args len node|0 )

dup IF dup >space? not #search-unit 0 > AND user-instance-#units 0= AND IF
( ) #search-unit dup to user-instance-#units 0 ?DO
search-unit i cells + @ user-instance-units i cells + !
LOOP
THEN THEN

dup IF dup >space? user-instance-#units 0 > AND IF
cr ." find-component with unit mismatch!" .s cr
drop 0
THEN THEN
;

: .find-node ( path len -- phandle|0 )
current-node @ >r
handle-leading-/ current-node @ 0= IF 2drop r> set-node 0 EXIT THEN
BEGIN dup WHILE \ handle one component:
find-component ( path len args len node ) dup 0= IF
3drop 2drop r> set-node 0 EXIT THEN
set-node 2drop REPEAT 2drop
get-node r> set-node ;
' .find-node to find-node
: find-node ( path len -- phandle|0 ) de-alias find-node ;

: delete-node ( phandle -- )
dup node>instance-template @ max-instance-size free-mem
dup node>parent @ node>child @ ( phandle 1st peer )
2dup = IF
node>peer @ swap node>parent @ node>child !
EXIT
THEN
dup node>peer @
BEGIN
2 pick 2dup <>
WHILE
drop
nip dup node>peer @
dup 0= IF 2drop drop unloop EXIT THEN
REPEAT
drop
node>peer @  swap node>peer !
drop
;

: open-dev ( path len -- ihandle|0 )
0 to user-instance-#units
de-alias current-node @ >r
handle-leading-/ current-node @ 0= IF 2drop r> set-node 0 EXIT THEN
my-self >r
0 to my-self
0 0 >r >r
BEGIN
dup
WHILE \ handle one component:
( arg len ) r> r> get-node open-node to my-self
find-component ( path len args len node ) dup 0= IF
3drop 2drop my-self close-dev
r> to my-self
r> set-node
0 EXIT
THEN
set-node
>r >r
REPEAT
2drop
r> r> get-node open-node to my-self
my-self r> to my-self r> set-node
;

: select-dev  open-dev dup to my-self ihandle>phandle set-node ;
: unselect-dev  my-self close-dev  0 to my-self  device-end ;

: find-device ( str len -- ) \ set as active node
find-node dup 0= ABORT" No such device path" set-node ;
: dev  parse-word find-device ;

: (lsprop) ( node --)
dup cr $indent indent @ type ."     node: " node>qname type
false +indent (.properties) cr -indent
;
: (show-children) ( node -- )
child BEGIN
dup
WHILE
dup (lsprop) dup child IF false +indent dup recurse -indent THEN peer
REPEAT
drop
;
: lsprop ( {device-specifier}<eol> -- )
parse-word dup IF de-alias ELSE 2drop s" /" THEN
find-device get-node dup dup
cr ." node: " node>path type (.properties) cr (show-children)
0 indent !
;

: (node>path) node>path ;

: node>path ( phandle -- str len )
node>path dup allot
;

0 VALUE packages

: find-package  ( name len -- false | phandle true )
dup 0 <= IF
2drop FALSE EXIT
THEN
over c@ [char] / = IF
find-node dup IF TRUE THEN EXIT
THEN
0 >r packages child
BEGIN
dup
WHILE
dup >r node>name 2over string=ci r> swap IF
r> drop dup >r
THEN
peer
REPEAT
3drop
r> dup IF true THEN
;

: open-package ( arg len phandle -- ihandle | 0 )  open-node ;
: close-package ( ihandle -- )  close-node ;
: $open-package ( arg len name len -- ihandle | 0 )
find-package IF open-package ELSE 2drop false THEN ;

db" OF root device node (c) IBM"

defer (client-exec)
defer client-exec

defer callback
defer continue-client

0 VALUE chosen-node

: chosen
chosen-node dup 0= IF
drop s" /chosen" find-node dup to chosen-node
THEN
;

: set-chosen ( prop len name len -- )
chosen set-property ;

: get-chosen ( name len -- [ prop len ] success )
chosen get-property 0= ;

VARIABLE chosen-cpu-ihandle
: set-chosen-cpu ( -- )
s" /cpus" find-node  dup 0= ABORT" /cpus not found"
child                dup 0= ABORT" /cpus/cpu not found"
0 0 rot open-node
dup chosen-cpu-ihandle !  encode-int s" cpu" set-chosen
;

: chosen-cpu-unit ( -- ret ) chosen-cpu-ihandle @ ihandle>phandle >unit ;

" /" find-node dup 0= IF
drop
new-device
s" /" device-name
ELSE
extend-device
THEN

" /chosen" find-node dup 0= IF
drop
new-device
s" chosen" device-name
s" " encode-string s" bootargs" property
s" " encode-string s" bootpath" property
finish-device
ELSE
drop
THEN

new-device
s" aliases" device-name
: open  true ;
: close ;
finish-device

new-device
s" options" device-name
finish-device

new-device
s" openprom" device-name
0 0 s" relative-addressing" property
finish-device

new-device 

s" packages" device-name
get-node to packages

new-device

s" filler" device-name

: block-size  s" block-size" $call-parent ;
: seek        s" seek"       $call-parent ;
: read        s" read"       $call-parent ;

: open  true ;
: close ;

finish-device

finish-device

: open true ;
: close ;

finish-device

previous definitions
banner

