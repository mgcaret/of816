testing 7.3.5.1 Numeric-base control

t{ hex -> }t
t{ base @ -> 10 }t
t{ decimal base @ hex -> 0a }t
t{ octal base @ hex -> 08 }t

testing 7.3.5.2 Numeric input

hex

\ IEEE 1275-1994 number input

\ first make sure >number (ANS word) works
t{ 0 s>d s" 123" >number nip -> 123 0 0 }t
t{ 0 s>d s" 123?456" >number nip -> 123 0 4 }t

t{ 1,234,567 -> 1234567 }t
t{ 1.234.567 -> 1234567 }t
t{ 1234567. -> 1234567 s>d }t
t{ -1234567. -> -1234567 s>d }t

\ Things that should fail
t{ s" 123," ' eval catch >r clear r> -> -d }t
t{ s" ,123" ' eval catch >r clear r> -> -d }t
t{ s" .123" ' eval catch >r clear r> -> -d }t


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

t{ 0 . 1 . -1 . -> }t    \ expect: "0 1 -1  OK"
t{ 0 s. 1 s. -1 s. -> }t \ expect: "0 1 -1  OK"
t{ 0 u. 1 u. -1 u. -> }t \ expect: "0 1 FFFFFFFF  OK"
t{ -1 7 .r -> }t  \ expect: "     -1 OK"
t{ -1 9 u.r -> }t \ expect: " FFFFFFFF OK"
t{ f .d -> }t \ expect: "15  OK"
decimal
t{ 15 .h -> }t \ expect: "F  OK"
hex
t{ 0 1 .s -> 0 1 }t \ expect: "{ 2 : 0 1 } OK"
t{ base ? -> }t \ expect: "10  OK"

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
