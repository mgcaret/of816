0 CONSTANT 0S
0 INVERT CONSTANT 1S

0 INVERT CONSTANT MAX-UINT
0 INVERT 1 RSHIFT CONSTANT MAX-INT
0 INVERT 1 RSHIFT INVERT CONSTANT MIN-INT
0 INVERT 1 RSHIFT CONSTANT MID-UINT
0 INVERT 1 RSHIFT INVERT CONSTANT MID-UINT+1

0S CONSTANT <FALSE>
1S CONSTANT <TRUE>

testing 7.3.6 Comparison operators

T{ 0 1 < -> <TRUE> }T
T{ 1 2 < -> <TRUE> }T
T{ -1 0 < -> <TRUE> }T
T{ -1 1 < -> <TRUE> }T
T{ MIN-INT 0 < -> <TRUE> }T
T{ MIN-INT MAX-INT < -> <TRUE> }T
T{ 0 MAX-INT < -> <TRUE> }T
T{ 0 0 < -> <FALSE> }T
T{ 1 1 < -> <FALSE> }T
T{ 1 0 < -> <FALSE> }T
T{ 2 1 < -> <FALSE> }T
T{ 0 -1 < -> <FALSE> }T
T{ 1 -1 < -> <FALSE> }T
T{ 0 MIN-INT < -> <FALSE> }T
T{ MAX-INT MIN-INT < -> <FALSE> }T
T{ MAX-INT 0 < -> <FALSE> }T

T{ 0 0 = -> <TRUE> }T
T{ 1 1 = -> <TRUE> }T
T{ -1 -1 = -> <TRUE> }T
T{ 1 0 = -> <FALSE> }T
T{ -1 0 = -> <FALSE> }T
T{ 0 1 = -> <FALSE> }T
T{ 0 -1 = -> <FALSE> }T

T{ 0 1 > -> <FALSE> }T
T{ 1 2 > -> <FALSE> }T
T{ -1 0 > -> <FALSE> }T
T{ -1 1 > -> <FALSE> }T
T{ MIN-INT 0 > -> <FALSE> }T
T{ MIN-INT MAX-INT > -> <FALSE> }T
T{ 0 MAX-INT > -> <FALSE> }T
T{ 0 0 > -> <FALSE> }T
T{ 1 1 > -> <FALSE> }T
T{ 1 0 > -> <TRUE> }T
T{ 2 1 > -> <TRUE> }T
T{ 0 -1 > -> <TRUE> }T
T{ 1 -1 > -> <TRUE> }T
T{ 0 MIN-INT > -> <TRUE> }T
T{ MAX-INT MIN-INT > -> <TRUE> }T
T{ MAX-INT 0 > -> <TRUE> }T

t{ 0 0 >= -> <true> }t
t{ 1 0 >= -> <true> }t
t{ 2 0 >= -> <true> }t
t{ -1 0 >= -> <false> }t
t{ -1 1 >= -> <false> }t
t{ 1 -1 >= -> <true> }t
t{ min-int 0 >= -> <false> }t
t{ max-int 0 >= -> <true> }t
t{ min-int max-int >= -> <false> }t
t{ max-int min-int >= -> <true> }t

\ todo: between within

T{ 0 0< -> <FALSE> }T
T{ -1 0< -> <TRUE> }T
T{ MIN-INT 0< -> <TRUE> }T
T{ 1 0< -> <FALSE> }T
T{ MAX-INT 0< -> <FALSE> }T

t{ 0 0<= -> <true> }t
t{ -1 0<= -> <true> }t
t{ -2 0<= -> <true> }t
t{ 1 0<= -> <false> }t
t{ min-int 0<= -> <true> }t
t{ max-int 0<= -> <false> }t

t{ 0 0<> -> <false> }t
t{ 1 0<> -> <true> }t
t{ 2 0<> -> <true> }t
t{ -1 0<> -> <true> }t
t{ MAX-UINT 0<> -> <true> }t
t{ MIN-INT 0<> -> <true> }t
t{ MAX-INT 0<> -> <true> }t

T{ 0 0= -> <TRUE> }T
T{ 1 0= -> <FALSE> }T
T{ 2 0= -> <FALSE> }T
T{ -1 0= -> <FALSE> }T
T{ MAX-UINT 0= -> <FALSE> }T
T{ MIN-INT 0= -> <FALSE> }T
T{ MAX-INT 0= -> <FALSE> }T

t{ 0 0> -> <false> }t
t{ 1 0> -> <true> }t
t{ 2 0> -> <true> }t
t{ -1 0> -> <false> }t
t{ min-int 0> -> <false> }t
t{ max-int 0> -> <true> }t

t{ 0 0>= -> <true> }t
t{ 1 0>= -> <true> }t
t{ 2 0>= -> <true> }t
t{ -1 0>= -> <false> }t
t{ min-int 0>= -> <false> }t
t{ max-int 0>= -> <true> }t

T{ 0 1 U< -> <TRUE> }T
T{ 1 2 U< -> <TRUE> }T
T{ 0 MID-UINT U< -> <TRUE> }T
T{ 0 MAX-UINT U< -> <TRUE> }T
T{ MID-UINT MAX-UINT U< -> <TRUE> }T
T{ 0 0 U< -> <FALSE> }T
T{ 1 1 U< -> <FALSE> }T
T{ 1 0 U< -> <FALSE> }T
T{ 2 1 U< -> <FALSE> }T
T{ MID-UINT 0 U< -> <FALSE> }T
T{ MAX-UINT 0 U< -> <FALSE> }T
T{ MAX-UINT MID-UINT U< -> <FALSE> }T

\ todo: u<= u> u>=
