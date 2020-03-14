testing 5.3.3 FCode implementation functions

\ Only testing built-in functions, it is expected that
\ the remaining Open Firmware specification, if implemented
\ will be done in Forth source or FCode.

\ Also, OF816 doesn't implement some of the FCode functions
\ as visible words (e.g. new-token, etc.)
\ These are untested by this suite.

testing 5.3.3.1 Defining new FCode functions

t{ s" mytrue" ' true (is-user-word) -> }t
t{ fc get-token drop -> ' ferror }t

600 get-token 2constant old-600
t{ ' true false 600 set-token -> }t
t{ 600 get-token -> ' true false }t
t{ ' false true 600 set-token -> }t
t{ 600 get-token -> ' false true }t
t{ old-600 600 set-token -> }t
t{ old-600 600 get-token swap >r = r> rot = -> true true }t

testing 5.3.3.3 Controlling values and defers

\ BEHAVIOR tested elsewhere, but we'll test here to verify
\ (is-user-word)

t{ ' mytrue behavior -> ' true }t

testing OF816 5.3.3-related checks

\ 0 and ff fcodes should be equivalent
t{ 0 get-token ff get-token swap >r = r> rot = -> true true }t
