testing 7.3.4.1 Text input
hex

\ test comment words
t{ 1 -> 1 }t ( t{ 1 -> 2 }t ) t{ 2 -> 2 }t
t{ 1 -> 1 }t \ t{ 1 -> 2 }t

t{ >in @ 0> -> true }t
t{ ascii / parse test/ swap 0> -> 4 true }t
t{ parse-word test swap 0> -> 4 true }t
t{ source 0> swap 0> -> true true }t
t{ bl word test count swap 0> -> 4 true }t

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

testing 7.3.4.2 Console input

\ covers: \
t{ \ -> supercalafrag }t   \ since 't{' is a nop this should be fine

\ hard to test stuff
t{ ' key?   0= -> false }t
t{ ' key    0= -> false }t
t{ ' expect 0= -> false }t
t{ ' span   0= -> false }t
t{ ' accept 0= -> false }t

testing 7.3.4.3 ASCII constants

hex

t{ bell     -> 07 }t
t{ bl       -> 20 }t
t{ bs       -> 08 }t
t{ carret   -> 0D }t
t{ linefeed -> 0A }t
t{ ascii A  -> 41 }t
t{ char A   -> 41 }t

t{ : an-a [char] A ; -> }t
t{ an-a -> 41 }t

t{ control A -> 01 }t

testing 7.3.4.4 Console output

t{ ." test" -> }t \ expect: "test OK"
t{ .( test) -> }t \ expect: "test OK"
t{ 41 emit -> }t \ expect: "A OK"
t{ parse-word test type -> }t \ expect: "test OK"

testing 7.3.4.5 Output formatting

t{ cr -> }t \ expect: ""
t{ space -> }t \ expect: "  OK"
t{ 8 spaces -> }t \ expect: "         OK"
t{ #line @ 0>= -> true }t
t{ #out @ 0>= -> true }t

testing 7.3.4.6 Display pause

t{ ' exit? 0= -> false }t

testing 7.3.4.7 String literals

t{ " test" swap 0> -> 4 true }t
t{ s" test" swap 0> -> 4 true }t
t{ " test"(41)" swap 0> -> 5 true }t
t{  s" testA" drop " test"(41)" comp -> 0 }t

testing 7.3.4.8 String manipulation
\ these aren't very good but hey

\ count tested above, sort of, and sort of again, here
\ along with pack
t{ s" AAAAA" drop >r s" BBBB" r> pack count swap 0> -> 4 true }t

t{ ascii a ascii A lcc = -> true }t
t{ ascii b ascii b lcc = -> true }t
t{ ascii A ascii a upc = -> true }t
t{ ascii B ascii B upc = -> true }t
t{ s" abc   " -trailing nip 3 = -> true }t

