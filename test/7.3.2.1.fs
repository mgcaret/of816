testing 7.3.2.1 Single-precision integer arithmetic
T{ 0 5 + -> 5 }T
T{ 5 0 + -> 5 }T
T{ 0 -5 + -> -5 }T
T{ -5 0 + -> -5 }T
T{ 1 2 + -> 3 }T
T{ 1 -2 + -> -1 }T
T{ -1 2 + -> 1 }T
T{ -1 -2 + -> -3 }T
T{ -1 1 + -> 0 }T
T{ MID-UINT 1 + -> MID-UINT+1 }T

T{ 0 5 - -> -5 }T
T{ 5 0 - -> 5 }T
T{ 0 -5 - -> 5 }T
T{ -5 0 - -> -5 }T
T{ 1 2 - -> -1 }T
T{ 1 -2 - -> 3 }T
T{ -1 2 - -> -3 }T
T{ -1 -2 - -> 1 }T
T{ 0 1 - -> -1 }T

T{ MID-UINT+1 1 - -> MID-UINT }T
T{ 0 0 * -> 0 }T            \ TEST IDENTITIES
T{ 0 1 * -> 0 }T
T{ 1 0 * -> 0 }T
T{ 1 2 * -> 2 }T
T{ 2 1 * -> 2 }T
T{ 3 3 * -> 9 }T
T{ -3 3 * -> -9 }T
T{ 3 -3 * -> -9 }T
T{ -3 -3 * -> 9 }T
T{ MID-UINT+1 1 RSHIFT 2 * -> MID-UINT+1 }T
T{ MID-UINT+1 2 RSHIFT 4 * -> MID-UINT+1 }T
T{ MID-UINT+1 1 RSHIFT MID-UINT+1 OR 2 * -> MID-UINT+1 }T

\ U* is essentially the same code as *, abbreviate test

T{ 0 0 u* -> 0 }T            \ TEST IDENTITIES
T{ 0 1 u* -> 0 }T
T{ 1 0 u* -> 0 }T
T{ 1 2 u* -> 2 }T
T{ 2 1 u* -> 2 }T
T{ 3 3 u* -> 9 }T

T{ 0 1 / -> 0 1 T/ }T
T{ 1 1 / -> 1 1 T/ }T
T{ 2 1 / -> 2 1 T/ }T
T{ -1 1 / -> -1 1 T/ }T
T{ -2 1 / -> -2 1 T/ }T
T{ 0 -1 / -> 0 -1 T/ }T
T{ 1 -1 / -> 1 -1 T/ }T
T{ 2 -1 / -> 2 -1 T/ }T
T{ -1 -1 / -> -1 -1 T/ }T
T{ -2 -1 / -> -2 -1 T/ }T
T{ 2 2 / -> 2 2 T/ }T
T{ -1 -1 / -> -1 -1 T/ }T
T{ -2 -2 / -> -2 -2 T/ }T
T{ 7 3 / -> 7 3 T/ }T
T{ 7 -3 / -> 7 -3 T/ }T
T{ -7 3 / -> -7 3 T/ }T
T{ -7 -3 / -> -7 -3 T/ }T
T{ MAX-INT 1 / -> MAX-INT 1 T/ }T
T{ MIN-INT 1 / -> MIN-INT 1 T/ }T
T{ MAX-INT MAX-INT / -> MAX-INT MAX-INT T/ }T
T{ MIN-INT MIN-INT / -> MIN-INT MIN-INT T/ }T

T{ 0 2 1 */ -> 0 2 1 T*/ }T
T{ 1 2 1 */ -> 1 2 1 T*/ }T
T{ 2 2 1 */ -> 2 2 1 T*/ }T
T{ -1 2 1 */ -> -1 2 1 T*/ }T
T{ -2 2 1 */ -> -2 2 1 T*/ }T
T{ 0 2 -1 */ -> 0 2 -1 T*/ }T
T{ 1 2 -1 */ -> 1 2 -1 T*/ }T
T{ 2 2 -1 */ -> 2 2 -1 T*/ }T
T{ -1 2 -1 */ -> -1 2 -1 T*/ }T
T{ -2 2 -1 */ -> -2 2 -1 T*/ }T
T{ 2 2 2 */ -> 2 2 2 T*/ }T
T{ -1 2 -1 */ -> -1 2 -1 T*/ }T
T{ -2 2 -2 */ -> -2 2 -2 T*/ }T
T{ 7 2 3 */ -> 7 2 3 T*/ }T
T{ 7 2 -3 */ -> 7 2 -3 T*/ }T
T{ -7 2 3 */ -> -7 2 3 T*/ }T
T{ -7 2 -3 */ -> -7 2 -3 T*/ }T
T{ MAX-INT 2 MAX-INT */ -> MAX-INT 2 MAX-INT T*/ }T
T{ MIN-INT 2 MIN-INT */ -> MIN-INT 2 MIN-INT T*/ }T

T{ 0 1 MOD -> 0 1 TMOD }T
T{ 1 1 MOD -> 1 1 TMOD }T
T{ 2 1 MOD -> 2 1 TMOD }T
T{ -1 1 MOD -> -1 1 TMOD }T
T{ -2 1 MOD -> -2 1 TMOD }T
T{ 0 -1 MOD -> 0 -1 TMOD }T
T{ 1 -1 MOD -> 1 -1 TMOD }T
T{ 2 -1 MOD -> 2 -1 TMOD }T
T{ -1 -1 MOD -> -1 -1 TMOD }T
T{ -2 -1 MOD -> -2 -1 TMOD }T
T{ 2 2 MOD -> 2 2 TMOD }T
T{ -1 -1 MOD -> -1 -1 TMOD }T
T{ -2 -2 MOD -> -2 -2 TMOD }T
T{ 7 3 MOD -> 7 3 TMOD }T
T{ 7 -3 MOD -> 7 -3 TMOD }T
T{ -7 3 MOD -> -7 3 TMOD }T
T{ -7 -3 MOD -> -7 -3 TMOD }T
T{ MAX-INT 1 MOD -> MAX-INT 1 TMOD }T
T{ MIN-INT 1 MOD -> MIN-INT 1 TMOD }T
T{ MAX-INT MAX-INT MOD -> MAX-INT MAX-INT TMOD }T
T{ MIN-INT MIN-INT MOD -> MIN-INT MIN-INT TMOD }T

T{ 0 1 /MOD -> 0 1 T/MOD }T
T{ 1 1 /MOD -> 1 1 T/MOD }T
T{ 2 1 /MOD -> 2 1 T/MOD }T
T{ -1 1 /MOD -> -1 1 T/MOD }T
T{ -2 1 /MOD -> -2 1 T/MOD }T
T{ 0 -1 /MOD -> 0 -1 T/MOD }T
T{ 1 -1 /MOD -> 1 -1 T/MOD }T
T{ 2 -1 /MOD -> 2 -1 T/MOD }T
T{ -1 -1 /MOD -> -1 -1 T/MOD }T
T{ -2 -1 /MOD -> -2 -1 T/MOD }T
T{ 2 2 /MOD -> 2 2 T/MOD }T
T{ -1 -1 /MOD -> -1 -1 T/MOD }T
T{ -2 -2 /MOD -> -2 -2 T/MOD }T
T{ 7 3 /MOD -> 7 3 T/MOD }T
T{ 7 -3 /MOD -> 7 -3 T/MOD }T
T{ -7 3 /MOD -> -7 3 T/MOD }T
T{ -7 -3 /MOD -> -7 -3 T/MOD }T
T{ MAX-INT 1 /MOD -> MAX-INT 1 T/MOD }T
T{ MIN-INT 1 /MOD -> MIN-INT 1 T/MOD }T
T{ MAX-INT MAX-INT /MOD -> MAX-INT MAX-INT T/MOD }T
T{ MIN-INT MIN-INT /MOD -> MIN-INT MIN-INT T/MOD }T

T{ 0 2 1 */MOD -> 0 2 1 T*/MOD }T
T{ 1 2 1 */MOD -> 1 2 1 T*/MOD }T
T{ 2 2 1 */MOD -> 2 2 1 T*/MOD }T
T{ -1 2 1 */MOD -> -1 2 1 T*/MOD }T
T{ -2 2 1 */MOD -> -2 2 1 T*/MOD }T
T{ 0 2 -1 */MOD -> 0 2 -1 T*/MOD }T
T{ 1 2 -1 */MOD -> 1 2 -1 T*/MOD }T
T{ 2 2 -1 */MOD -> 2 2 -1 T*/MOD }T
T{ -1 2 -1 */MOD -> -1 2 -1 T*/MOD }T
T{ -2 2 -1 */MOD -> -2 2 -1 T*/MOD }T
T{ 2 2 2 */MOD -> 2 2 2 T*/MOD }T
T{ -1 2 -1 */MOD -> -1 2 -1 T*/MOD }T
T{ -2 2 -2 */MOD -> -2 2 -2 T*/MOD }T
T{ 7 2 3 */MOD -> 7 2 3 T*/MOD }T
T{ 7 2 -3 */MOD -> 7 2 -3 T*/MOD }T
T{ -7 2 3 */MOD -> -7 2 3 T*/MOD }T
T{ -7 2 -3 */MOD -> -7 2 -3 T*/MOD }T
T{ MAX-INT 2 MAX-INT */MOD -> MAX-INT 2 MAX-INT T*/MOD }T
T{ MIN-INT 2 MIN-INT */MOD -> MIN-INT 2 MIN-INT T*/MOD }T

T{ 0 1 u/MOD -> 0 1 T/MOD }T
T{ 1 1 u/MOD -> 1 1 T/MOD }T
T{ 2 1 u/MOD -> 2 1 T/MOD }T
T{ 2 2 u/MOD -> 2 2 T/MOD }T
T{ 7 3 u/MOD -> 7 3 T/MOD }T
T{ MAX-INT 1 u/MOD -> MAX-INT 1 T/MOD }T
T{ MAX-INT MAX-INT u/MOD -> MAX-INT MAX-INT T/MOD }T

T{ 0 1+ -> 1 }T
T{ -1 1+ -> 0 }T
T{ 1 1+ -> 2 }T
T{ MID-UINT 1+ -> MID-UINT+1 }T

T{ 2 1- -> 1 }T
T{ 1 1- -> 0 }T
T{ 0 1- -> -1 }T
T{ MID-UINT+1 1- -> MID-UINT }T

t{ 1 2+ -> 3 }t
t{ -2 2+ -> 0 }t

t{ 2 2- -> 0 }t
t{ 0 2- -> -2 }t

T{ 0 ABS -> 0 }T
T{ 1 ABS -> 1 }T
T{ -1 ABS -> 1 }T
T{ MIN-INT ABS -> MID-UINT+1 }T

T{ 0 NEGATE -> 0 }T
T{ 1 NEGATE -> -1 }T
T{ -1 NEGATE -> 1 }T
T{ 2 NEGATE -> -2 }T
T{ -2 NEGATE -> 2 }T

T{ 0 1 MAX -> 1 }T
T{ 1 2 MAX -> 2 }T
T{ -1 0 MAX -> 0 }T
T{ -1 1 MAX -> 1 }T
T{ MIN-INT 0 MAX -> 0 }T
T{ MIN-INT MAX-INT MAX -> MAX-INT }T
T{ 0 MAX-INT MAX -> MAX-INT }T
T{ 0 0 MAX -> 0 }T
T{ 1 1 MAX -> 1 }T
T{ 1 0 MAX -> 1 }T
T{ 2 1 MAX -> 2 }T
T{ 0 -1 MAX -> 0 }T
T{ 1 -1 MAX -> 1 }T
T{ 0 MIN-INT MAX -> 0 }T
T{ MAX-INT MIN-INT MAX -> MAX-INT }T
T{ MAX-INT 0 MAX -> MAX-INT }T

T{ 0 1 MIN -> 0 }T
T{ 1 2 MIN -> 1 }T
T{ -1 0 MIN -> -1 }T
T{ -1 1 MIN -> -1 }T
T{ MIN-INT 0 MIN -> MIN-INT }T
T{ MIN-INT MAX-INT MIN -> MIN-INT }T
T{ 0 MAX-INT MIN -> 0 }T
T{ 0 0 MIN -> 0 }T
T{ 1 1 MIN -> 1 }T
T{ 1 0 MIN -> 0 }T
T{ 2 1 MIN -> 1 }T
T{ 0 -1 MIN -> -1 }T
T{ 1 -1 MIN -> -1 }T
T{ 0 MIN-INT MIN -> MIN-INT }T
T{ MAX-INT MIN-INT MIN -> MIN-INT }T
T{ MAX-INT 0 MIN -> 0 }T

t{ 0 5 bounds -> 5 0 }t
t{ 5 10 bounds -> 15 5 }t

t{ 1 even -> 2 }t
t{ 2 even -> 2 }t
t{ -1 even -> 0 }t
t{ 0 even -> 0 }t

