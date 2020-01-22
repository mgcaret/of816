# Forth Dictionary

Updated: 2020-01-21 23:40:51 -0800

## !

_( n c-addr -- )_ write cell n to c-addr

## "

- Immediate.

_( "text"<"> -- c-addr u )_ parse string, including hex interpolation

## \#

_( ud1 -- ud2 )_ divide ud1 by BASE, convert remainder to char and HOLD it, ud2 = quotient

## #>

_( ud -- )_ conclude pictured numeric output

## #IN

_( -- addr )_ Variable containing number of chars in the current input buffer.

## #LINE

_( -- addr )_ Variable containing the number of lines output.

## #OUT

_( -- addr )_ variable containing the number of chars output on the current line.

## #S

_( ud -- 0 )_ perform # until quotient is zero

## $2VALUE

_( n1 n2 str len -- )_ create a definition that pushes the first two cells of the body
initially n1 and n2

## $BYTE-EXEC

_( addr xt -- )_ evaluate FCode at addr with fetch function xt, do not save FCode
evaluator state

## $CREATE

_( c-addr u -- )_ like CREATE but use c-addr u for name

## $DIRECT

_( -- addr )_ addr = address of the CPU direct page

## $EMPTY-WL

_( -- wid )_ create a new empty wordlist (danger!)

## $ENV?-WL

_( -- wid )_ Return the WID of the wordlist for environmental queries.

## $FIND

_( c-addr u -- xt true | c-addr u false )_ find word in search order

## $FORGET

_( xt -- )_ forget word referenced by xt and subsequent words

## $HEX(

- Immediate.

_( "text"<rparen> -- c-addr u )_ parse hex, return in allocated string

## $MEMTOP

_( -- addr )_ addr = top of usable data space

## $NUMBER

_( addr len -- true | n false )_ attmept to convert string to number

## $RESTORE-INPUT

## $SEARCH

_( c-addr u -- 0 | xt +-1 )_ search for word in current search order

## $SOURCE-ID

_( -- a-addr )_ variable containing current input source ID

## $SYSIF

_( ... u -- ... )_ call system interface function u

## $TMPSTR

Allocate a temporary string buffer for interpretation semantics of strings
and return the address and length of the buffer.  If taking the slot used
by an existing buffer, free it.

## $VALUE

_( n str len -- )_ create a definition that pushes the first cell of the body, initially n

## '

_( old-name<> -- xt )_ parse old-name in input stream, return xt of word

## (

- Immediate.

_( "text"<rparen> -- )_ parse and discard text until a right paren or end of input

## (.)

_( n -- c-addr u )_ convert n to text via pictured numeric output

## (CR

_( -- )_ emit a CR with no linefeed, set #OUT to 0

## (IS-USER-WORD)

_( str len xt -- )_ create a DEFER definition for string with xt as its initial behavior

## (SEE)

_( xt -- )_ attempt to decompile the word at xt

## (U.)

_( u -- c-addr u )_ convert u to text via pictured numeric output

## *

_( n1 n2 -- n3 )_ n3 = n1*n2

## */

_( n1 n2 n3 -- n4 )_ n4 = symmetric quot of n1*n2/n3 

## */MOD

_( n1 n2 n3 -- n4 n5 )_ n4, n5 = symmetric rem, quot of n1*n2/n3 

## +

_( n1 n2 -- n3 )_ n3 = n1+n2

## +!

_( n c-addr -- )_ add n to value at c-addr

## +LOOP

- Immediate.
- Compile-only.

Compilation: _( C: do-sys -- )_

Execution: _( u|n -- )_ add u|n to loop index and continue loop if within bounds

## ,

_( n -- )_ compile cell n into the dictionary

## -

_( n1 n2 -- n3 )_ n3 = n1-n2

## -1

_( -- -1 )_

## -ROT

_( n1 n2 n3 -- n3 n1 n2 )_

## -TRAILING

_( c-addr u1 -- c-addr u2 )_ u2 = length of string with trailing spaces omitted

## .

_( n -- )_ output n

## ."

- Immediate.

_( "text"<"> -- )_ output parsed text

## .(

- Immediate.

_( "text"<rparen> -- )_ parse text until a right paren or end of input, output text

## .D

_( n -- )_ output n in decimal base

## .H

_( n -- )_ output n in hexadecimal base

## .R

_( n u -- )_ output n in a field of u chars

## .S

_( -- )_ display stack contents

## .VERSION

_( -- )_ Display version information.

## /

_( n1 n2 -- n3 )_ symmetric divide n1 by n2, giving quotient n3

## /C

_( -- u )_ u = size of char in bytes.

## /C*

_( n1 -- n2 )_ n2 = n1 * size of char.

## /L

_( -- u )_ u = size of long in bytes.

## /L*

_( n1 -- n2 )_ n2 = n1 * size of long.

## /MOD

_( n1 n2 -- n3 n4 )_ symmetric divide n1 by n2, giving quotient n4 and remainder n3

## /N

_( -- u )_ u = size of cell in bytes.

## /N*

_( n1 -- n2 )_ n2 = n1 * size of cell.

## /STRING

_( c-addr1 u1 n -- c-addr2 u2 )_ adjust string

## /W

_( -- u )_ u = size of word in bytes.

## /W*

_( n1 -- n2 )_ n2 = n1 * size of word.

## 0

_( -- 0 )_

## 0<

_( n -- f )_ f = true if x < 0, false if not

## 0<=

_( n -- f )_ f = true if x <= 0, false if not

## 0<>

_( n -- f )_ f = false if x is zero, true if not

## 0=

_( n -- f )_ f = true if x is zero, false if not

## 0>

_( n -- f )_ f = true if x > 0, false if not

## 0>=

_( n -- f )_ f = true if x >= 0, false if not

## 1

_( -- 1 )_

## 1+

_( n -- n' )_ increment top stack item

## 1-

_( n -- n' )_ decrement top stack item

## 2

_( -- 2 )_

## 2!

_( n1 n2 c-addr -- )_ write consecutive cells n1 and n2 to c-addr

## 2*

_( n -- n' )_ shift n1 one bit left

## 2+

_( n -- n' )_ increment top stack item by 2

## 2-

_( n -- n' )_ decrement top stack item by 2

## 2/

_( n -- n' )_ shift n1 one bit right, extending sign bit

## 2>R

_( n1 n2 -- )_ _(R: -- n1 n2 )_

## 2@

_( c-addr -- n1 n2 )_ fetch two consecutive cells from c-addr

## 2CONSTANT

_( n1 n2 "name"<> -- )_ create name, name does _( -- n1 n2 )_ when executed

## 2DROP

_( n1 n2 -- )_

## 2DUP

_( n1 n2 -- n1 n2 n3 n4 )_ n3 = n1, n4 = n2

## 2OVER

_( x1 x2 x3 x4 -- x1 x2 x3 x4 x5 x6 )_ x5 = x1, x6 = x2

## 2R>

_( R: n1 n2 -- )_ _( -- n1 n2 )_

## 2R@

_( R: n1 n2 -- n1 n2 )_ _( -- n1 n2 )_

## 2ROT

_( x1 x2 x3 x4 x5 x6 -- x3 x4 x5 x6 x1 x2 )_

## 2S>D

_( n n -- d d )_ convert two numbers to double-numbers

## 2SWAP

_( x1 x2 x3 x4 -- x3 x4 x1 x2 )_

## 3

_( -- 3 )_

## 3DROP

_( n1 n2 n3 -- )_

## 3DUP

_( n1 n2 n3 -- n1 n2 n3 n4 n5 n6 )_ n4 = n1, n5 = n2, n6 = n3

## :

_( "name"<> -- colon-sys )_ parse name, create colon definition and enter compiling state

## :NONAME

_( -- colon-sys )_ Create an anonymous colon definition and enter compiling state.
The xt of the anonymous definition is left on the stack after ;.

## :TEMP

_( -- colon-sys )_ Create a temporary anonymous colon definition and enter
compiling state.  The temporary definition is executed immediately after ;

## ;

- Immediate.
- Compile-only.

_( colon-sys -- )_ consume colon-sys and enter interpretation state, ending the current
definition.  If the definition was temporary, execute it.

## ;CODE

- Immediate.
- Compile-only.

_( -- )_ end compiler mode, begin machine code section of definition

## ;]

- Immediate.
- Compile-only.

_( C: quot-sys -- )_ _( R: -- xt )_ End a quotation.  During executon,
leave xt of the quotation on the stack.

## \<

_( n1 n2 -- f )_ f = true if n1 < n2, false if not

## \<#

_( -- )_ begin pictured numeric output

## \<<

_( n1 n2 -- n3 )_ n3 = n1 << n2

## \<=

_( n1 n2 -- f )_ f = true if n1 <= n2, false if not

## \<>

_( n1 n2 -- f )_ f = true if n1 <> n2, false if not

## \<W@

_( c-addr -- n )_ fetch sign-extended word from c-addr

## =

_( n1 n2 -- f )_ f = true if n1 = n2, false if not

## \>

_( n1 n2 -- f )_ f = true if n1 > n2, false if not

## \>=

_( n1 n2 -- f )_ f = true if n1 >= n2, false if not

## \>>

_( n1 n2 -- n3 )_ n3 = n1 >> n2

## \>>A

_( n1 n2 -- n3 )_ n3 = n1 >> n2, extending sign bit

## \>BODY

_( xt -- a-addr)_ return body of word at xt, if unable then throw exception -31

## \>IN

_( -- addr )_ Variable containing offset to the current parsing area of input buffer.

## \>LINK

_( xt -- addr|0 )_ get link field of function at xt or 0 if none

## \>NAME

_( xt -- c-addr u )_ get string name of function at xt, or ^xt if anonymous/noname

## \>NUMBER

_( ud1 c-addr1 u1 -- ud2 c-addr2 u2 )_ convert text to number

## \>R

_( n -- )_ _(R: -- n )_

## \>R@

_( n -- n )_ _( R: -- n )_

## ?

_( a-addr -- )_ output signed contents of cell at a-addr

## ?DO

- Immediate.
- In interpretation state, starts temporary definition.

Compilation: _( -- )_ _( R: -- do-sys )_

Execution: _( limit start -- )_ begin DO loop, skip if limit=start

## ?DUP

_( n -- n )_ if n = 0, else _( n1 -- n1 n2 )_ n2 = n1

## ?LEAVE

- Compile-only.

_( f -- )_ exit loop if f is nonzero

## @

_( c-addr -- n )_ fetch cell from c-addr

## A"

_( "text"<"> -- c-addr u )_ parse quoted text in input buffer, copy to allocated string

## ABORT

_( -- )_ Execute -1 THROW.

## ABORT"

- Immediate.

Compilation/Interpretation: _( [text<">] -- )_

Execution: _( f -- )_
If f is true, display text and execute -2 THROW.

## ABS

_( n -- n' )_ take the absolute value of n

## ACCEPT

_( addr len -- u )_ get input line of up to len chars, stor at addr, u = # chars accepted

## ACONCAT

_( c-addr1 u1 c-addr2 u2 -- c-addr3 u1+u2 )_ Concatenate allocated strings,
freeing the originals.

## AGAIN

- Immediate.
- Compile-only.

_( C: dest -- )_ _( R: -- )_ resolve dest, jump to BEGIN

## AHEAD

- Immediate.
- In interpretation state, starts temporary definition.

_( C: orig ) ( E: -- )_ jump ahead as resolved by e.g. THEN

## ALIAS

_( "name1"<> "name2"<> -- )_ create name1, name1 is a synonym for name2

## ALIGN

_( u -- u )_ align u (no-op in this implementation)

## ALIGNED

_( u1 -- u2 )_ u2 = next aligned address after u1.

## ALLOC-MEM

_( u -- c-addr )_ Allocate memory from heap.

## ALLOT

_( n -- )_ allocate n bytes in the dictionary

## ALSO

_( -- )_ Fuplicate the first wordlist in the search order.

## AND

_( n1 n2 -- n3 )_ n3 = n1 & n2

## ASCII

- Immediate.

_( "word"<> -- char )_ perform either CHAR or [CHAR] per the current compile state

## AT-XY

_( u1 u2 -- )_ place cursor at col u1 row u2 (uses ANSI escape sequence)

## BASE

_( -- a-addr )_ System BASE variable.

## BEGIN

- Immediate.
- In interpretation state, starts temporary definition.

_( C: -- dest )_ _( E: -- )_ start a BEGIN loop

## BEHAVIOR

_( "name"<> -- )_ return the first cell of the body of name, which should be a DEFER word

## BELL

_( -- <bel> )_

## BETWEEN

_( n1|u1 n2|u2 n3|u3 -- f )_ f =  true if n2|u2 <= n1|u1 <= n3|u3, false otherwise

## BINARY

_( -- )_ store 2 to BASE

## BL

_( -- ' ' )_

## BLANK

_( addr len -- )_ fill memory with spaces

## BLJOIN

_( b.l b2 b3 b.h -- q )_ Join bytes into quad.

## BODY>

_( a-addr -- xt )_ return xt of word with body at a-addr, if unable throw exc. -31

## BOUNDS

_( n1 n2 -- n1+n2 n1 )_

## BS

_( -- <bs> )_

## BSX

_( byte -- sign-extended )_

## BUFFER:

_( n -- )_ allocate memory immediately, create definition that returns address of memory

## BWJOIN

_( b.l b.h -- w )_ Join bytes into word.

## BYE

_( -- )_ Restore system stack pointer and exit Forth.

## BYTE-LOAD

_( addr xt -- )_ sav state, evaluate FCode at addr with fetch function xt, restore state

## C!

_( char c-addr -- )_ write char n to c-addr

## C,

_( char -- )_ compile char into dictionary

## C;

_( code-sys -- )_ consume code-sys, end CODE or LABEL definition

## C@

_( c-addr -- char )_ fetch char from c-addr

## CA+

_( u1 n -- u2 )_ u2 = u1 + n * size of char in bytes.

## CA1+

_( n1 -- n2 )_ n2 = n1 + size of char.

## CARRET

_( -- <cr> )_

## CASE

- Immediate.
- In interpretation state, starts temporary definition.

Compilation: _( R: -- case-sys )_ start a CASE...ENDCASE structure

Execution: _( -- )_

## CATCH

_( xt -- xi ... xj n|0 )_ Call xt, trap exception, and return it in n.

## CELL+

_( u1 -- u2 )_ u2 = u1 + size of cell in bytes.

## CELLS

_( n1 -- n2 )_ n2 = n1 * size of cell.

## CHAR

_( "word"<> -- char )_ parse word from input stream, return value of first char

## CHAR+

_( u1 -- u2 )_ u2 = u1 + size of char in bytes.

## CHARS

_( n1 -- n2 )_ n2 = n1 * size of char.

## CICOMP

_( addr1 addr2 u1 -- n1 )_ case-insensitive compare two strings of length u1 

## CLEAR

_( n1 ... nx -- )_ empty stack

## CMOVE

_( addr1 addr2 len -- )_ move startomg from the bottom

## CMOVE>

_( addr1 addr2 len -- )_ move starting from the top

## CODE

_( "name"<> -- code-sys )_ create a new CODE definiion

## COMP

_( addr1 addr2 u1 -- n1 )_ compare two strings of length u1 

## COMPARE

_( addr1 u1 addr2 u2 -- n1 )_ compare two strings

## COMPILE

- Immediate.
- Compile-only.

_( -- )_ Compile code to compile the immediately following word.  Better to use POSTPONE.

## COMPILE,

- Immediate.

_( xt -- )_ compile xt into the dictionary

## CONSTANT

_( n "name"<> -- )_ alias of VALUE, OF816 doesn't have true constants

## CONTEXT

_( -- wid )_ Return first wordlist in search order.

## CONTROL

- Immediate.

( "name"<> ) parse name, place low 5 bits of first char on stack, if compiling stat
compile it as a literal

## COUNT

_( c-addr -- c-addr+1 u )_ count packed string at c-addr

## CPEEK

_( addr -- char true )_ access memory at addr, returning char

## CPOKE

_( char addr -- true )_ store char at addr

## CR

_( -- )_ emit a CR/LF combination, set increment #LINE

## CREATE

_( "name"<> -- )_ create a definition, when executed pushes the body address

## D#

- Immediate.

_( "#"<> -- n | -- )_ parse following number as decimal, compile as literal if compiling

## D+

_( d1 d2 -- d3 )_ d3 = d1+d2

## D-

_( d1 d2 -- d3 )_ d3 = d1-d2

## D.

_( d -- )_ output d

## D.R

_( d u -- )_ output d in a field of u chars

## D>S

_( d -- n )_ convert double-number to number

## DABS

_( d -- d' )_ take the absolute value of d

## DEBUG-MEM

_( -- )_ Display heap and temporary string information.

## DECIMAL

_( -- )_ store 10 to BASE

## DEFER

_( "name"<> -- )_ create definition that executes the first word of the body as an xt

## DEFINITIONS

_( -- )_ Set the compiler wordlist to the first wordlist in the search order.

## DEPTH

_( n1 ... nx -- n1 ... nx x )_

## DIGIT

_( char base -- digit true | char false )_ attempt to convert char to digit

## DNEGATE

_( d -- d' )_ negate d

## DO

- Immediate.
- In interpretation state, starts temporary definition.

Compilation: _( -- )_ _( R: -- do-sys )_

Execution: _( limit start -- )_ begin DO loop

## DOES>

- Immediate.
- Compile-only.

_( -- )_ alter execution semantics of most recently-created definition to perform
the following execution semantics.

## DROP

_( n1 -- )_

## DUMP

_( addr len -- )_ dump memory

## DUP

_( n1 -- n1 n2 )_ n2 = n1

## ELSE

- Immediate.
- Compile-only.

_( C: if-sys -- else-sys )_ _( E: -- )_ ELSE clause of IF ... ELSE ... THEN

## EMIT

_( char -- )_ Output char.

## END-CODE

- Immediate.
- Compile-only.

_( code-sys -- )_ synonym for C;

## ENDCASE

- Immediate.
- Compile-only.

Compilation: _( case-sys -- )_  conclude a CASE...ENDCASE structure

Execution: _( | n -- )_ continue execution, dropping n if no OF matched

## ENDOF

- Immediate.
- Compile-only.

Compilation; _( case-sys of-sys -- case-sys )_ conclude an OF...ENDOF structure

Execution: Continue execution at ENDCASE of case-sys

## ENVIRONMENT?

_( c-addr u -- xn...x1 t | f )_ environmental query

## ERASE

_( addr len -- )_ zero fill memory with spaces

## EVAL

synonym for EVALUATE

## EVALUATE

_( xxn...xx1 c-addr u -- yxn...yx1 )_ interpret text in c-addr u

## EVEN

_( n1 -- n2 )_ if n1 is odd, n2=n1+1, otherwise n2=n1

## EXECUTE

_( xt -- )_ execute xt, regardless of its flags

## EXIT

- Compile-only.

## EXIT?

_( -- f )_ If #LINE >= 20, prompt user to continue and return false if they want to.

## EXPECT

_( addr len -- )_ get input line of up to len chars, stor at addr, actual len in SPAN

## FALSE

_( -- false )_ false = all zero bits

## FCODE-REVISION

_( -- u )_ Return FCode revision

## FERROR

_( -- )_ display FCode IP and byte, throw exception -256

## FIELD

_( offset size "name"<> -- offset+size )_ create name, name exec: _( addr -- addr+offset)_

## FILL

_( addr len char -- )_ fill memory with char

## FIND

_( c-addr -- xt )_ find packed string word in search order, 0 if not found

## FM/MOD

_( d n1 -- n2 n3 )_ floored divide d by n1, giving quotient n3 and remainder n2

## FORGET

_( "name"<> -- )_ attempt to forget name and subsequent definitions in compiler
word list.  This may have unintended consequences if things like wordlists and
such were defined after name.

## FORTH

_( -- )_ Set the first wordlist in the search order to the system words

## FORTH-WORDLIST

_( -- wid )_ Return the WID of the wordlist containing system words.

## FREE-MEM

_( c-addr u -- )_ Release memory to heap, u is currently ignored.

## GET-CURRENT

_( -- wid )_ Get WID current compiler wordlist.

## GET-ORDER

_( -- widn ... wid1 u )_ Get dictionary search order.

## GET-TOKEN

_( fcode# -- xt f )_ get fcode#'s xt and immediacy

## H#

- Immediate.

_( "#"<> -- n | -- )_ parse following number as hex, compile as literal if compiling

## HERE

_( -- c-addr )_ return dictionary pointer

## HEX

_( -- )_ store 16 to BASE

## HOLD

_( c -- )_ place c in pictured numeric output

## I

- Compile-only.

_( -- n )_ copy inner loop index to stack

## IF

- Immediate.
- In interpretation state, starts temporary definition.

_( C: if-sys ) ( E: n -- )_ begin IF ... ELSE ... ENDIF

## IMMEDIATE

_( -- )_ mark last compiled word as an immediate word

## INVERT

_( x -- x' )_ invert the bits in x

## J

- Compile-only.

_( -- n )_ copy second-inner loop index to stack

## KEY

_( -- char )_ wait for input char, return it

## KEY?

_( -- f )_ f = true if input char is ready, false otherwise

## L!

_( n c-addr -- )_ write cell n to c-addr

## L,

_( q -- )_ compile quad into the dictionary

## L@

_( c-addr -- n )_ fetch cell from c-addr

## LA+

_( u1 n -- u2 )_ u2 = u1 + n * size of long in bytes.

## LA1+

_( n1 -- n2 )_ n2 = n1 + size of long.

## LABEL

_( "name"<> -- code-sys )_ create a new LABEL definition

## LAST

## LBFLIP

_( q -- q' )_ Flip the byte order of quad.

## LBFLIPS

_( addr len -- )_ perform LBFLIP on the cells in memory

## LBSPLIT

_( u -- u1 ... u4 )_ u1 ... u4 = bytes of u.

## LCC

_( char -- char' )_ lower case convert char

## LEAVE

- Compile-only.

_( -- )_ exit loop

## LEFT-PARSE-STRING

_( str len char -- r-str r-len l-str l-len )_ parse string for char, returning
the left and right sides

## LINEFEED

_( -- <lf> )_

## LITERAL

- Immediate.

_( n -- )_ compile numeric literal n into dictionary, leave n on stack at execution

## LOOP

- Immediate.
- Compile-only.

Compilation: _( C: do-sys -- )_

Execution: _( -- )_ add 1 to loop index and continue loop if within bounds

## LPEEK

_( addr -- cell true )_ access memory at addr, returning cell

## LPOKE

_( cell addr -- true )_ store cell at addr

## LSHIFT

_( n1 n2 -- n3 )_ n3 = n1 << n2

## LWFLIP

_( q -- q )_ Flip the word order of quad.

## LWFLIPS

_( addr len -- )_ perform LWFLIP on the cells in memory

## LWSPLIT

_( u -- u1 ... u2 )_ u1 ... u2 = words of u.

## M*

_( n1 n2 -- d )_ d = n1*n2

## MAX

_( n1 n2 -- n1|n2 )_ return the greater of n1 or n2

## MIN

_( n1 n2 -- n1|n2 )_ return the smaller of n1 or n2

## MOD

_( n1 n2 -- n3 )_ symmetric divide n1 by n2, giving remainder n3

## MOVE

_( addr1 addr2 len -- )_ move memory

## N>R

_( x1 ... xn n -- n )_ _( R: x1 ... xn -- )_

## NA+

_( u1 n -- u2 )_ u2 = u1 + n * size of cell in bytes.

## NA1+

_( n1 -- n2 )_ n2 = n1 + size of cell.

## NEGATE

_( n -- n' )_ negate n

## NIP

_( n1 n2 -- n2 )_

## NOOP

_( -- )_ Do nothing.

## NOSHOWSTACK

_( -- )_ assuming STATUS is a defer, set it to NOOP

## NOT

_( x -- x' )_ invert the bits in x

## NR>

_( R: x1 ... xn -- )_ _( n -- x1 ... xn n )_

## O#

- Immediate.

_( "#"<> -- n | --)_ parse following number as octal, compile as literal if compiling

## OCTAL

_( -- )_ store 8 to BASE

## OF

- Immediate.
- Compile-only.

Compilation: _( case-sys -- case-sys of-sys )_ begin an OF...ENDOF structure

Execution: _( x1 x2 -- | x1 )_ execute OF clause if x1 = x2, leave x1 on stack if not

## OFF

_( c-addr -- )_ store all zero bits to cell at c-addr

## ON

_( c-addr -- )_ store all one bits to cell at c-addr

## ONLY

_( -- )_ Set the search order to contain only the system wordlist.

## OR

_( n1 n2 -- n3 )_ n3 = n1 | n2

## ORDER

_( -- )_ Display the current search order and compiler wordlist.

## OVER

_( n1 n2 -- n1 n2 n3 )_ n3 = n1

## PACK

_( str len addr -- addr )_ pack string into addr, similar to PLACE in some Forths

## PAD

_( -- a-addr )_ return address of PAD

## PAGE

_( -- )_ clear screen & home cursor (uses ANSI escape sequence)

## PARSE

_( char "word"<char> -- c-addr u )_ parse word from input stream, delimited by char

## PARSE-2INT

_( str len -- val.lo val.hi )_ parse two integers from string in the form "n2,n2"

## PARSE-NAME

_( "word"<> -- c-addr u )_ alias of PARSE-WORD

## PARSE-WORD

_( "word"<> -- c-addr u )_ parse word from input stream, return address and length

## PICK

_( x1 ... xn u -- x1 ... xn x(n-u)_ )

## POSTPONE

- Immediate.

_( "name"<> -- )_  

## PREVIOUS

_( -- )_ Remove the first wordlist in the search order.

## QUIT

_( -- )_ _( R: ... -- )_ enter outer interpreter loop, aborting any execution

## R+1

_( R: n -- n' )_ n' = n + 1

## R>

_( R: n -- )_ _( -- n )_

## R@

_( R: n -- n )_ _( -- n )_

## RB!

- Immediate.

_( byte addr -- )_ perform FCode-equivalent RB!: store byte

## RB@

- Immediate.

_( addr -- byte )_ perform FCode-equivalent RB@: fetch byte

## RDROP

_( R: n -- )_

## RECURSE

- Immediate.
- Compile-only.

_( -- )_ compile the execution semantics of the most recently-created definition

## RECURSIVE

- Immediate.
- Compile-only.

_( -- )_ make the current definition findable during compilation

## REFILL

_( -- f )_ refill input buffer, f = true if that worked, false if not

## REPEAT

- Immediate.
- Compile-only.

_( C: orig dest -- )_ _(R: -- )_ resolve orig and dest, repeat BEGIN loop

## RESET-ALL

_( -- )_ Reset the system.

## RESTORE-INPUT

## RL!

- Immediate.

_( cell addr -- )_ perform FCode-equivalent RL!, store cell

## RL@

- Immediate.

_( addr -- cell )_ perform FCode-equivalent RL@: fetch cell

## ROLL

_( xu ... x0 u -- xu-1 .. x0 xu )_

## ROT

_( n1 n2 n3 -- n2 n3 n1 )_

## RSHIFT

_( n1 n2 -- n3 )_ n3 = n1 >> n2

## RW!

- Immediate.

_( word addr -- )_ perform FCode-equivalent RW!: store word

## RW@

- Immediate.

_( addr -- word )_ perform FCode-equivalent RW@: fetch word

## S"

- Immediate.

_( "text"<"> -- c-addr u )_

## S.

_( n -- )_ output n

## S>D

_( n -- d )_ convert number to double-number

## SAVE-INPUT

## SEAL

_( -- )_ Set the search order to contain only the current top of the order.

## SEARCH

_( c-addr1 u1 c-addr2 u2 -- c-addr3 u3 flag )_

## SEARCH-WORDLIST

_( c-addr u wid -- 0 | xt +-1 )_ search wordlist for word

## SEE

_( "name"<> -- )_ attempt to decompile name

## SET-CURRENT

_( wid -- )_ Set the compiler wordlist.

## SET-ORDER

_( widn ... wid1 n -- )_ Set dictionary search order.

## SET-TOKEN

_( xt fcode# f -- )_ set fcode# to execute xt, immediacy f

## SHOWSTACK

_( -- )_ assuming STATUS is a defer, set it to .S

## SIGN

_( n -- )_ place - in pictured numeric output if n is negative

## SIGNUM

_( n -- s )_ s = -1 if n is negative, 0 if 0, 1 if positive

## SLITERAL

- Immediate.
- Compile-only.

C: _( c-addr1 u -- )_ R: _( -- c-addr 2 u )_ compile string literal into current def

## SM/REM

_( d n1 -- n2 n3 )_ symmetric divide d by n1, giving quotient n3 and remainder n2

## SOURCE

_( -- c-addr u )_ return address and length of input source buffer

## SOURCE-ID

_( -- n )_ return current input source id (0 = console, -1 = string, >0 = file)

## SPACE

_( -- )_ emit a space

## SPACES

_( u -- )_ emit u spaces

## SPAN

## SQRTREM

_( u1 -- u2 u3 )_ u2 = closest square root <= to the true root, u3 = remainder

## STATE

_( -- a-addr )_ STATE variable, zero if interpreting.

## STRUCT

_( -- 0 )_

## SWAP

_( n1 n2 -- n2 n1 )_

## THEN

- Immediate.
- Compile-only.

_( C: if-sys|else-sys -- )_ _( E: -- )_

## THROW

_( n -- )_ Throw exception n if n <> 0.

## TO

- Immediate.

_( n "name"<> -- )_ change the first cell of the body of xt to n.  Can be used on
most words created with CREATE, DEFER, VALUE, etc.  even VARIABLE

## TRUE

_( -- true )_ true = all one bits

## TUCK

_( n1 n2 -- n3 n1 n2 )_ n3 = n2

## TYPE

_( addr u -- )_ Output string.

## U#

_( u1 -- u2 )_ divide u1 by BASE, convert remainder to char and HOLD it, u2 = quotient

## U#>

_( u -- )_ conclude pictured numeric output

## U#S

_( u -- 0 )_ perform U# until quotient is zero

## U*

_( u1 u2 -- u3 )_ u3 = u1*u2

## U.

_( u -- )_ output u

## U.0

_( u1 -- )_ output u1 with no trailing space

## U.R

_( u1 u2 -- )_ output u1 in a field of u2 chars

## U/MOD

_( u1 u2 -- u3 u4 )_ divide u1 by u2, giving quotient u4 and remainder u3

## U2/

_( n -- n' )_ shift n1 one bit right

## U<

_( u1 u2 -- f )_ f = true if u1 < u2, false if not

## U<=

_( u1 u2 -- f )_ f = true if u1 <= u2, false if not

## U>

_( u1 u2 -- f )_ f = true if u1 > u2, false if not

## U>=

_( u1 u2 -- f )_ f = true if u1 >= u2, false if not

## UD/MOD

_( d1 n1 -- d2 n2 )_ d2, n2 = remainder and quotient of d1/n1

## UM*

_( u1 u2 -- ud )_ ud = u1*u2

## UM/MOD

_( ud u1 -- u2 u3 )_ divide ud by u1, giving quotient u3 and remainder u2

## UNALIGNED-L!

_( n c-addr -- )_ write cell n to c-addr

## UNALIGNED-L@

_( c-addr -- n )_ fetch cell from c-addr

## UNALIGNED-W!

_( word c-addr -- )_ write word n to c-addr

## UNALIGNED-W@

_( c-addr -- n )_ fetch word from c-addr

## UNLOOP

- Compile-only.

_( -- )_ _( R: loop-sys -- )_ remove loop parameters from stack

## UNTIL

- Immediate.
- Compile-only.

_( C: dest -- )_ _( R: x -- )_ UNTIL clause of BEGIN...UNTIL loop

## UNUSED

_( -- u )_ u = unused data space accounting for PAD and dynamic allocations

## UPC

_( char -- char' )_ upper case convert char

## VALUE

_( n "name"<> -- )_ create a definition that pushes n on the stack, n can be changed
with TO

## VARIABLE

_( "name"<> -- )_ execute CREATE name and ALLOT one cell, initially a zero.

## VOCABULARY

_( "name"<> -- )_ Create a new named wordlist definition.  When name is executed,
put the WID of the wordlist at the top of the search order.
The WID is the address of the body of the named wordlist definition.

## W!

_( word c-addr -- )_ write word n to c-addr

## W,

_( word -- )_ compile word into dictionary

## W@

_( c-addr -- word )_ fetch word from c-addr

## WA+

_( u1 n -- u2 )_ u2 = u1 + n * size of word in bytes.

## WA1+

_( n1 -- n2 )_ n2 = n1 + size of word.

## WBFLIP

_( w -- w' )_ Flip the byte order of w.

## WBFLIPS

_( addr len -- )_ perform WBFLIP on the words in memory

## WBSPLIT

_( u -- u1 .. u2 )_ u1 .. u2 = bytes of word u.

## WHILE

- Immediate.
- Compile-only.

_( C: dest -- orig dest )_ _( E: x -- )_ WHILE clause of BEGIN...WHILE...REPEAT loop

## WITHIN

_( n1|u1 n2|u2 n3|u3 -- f )_ f =  true if n2|u2 <= n1|u1 < n3|u3, false otherwise

## WLJOIN

_( w.l w.h -- q )_ Join words into quad.

## WORD

_( char "word"<char> -- c-addr )_ parse word from input stream delimited by char, return
address of WORD buffer containing packed string

## WORDLIST

_( -- wid )_ Create a new wordlist.

## WORDS

_( -- )_ output the words in the CONTEXT wordlist

## WPEEK

_( addr -- word true )_ access memory at addr, returning word

## WPOKE

_( word addr -- true )_ store word at addr

## WSX

_( word -- sign-extended )_

## XOR

_( n1 n2 -- n3 )_ n3 = n1 ^ n2

## [

- Immediate.
- Compile-only.

_( -- )_ Enter interpretation state.

## [']

- Immediate.

_( [old-name<>] -- xt )_ immediately parse old-name in input stream, return xt of word

## [:

- Immediate.
- Compile-only.

_( C: -- quot-sys )_ _( R: -- )_ Start a quotation.

## [CHAR]

- Immediate.
- Compile-only.

_( "word"<> -- char )_ immediately perform CHAR and compile literal

## [COMPILE]

- Immediate.

_( "name"<> -- )_ Compile name now.  Better to use POSTPONE.

## \

- Immediate.

_( "..."<end> -- )_ discard the rest of the input buffer (line during EVALUATE)

## ]

- Immediate.

_( -- )_ Enter compilation state.

