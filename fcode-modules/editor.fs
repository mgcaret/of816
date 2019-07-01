start1 decimal

." OF816 screen EDITOR by M.G. "

s" get-current vocabulary EDITOR also EDITOR definitions" evaluate

headers

\ necessary defers
defer $at-xy
s" at-xy" $find 0= if abort then to $at-xy
defer $page
s" page" $find 0= if abort then to $page
defer $-trailing
s" -trailing" $find 0= if abort then to $-trailing

\ other defers
external
defer $header \ to be used to display block #, etc.
' noop to $header
headers

\ set up variables
64 value $c/l
0 value $buf

\ adapted from miniEDIT in Bill Meunch post to comp.lang.forth 1/24/2010
: head ( -- )
  ." -Mini Editor- " $header
;

: ll ( line# -- )
  dup $c/l * $buf + $c/l type space 0 <# # # #> type
;

: list ( addr -- )
  0 begin cr dup ll 1+ dup 16 = until drop
;

: !xy ( i -- i ) 1023 and dup $c/l /mod 1+ $at-xy ;
: !ch ( c i -- c i ) 2dup $buf + c! over emit ;
: ?ch ( c i -- c i' )
  over bl - 95 u< if !ch 1+ exit then
  over 8 = if 1- then ( left backspace )
  over 127 = if 1- then ( left delete )
  over 12 = if 1+ then ( right )
  over 11 = if $c/l - then ( up )
  over 10 = if $c/l + then ( down )
  over 13 = if $c/l 2dup mod - + then ( cr )
  \ mx1 ( <- uncomment and put extensions here )
;

external

: $edit ( addr -- )
  to $buf
  $page 0 dup $at-xy head list 0
  begin !xy key swap ?ch swap 27 = until drop $page 0 dup $at-xy
;

: new-ram-screen
  1024 alloc-mem dup 1024 blank
;

: load-ram-screen
  1024 $-trailing eval
;

s" previous set-current" evaluate
." loaded!" cr

fcode-end
