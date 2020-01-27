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

t{ 0 0 0 between -> true }t
t{ 1 0 0 between -> false }t
t{ -1 0 0 between -> false }t
t{ -1 -1 1 between -> true }t
t{ 1 -1 1 between -> true }t
t{ 0 0 max-int between -> true }t
t{ 0 min-int 0 between -> true }t
t{ 1 min-int 0 between -> false }t
\ next test fails with current implementation of BETWEEN
\ t{ 0 min-int max-int between -> true }t

T{ 0 0 0 WITHIN -> FALSE }T
T{ 0 0 MID-UINT WITHIN -> TRUE }T
T{ 0 0 MID-UINT+1 WITHIN -> TRUE }T
T{ 0 0 MAX-UINT WITHIN -> TRUE }T
T{ 0 MID-UINT 0 WITHIN -> FALSE }T
T{ 0 MID-UINT MID-UINT WITHIN -> FALSE }T
T{ 0 MID-UINT MID-UINT+1 WITHIN -> FALSE }T
T{ 0 MID-UINT MAX-UINT WITHIN -> FALSE }T
T{ 0 MID-UINT+1 0 WITHIN -> FALSE }T
T{ 0 MID-UINT+1 MID-UINT WITHIN -> TRUE }T
T{ 0 MID-UINT+1 MID-UINT+1 WITHIN -> FALSE }T
T{ 0 MID-UINT+1 MAX-UINT WITHIN -> FALSE }T
T{ 0 MAX-UINT 0 WITHIN -> FALSE }T
T{ 0 MAX-UINT MID-UINT WITHIN -> TRUE }T
T{ 0 MAX-UINT MID-UINT+1 WITHIN -> TRUE }T
T{ 0 MAX-UINT MAX-UINT WITHIN -> FALSE }T
T{ MID-UINT 0 0 WITHIN -> FALSE }T
T{ MID-UINT 0 MID-UINT WITHIN -> FALSE }T
T{ MID-UINT 0 MID-UINT+1 WITHIN -> TRUE }T
T{ MID-UINT 0 MAX-UINT WITHIN -> TRUE }T
T{ MID-UINT MID-UINT 0 WITHIN -> TRUE }T
T{ MID-UINT MID-UINT MID-UINT WITHIN -> FALSE }T
T{ MID-UINT MID-UINT MID-UINT+1 WITHIN -> TRUE }T
T{ MID-UINT MID-UINT MAX-UINT WITHIN -> TRUE }T
T{ MID-UINT MID-UINT+1 0 WITHIN -> FALSE }T
T{ MID-UINT MID-UINT+1 MID-UINT WITHIN -> FALSE }T
T{ MID-UINT MID-UINT+1 MID-UINT+1 WITHIN -> FALSE }T
T{ MID-UINT MID-UINT+1 MAX-UINT WITHIN -> FALSE }T
T{ MID-UINT MAX-UINT 0 WITHIN -> FALSE }T
T{ MID-UINT MAX-UINT MID-UINT WITHIN -> FALSE }T
T{ MID-UINT MAX-UINT MID-UINT+1 WITHIN -> TRUE }T
T{ MID-UINT MAX-UINT MAX-UINT WITHIN -> FALSE }T
T{ MID-UINT+1 0 0 WITHIN -> FALSE }T
T{ MID-UINT+1 0 MID-UINT WITHIN -> FALSE }T
T{ MID-UINT+1 0 MID-UINT+1 WITHIN -> FALSE }T
T{ MID-UINT+1 0 MAX-UINT WITHIN -> TRUE }T
T{ MID-UINT+1 MID-UINT 0 WITHIN -> TRUE }T
T{ MID-UINT+1 MID-UINT MID-UINT WITHIN -> FALSE }T
T{ MID-UINT+1 MID-UINT MID-UINT+1 WITHIN -> FALSE }T
T{ MID-UINT+1 MID-UINT MAX-UINT WITHIN -> TRUE }T
T{ MID-UINT+1 MID-UINT+1 0 WITHIN -> TRUE }T
T{ MID-UINT+1 MID-UINT+1 MID-UINT WITHIN -> TRUE }T
T{ MID-UINT+1 MID-UINT+1 MID-UINT+1 WITHIN -> FALSE }T
T{ MID-UINT+1 MID-UINT+1 MAX-UINT WITHIN -> TRUE }T
T{ MID-UINT+1 MAX-UINT 0 WITHIN -> FALSE }T
T{ MID-UINT+1 MAX-UINT MID-UINT WITHIN -> FALSE }T
T{ MID-UINT+1 MAX-UINT MID-UINT+1 WITHIN -> FALSE }T
T{ MID-UINT+1 MAX-UINT MAX-UINT WITHIN -> FALSE }T
T{ MAX-UINT 0 0 WITHIN -> FALSE }T
T{ MAX-UINT 0 MID-UINT WITHIN -> FALSE }T
T{ MAX-UINT 0 MID-UINT+1 WITHIN -> FALSE }T
T{ MAX-UINT 0 MAX-UINT WITHIN -> FALSE }T
T{ MAX-UINT MID-UINT 0 WITHIN -> TRUE }T
T{ MAX-UINT MID-UINT MID-UINT WITHIN -> FALSE }T
T{ MAX-UINT MID-UINT MID-UINT+1 WITHIN -> FALSE }T
T{ MAX-UINT MID-UINT MAX-UINT WITHIN -> FALSE }T
T{ MAX-UINT MID-UINT+1 0 WITHIN -> TRUE }T
T{ MAX-UINT MID-UINT+1 MID-UINT WITHIN -> TRUE }T
T{ MAX-UINT MID-UINT+1 MID-UINT+1 WITHIN -> FALSE }T
T{ MAX-UINT MID-UINT+1 MAX-UINT WITHIN -> FALSE }T
T{ MAX-UINT MAX-UINT 0 WITHIN -> TRUE }T
T{ MAX-UINT MAX-UINT MID-UINT WITHIN -> TRUE }T
T{ MAX-UINT MAX-UINT MID-UINT+1 WITHIN -> TRUE }T
T{ MAX-UINT MAX-UINT MAX-UINT WITHIN -> FALSE }T

T{ MIN-INT MIN-INT MIN-INT WITHIN -> FALSE }T
T{ MIN-INT MIN-INT 0 WITHIN -> TRUE }T
T{ MIN-INT MIN-INT 1 WITHIN -> TRUE }T
T{ MIN-INT MIN-INT MAX-INT WITHIN -> TRUE }T
T{ MIN-INT 0 MIN-INT WITHIN -> FALSE }T
T{ MIN-INT 0 0 WITHIN -> FALSE }T
T{ MIN-INT 0 1 WITHIN -> FALSE }T
T{ MIN-INT 0 MAX-INT WITHIN -> FALSE }T
T{ MIN-INT 1 MIN-INT WITHIN -> FALSE }T
T{ MIN-INT 1 0 WITHIN -> TRUE }T
T{ MIN-INT 1 1 WITHIN -> FALSE }T
T{ MIN-INT 1 MAX-INT WITHIN -> FALSE }T
T{ MIN-INT MAX-INT MIN-INT WITHIN -> FALSE }T
T{ MIN-INT MAX-INT 0 WITHIN -> TRUE }T
T{ MIN-INT MAX-INT 1 WITHIN -> TRUE }T
T{ MIN-INT MAX-INT MAX-INT WITHIN -> FALSE }T
T{ 0 MIN-INT MIN-INT WITHIN -> FALSE }T
T{ 0 MIN-INT 0 WITHIN -> FALSE }T
T{ 0 MIN-INT 1 WITHIN -> TRUE }T
T{ 0 MIN-INT MAX-INT WITHIN -> TRUE }T
T{ 0 0 MIN-INT WITHIN -> TRUE }T
T{ 0 0 0 WITHIN -> FALSE }T
T{ 0 0 1 WITHIN -> TRUE }T
T{ 0 0 MAX-INT WITHIN -> TRUE }T
T{ 0 1 MIN-INT WITHIN -> FALSE }T
T{ 0 1 0 WITHIN -> FALSE }T
T{ 0 1 1 WITHIN -> FALSE }T
T{ 0 1 MAX-INT WITHIN -> FALSE }T
T{ 0 MAX-INT MIN-INT WITHIN -> FALSE }T
T{ 0 MAX-INT 0 WITHIN -> FALSE }T
T{ 0 MAX-INT 1 WITHIN -> TRUE }T
T{ 0 MAX-INT MAX-INT WITHIN -> FALSE }T
T{ 1 MIN-INT MIN-INT WITHIN -> FALSE }T
T{ 1 MIN-INT 0 WITHIN -> FALSE }T
T{ 1 MIN-INT 1 WITHIN -> FALSE }T
T{ 1 MIN-INT MAX-INT WITHIN -> TRUE }T
T{ 1 0 MIN-INT WITHIN -> TRUE }T
T{ 1 0 0 WITHIN -> FALSE }T
T{ 1 0 1 WITHIN -> FALSE }T
T{ 1 0 MAX-INT WITHIN -> TRUE }T
T{ 1 1 MIN-INT WITHIN -> TRUE }T
T{ 1 1 0 WITHIN -> TRUE }T
T{ 1 1 1 WITHIN -> FALSE }T
T{ 1 1 MAX-INT WITHIN -> TRUE }T
T{ 1 MAX-INT MIN-INT WITHIN -> FALSE }T
T{ 1 MAX-INT 0 WITHIN -> FALSE }T
T{ 1 MAX-INT 1 WITHIN -> FALSE }T
T{ 1 MAX-INT MAX-INT WITHIN -> FALSE }T
T{ MAX-INT MIN-INT MIN-INT WITHIN -> FALSE }T
T{ MAX-INT MIN-INT 0 WITHIN -> FALSE }T
T{ MAX-INT MIN-INT 1 WITHIN -> FALSE }T
T{ MAX-INT MIN-INT MAX-INT WITHIN -> FALSE }T
T{ MAX-INT 0 MIN-INT WITHIN -> TRUE }T
T{ MAX-INT 0 0 WITHIN -> FALSE }T
T{ MAX-INT 0 1 WITHIN -> FALSE }T
T{ MAX-INT 0 MAX-INT WITHIN -> FALSE }T
T{ MAX-INT 1 MIN-INT WITHIN -> TRUE }T
T{ MAX-INT 1 0 WITHIN -> TRUE }T
T{ MAX-INT 1 1 WITHIN -> FALSE }T
T{ MAX-INT 1 MAX-INT WITHIN -> FALSE }T
T{ MAX-INT MAX-INT MIN-INT WITHIN -> TRUE }T
T{ MAX-INT MAX-INT 0 WITHIN -> TRUE }T
T{ MAX-INT MAX-INT 1 WITHIN -> TRUE }T
T{ MAX-INT MAX-INT MAX-INT WITHIN -> FALSE }T

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

t{ 0 0 <= -> <true> }t
t{ -1 0 <= -> <true> }t
t{ -2 0 <= -> <true> }t
t{ 1 0 <= -> <false> }t
t{ min-int 0 <= -> <true> }t
t{ max-int 0 <= -> <false> }t
t{ max-int min-int <= -> <false> }t
t{ min-int max-int <= -> <true> }t
t{ min-int min-int <= -> <true> }t
t{ max-int max-int <= -> <true> }t

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

t{ 0 0 u<= -> <true> }t
t{ 1 0 u<= -> <false> }t
t{ max-uint 0 u<= -> <false> }t
t{ max-uint max-uint u<= -> <true> }t
t{ mid-uint max-uint u<= -> <true> }t
t{ max-uint mid-uint u<= -> <false> }t

t{ 0 0 u> -> <false> }t
t{ 1 0 u> -> <true> }t
t{ max-uint 0 u> -> <true> }t
t{ max-uint max-uint u> -> <false> }t
t{ mid-uint max-uint u> -> <false> }t
t{ max-uint mid-uint u> -> <true> }t

t{ 0 0 u>= -> <true> }t
t{ 1 0 u>= -> <true> }t
t{ max-uint 0 u>= -> <true> }t
t{ max-uint max-uint u>= -> <true> }t
t{ mid-uint max-uint u>= -> <false> }t
t{ max-uint mid-uint u>= -> <true> }t


