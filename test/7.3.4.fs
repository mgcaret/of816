testing 7.3.4.1 Text input

t{ 1 -> 1 }t ( t{ 1 -> 2 }t ) t{ 2 -> 2 }t
t{ 1 -> 1 }t \ t{ 1 -> 2 }t

t{ >in @ 0> -> true }t
t{ ascii / parse test/ swap 0> -> 4 true }t
t{ parse-word test swap 0> -> 4 true }t
t{ source 0> swap 0> -> true true }t
t{ bl word test count swap 0> -> 4 true }t

testing 7.3.4.2 Console input
\ not functionally tested

t{ ' key?   0> -> true }t
t{ ' key    0> -> true }t
t{ ' expect 0> -> true }t
t{ ' span   0> -> true }t
t{ ' accept 0> -> true }t

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

t{ ." test" -> }t
t{ .( test ) -> }t
t{ 41 emit -> }t
t{ parse-word test type -> }t

testing 7.3.4.5 Output formatting

t{ cr -> }t
t{ space -> }t
t{ 10 spaces -> }t
t{ #line @ 0>= -> true }t
t{ #out @ 0>= -> true }t

testing 7.3.4.6 Display pause
\ not functionally tested

t{ ' exit? 0> -> true }t

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

