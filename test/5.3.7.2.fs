testing 5.3.7.1 Device-register access

\ On the 65816, no strictly atomic 16-bit accesses can occur as the data bus is only
\ 8 bits.  So the "register access" words are the same as their non-register equivalents.
\ We just test for correctness.

hex
variable foobar
f0e1d2c3 foobar !

t{ foobar rb@ -> c3 }t
t{ foobar 1 ca+ rb@ -> d2 }t
t{ foobar 2 ca+ rb@ -> e1 }t
t{ foobar 3 ca+ rb@ -> f0 }t

t{ foobar rw@ -> d2c3 }t
t{ foobar 1 wa+ rw@ -> f0e1 }t

t{ foobar rl@ -> f0e1d2c3 }t

t{ 01020304 foobar rl! -> }t
t{ foobar rl@ -> 01020304 }t

t{ abcd foobar rw! -> }t
t{ ef01 foobar 1 wa+ rw! -> }t
t{ foobar rw@ -> abcd }t
t{ foobar 1 wa+ rw@ -> ef01 }t
t{ foobar rl@ -> ef01abcd }t

t{ 22 foobar rb! -> }t
t{ 33 foobar 2 ca+ rb! -> }t
t{ foobar rb@ -> 22 }t
t{ foobar 2 ca+ rb@ -> 33 }t
t{ foobar rl@ -> ef33ab22 }t
