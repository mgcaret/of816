testing 7.3.1.1 Stack duplication
t{ 1 dup -> 1 1 }t
t{ 1 2 2dup -> 1 2 1 2 }t
t{ 1 2 3 3dup -> 1 2 3 1 2 3 }t
t{ 0 ?dup -> 0 }t
t{ 1 ?dup -> 1 1 }t
t{ 1 2 over -> 1 2 1 }t
t{ 1 2 3 4 2over -> 1 2 3 4 1 2 }t
t{ 1 2 3 1 pick -> 1 2 3 2 }t
t{ 1 2 tuck -> 2 1 2 }t

testing 7.3.1.2 Stack removal
t{ 1 2 3 clear -> }t
t{ 1 drop -> }t
t{ 1 2 2drop -> }t
t{ 1 2 3 3drop -> }t
t{ 1 2 nip -> 2 }t

testing 7.3.1.3 Stack rearrangement
T{ : RO5 100 200 300 400 500 ; -> }T
T{ RO5 3 ROLL -> 100 300 400 500 200 }T
T{ RO5 2 ROLL -> RO5 ROT }T
T{ RO5 1 ROLL -> RO5 SWAP }T
T{ RO5 0 ROLL -> RO5 }T
t{ 1 2 3 rot -> 2 3 1 }t
t{ 1 2 3 -rot -> 3 1 2 }t
t{ 1 2 swap -> 2 1 }t
t{ 1 2 3 4 2swap -> 3 4 1 2 }t

testing 7.3.1.4 Return stack
t{ 1 2 >r drop >r -> 2 }t \ both >r and r>
t{ 1 >r r@ r> -> 1 1 }t

testing 7.3.1.5 Stack depth
t{ 1 2 3 depth -> 1 2 3 3 }t
