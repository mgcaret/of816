testing 7.3.5.1 Numeric-base control

t{ hex -> }t
t{ base @ -> 10 }t
t{ decimal base @ hex -> 0a }t
t{ octal base @ hex -> 08 }t

testing 7.3.5.2 Numeric input

hex

t{ s" 123" $number -> 123 false }t
t{ s" $xyz" $number -> true }t

t{ 0 s>d s" 456" >number nip -> 456 s>d 0 }t
t{ 0 s>d s" $xyz" >number nip -> 0 s>d 4 }t

t{ 3a 30 do i 10 digit drop loop -> 0 1 2 3 4 5 6 7 8 9 }t
t{ 47 41 do i 10 digit drop loop -> a b c d e f }t
t{ 67 61 do i 10 digit drop loop -> a b c d e f }t
t{ 6a 67 do i 10 digit nip loop -> false false false }t

t{ d# 10 -> 0a }t
decimal
t{ h# 10 hex -> 10 }t
hex
t{ o# 10 -> 08 }t

testing 7.3.5.3 Numeric output

\ the output must be examined by hand to completely verify
\ but if the subsequent privitives work, the chances are that
\ these work as well

t{ 0 . 1 . -1 . -> }t
t{ 0 s. 1 s. -1 s. -> }t
t{ 0 u. 1 u. -1 u. -> }t       \ 0 1 ffffffff
t{ -1 10 .r -> }t
t{ -1 10 u.r -> }t
t{ f .d -> }t
decimal
t{ 15 .h -> }t
hex
t{ 0 1 .s -> 0 1 }t
t{ base ? -> }t

testing 7.3.5.4 Numeric output primitives

hex

: s= ( str len str len )
  2 pick over = if
    drop swap comp 0=
  else
    2drop 2drop false
  then
;

t{ 0 (.) s" 0" s= -> true }t
t{ -1 (.) s" -1" s= -> true }t
t{ 1 (.) s" 1" s= -> true }t

t{ 0 (u.) s" 0" s= -> true }t
t{ -1 (u.) s" FFFFFFFF" s= -> true }t
t{ 1 (u.) s" 1" s= -> true }t

T{ <# 41 HOLD 42 HOLD 0 0 #> S" BA" S= -> true }T
T{ <# -1 SIGN 0 SIGN -1 SIGN 0 0 #> S" --" S= -> true }T
T{ <# 1 0 # # #> S" 01" S= -> true }T
T{ <# 1 0 #S #> S" 1" S= -> true }T

T{ <# 1 u#s u#> S" 1" S= -> true }T
