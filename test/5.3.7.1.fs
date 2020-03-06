testing 5.3.7.1 Peek/poke

\ On the 65816, all memory regions are valid, even if there isn't anything there
\ so these always succeed.  We just test for correctness.

hex
variable foobar
f0e1d2c3 foobar !

t{ foobar cpeek -> c3 true }t
t{ foobar 1 ca+ cpeek -> d2 true }t
t{ foobar 2 ca+ cpeek -> e1 true }t
t{ foobar 3 ca+ cpeek -> f0 true }t

t{ foobar wpeek -> d2c3 true }t
t{ foobar 1 wa+ wpeek -> f0e1 true }t

t{ foobar lpeek -> f0e1d2c3 true }t

t{ 01020304 foobar lpoke -> true }t
t{ foobar lpeek -> 01020304 true }t

t{ abcd foobar wpoke -> true }t
t{ ef01 foobar 1 wa+ wpoke -> true }t
t{ foobar wpeek -> abcd true }t
t{ foobar 1 wa+ wpeek -> ef01 true }t
t{ foobar lpeek -> ef01abcd true }t

t{ 22 foobar cpoke -> true }t
t{ 33 foobar 2 ca+ cpoke -> true }t
t{ foobar cpeek -> 22 true }t
t{ foobar 2 ca+ cpeek -> 33 true }t
t{ foobar lpeek -> ef33ab22 true }t
