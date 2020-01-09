testing OF816 words

\ excluding FCode-related words

t{ binary base @ hex -> 2 }t

: s= ( str len str len )
  2 pick over = if
    drop swap comp 0=
  else
    2drop 2drop false
  then
;

\ Byte and word sign extension
t{ 0 bsx -> 0 }t
t{ 7f bsx -> 7f }t
t{ 80 bsx -> -80 }t
t{ ff bsx -> -1 }t

t{ 0 wsx -> 0 }t
t{ 7fff wsx -> 7fff }t
t{ 8000 wsx -> -8000 }t
t{ ffff wsx -> -1 }t

\ Return stack
t{ 1 >r 2 >r rdrop r> -> 1 }t
t{ 1 >r r+1 r> -> 2 }t
t{ 1 >r@ r> -> 1 1 }t

\ Dictionary management
t{ s" dm1" $create -> }t
t{ last ' dm1 >link = -> true }t
t{ ' dm1 >name s" DM1" s= -> true }t

\ Temporary string buffer & allocated strings
\ and $2value for the heck of it
\ This is indirectly tested by all s" and " tests.
t{ s" foobar" 2dup $tmpstr s= -> true }t
t{ a" foobaz" 2dup $2value -> }t
t{ a" bazbar" 2dup $2value -> }t
t{ foobaz s" foobaz" s= -> true }t
t{ bazbar s" bazbar" s= -> true }t
t{ foobaz bazbar aconcat 2constant fbbb -> }t
t{ fbbb s" foobazbazbar" s= -> true }t
t{ fbbb free-mem -> }t
t{ $hex( 414243) 2dup $2value -> }t
t{ abc s" ABC" s= -> true }t

\ Case-independent comparison
t{ s" foo" drop s" FoO" cicomp -> 0 }t

\ Memory debug, good time to run it after the above
t{ debug-mem -> }t

\ Temporary definitions
t{ :temp 1 ; -> 1 }t

\ Quotations
t{ : qt1 [: 123 ;] ; -> }t
t{ qt1 execute -> 123 }t

\ Existence of a couple of words that are hard to test
t{ ' $empty-wl 0= -> false }t
t{ ' $env?-wl 0= -> false }t
t{ ' $sysif 0= -> false }t
t{ ' $direct 0= -> false }t

\ square root
decimal
t{ 0 sqrtrem -> 0 0 }t
t{ 4 sqrtrem -> 2 0 }t
t{ 25 sqrtrem -> 5 0 }t
t{ 31 sqrtrem -> 5 6 }t
hex

t{ $memtop @ 0= -> false }t
