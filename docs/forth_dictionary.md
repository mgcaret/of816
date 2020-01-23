# Forth Dictionary

Updated: 2020-01-22 17:13:58 -0800

## !

_( n addr -- )_ Store n at addr.

## "

- Immediate.

Compiling: _( [text<">] -- )_ Parse string, including IEEE 1275-1994 hex interpolation.

Execution: _( -- addr u )_ Return parsed string.

## \#

_( ud1 -- ud2 )_ Divide ud1 by BASE, convert remainder to char and HOLD it, ud2 = quotient.

## #>

_( ud -- )_ Conclude pictured numeric output.

## #IN

_( -- addr )_ Variable containing number of chars in the current input buffer.

## #LINE

_( -- addr )_ Variable containing the number of lines output.

## #OUT

_( -- addr )_ Variable containing the number of chars output on the current line.

## #S

_( ud -- 0 )_ Perform # until quotient is zero.

## $2VALUE

_( n1 n2 addr u -- )_ Create a definition that pushes the first two cells of the body.
initially n1 and n2

## $BYTE-EXEC

_( addr xt -- )_ evaluate FCode at addr with fetch function xt, do not save FCode
evaluator state

## $CREATE

_( addr u -- )_ Like CREATE but use addr u for name.

## $DIRECT

_( -- addr )_ addr = address of the CPU direct page

## $EMPTY-WL

_( -- wid )_ Create a new empty wordlist (danger!).

## $ENV?-WL

_( -- wid )_ Return the WID of the wordlist for environmental queries.

## $FIND

_( c-addr u -- xt true | c-addr u false )_ Find word in search order.

## $FORGET

_( xt -- )_ Forget word referenced by xt and subsequent words.

## $HEX(

- Immediate.

_( [text<)>] -- addr u )_ Parse hex digits, return in allocated string.

## $MEMTOP

_( -- addr )_ addr = top of usable data space

## $NUMBER

_( addr len -- true | n false )_ Attmept to convert string to number.

## $RESTORE-INPUT

_( xn...x1 n f1 -- f2 )_ restore current source input state,
including source ID if f1 is true.

## $SEARCH

_( c-addr u -- 0 | xt +-1 )_ Search for word in current search order.

## $SOURCE-ID

_( -- a-addr )_ variable containing current input source ID

## $SYSIF

_( ... u -- ... )_ Call system interface function u.

## $TMPSTR

_( addr1 u1 -- addr2 u1 )_
Allocate a temporary string buffer for interpretation semantics of strings
and return the address and length of the buffer.  If taking the slot used
by an existing buffer, free it.

## $VALUE

_( n addr u -- )_ Create a definition that pushes the first cell of the body, initially n.

## '

_( [old-name< >] -- xt )_ Parse old-name in input stream, return xt of word.

## (

- Immediate.

_( [text<)>] -- )_ Parse and discard text until a right paren or end of input.

## (.)

_( n -- addr u )_ Convert n to text via pictured numeric output.

## (CR

_( -- )_ Emit a CR with no linefeed, set #OUT to 0.

## (IS-USER-WORD)

_( addr u xt -- )_ Create a DEFER definition for string with xt as its initial behavior.

## (SEE)

_( xt -- )_ Attempt to decompile the word at xt.

## (U.)

_( u -- addr u )_ Convert u to text via pictured numeric output.

## *

_( n1 n2 -- n3 )_ n3 = n1*n2

## */

_( n1 n2 n3 -- n4 )_ n4 = quot of n1*n2/n3.

## */MOD

_( n1 n2 n3 -- n4 n5 )_ n4, n5 = rem, quot of n1*n2/n3.

## +

_( x1 x2 -- x3 )_ x3 = x1 + x2

## +!

_( n addr -- )_ Add n to value at addr.

## +LOOP

- Immediate.
- Compile-only.

Compilation: _( do-sys -- )_

Execution: _( u|n -- )_ Add u|n to loop index and continue loop if within bounds.

## ,

_( n -- )_ Compile cell n into the dictionary.

## -

_( x1 x2 -- x3 )_ x3 = x1 - x2

## -1

_( -- -1 )_

## -ROT

_( x1 x2 x3 -- x3 x1 x2 )_

## -TRAILING

_( addr u1 -- addr u2 )_ u2 = length of string with trailing spaces omitted.

## .

_( n -- )_ Output n.

## ."

- Immediate.

_( [text<">] -- )_ Parse text and output.

## .(

- Immediate.

_( [text<)>] -- )_ Parse text until a right paren or end of input, output text.

## .D

_( n -- )_ Output n in decimal base.

## .H

_( n -- )_ Output n in hexadecimal base.

## .R

_( n u -- )_ Output n in a field of u chars.

## .S

_( -- )_ Display stack contents.

## .VERSION

_( -- )_ Display version information.

## /

_( n1 n2 -- n3 )_ Divide n1 by n2, giving quotient n3.

## /C

_( -- u )_ u = size of char in bytes.

## /C*

_( n1 -- n2 )_ n2 = n1 * size of char.

## /L

_( -- u )_ u = size of long in bytes.

## /L*

_( n1 -- n2 )_ n2 = n1 * size of long.

## /MOD

_( n1 n2 -- n3 n4 )_ Divide n1 by n2, giving quotient n4 and remainder n3.

## /N

_( -- u )_ u = size of cell in bytes.

## /N*

_( n1 -- n2 )_ n2 = n1 * size of cell.

## /STRING

_( c-addr1 u1 n -- c-addr2 u2 )_ Adjust string.

## /W

_( -- u )_ u = size of word in bytes.

## /W*

_( n1 -- n2 )_ n2 = n1 * size of word.

## 0

_( -- 0 )_

## 0<

_( n -- f )_ f = true if n < 0, false if not.

## 0<=

_( n -- f )_ f = true if n <= 0, false if not.

## 0<>

_( x -- f )_ f = false if x is zero, true if not.

## 0=

_( x -- f )_ f = true if x is zero, false if not.

## 0>

_( n -- f )_ f = true if n > 0, false if not.

## 0>=

_( n -- f )_ f = true if n >= 0, false if not.

## 1

_( -- 1 )_

## 1+

_( x1 -- x2 )_ x2 = x1 + 1

## 1-

_( x1 -- x2 )_ x2 = x1 - 1

## 2

_( -- 2 )_

## 2!

_( n1 n2 addr -- )_ Store two consecutive cells at addr.

## 2*

_( u1 -- u2 )_ Shift n1 one bit left.

## 2+

_( x1 -- x2 )_ x2 = x1 + 2

## 2-

_( x1 -- x2 )_ x2 = x1 - 2

## 2/

_( x1 -- x2 )_ Shift x1 one bit right, extending sign bit.

## 2>R

_( n1 n2 -- )_ _(R: -- n1 n2 )_

## 2@

_( addr -- n1 n2 )_ Fetch two consecutive cells from addr.

## 2CONSTANT

_( n1 n2 [name< >] -- )_ Create name, name does _( -- n1 n2 )_ when executed.

## 2DROP

_( x1 x2 -- )_

## 2DUP

_( x1 x2 -- x1 x2 x1 x2 )_

## 2OVER

_( x1 x2 x3 x4 -- x1 x2 x3 x4 x1 x2 )_

## 2R>

_( R: x1 x2 -- )_ _( -- x1 x2 )_

## 2R@

_( R: n1 n2 -- n1 n2 )_ _( -- n1 n2 )_

## 2ROT

_( x1 x2 x3 x4 x5 x6 -- x3 x4 x5 x6 x1 x2 )_

## 2S>D

_( n1 n2 -- d1 d2 )_ Convert two numbers to double-numbers.

## 2SWAP

_( x1 x2 x3 x4 -- x3 x4 x1 x2 )_

## 3

_( -- 3 )_

## 3DROP

_( x1 x2 x3 -- )_

## 3DUP

_( x1 x2 x3 -- x1 x2 x3 x1 x2 x3 )_

## :

_( [name< >] -- colon-sys )_ Parse name, start colon definition and enter compiling state.

## :NONAME

_( -- colon-sys )_ Create an anonymous colon definition and enter compiling state.
The xt of the anonymous definition is left on the stack after ;.

## :TEMP

_( -- colon-sys )_ Create a temporary anonymous colon definition and enter
compiling state.  The temporary definition is executed immediately after ;.

## ;

- Immediate.
- Compile-only.

_( colon-sys -- )_ Consume colon-sys and enter interpretation state, ending the current
definition.  If the definition was temporary, execute it.

## ;CODE

- Immediate.
- Compile-only.

_( -- )_ End compiler mode, begin machine code section of definition.

## ;]

- Immediate.
- Compile-only.

Compilation: _( quot-sys -- )_ End a quotation.

Execution: _( -- xt )_  Leave xt of the quotation on the stack.

## \<

_( n1 n2 -- f )_ f = true if n1 < n2, false if not.

## \<#

_( -- )_ Begin pictured numeric output.

## \<<

_( u1 u2 -- u3 )_ u3 = u1 << u2

## \<=

_( n1 n2 -- f )_ f = true if n1 <= n2, false if not.

## \<>

_( x1 x2 -- f )_ f = true if x1 <> x2, false if not.

## \<W@

_( addr -- n )_ Fetch sign-extended word from addr.

## =

_( x1 x2 -- f )_ f = true if x1 = x2, false if not.

## \>

_( n1 n2 -- f )_ f = true if n1 > n2, false if not.

## \>=

_( n1 n2 -- f )_ f = true if n1 >= n2, false if not.

## \>>

_( u1 u2 -- u3 )_ u3 = u1 >> u2

## \>>A

_( x1 x2 -- x3 )_ x3 = x1 >> x2, extending sign bit.

## \>BODY

_( xt -- a-addr)_ return body of word at xt, if unable then throw exception -31

## \>IN

_( -- addr )_ Variable containing offset to the current parsing area of input buffer.

## \>LINK

_( xt -- addr|0 )_ Get link field of word at xt or 0 if none.

## \>NAME

_( xt -- c-addr u )_ Get string name of word at xt, or ^xt if anonymous/noname.
Uses pictured numeric output.

## \>NUMBER

_( ud1 addr1 u1 -- ud2 addr2 u2 )_ Convert text to number.

## \>R

_( n -- )_ _(R: -- n )_

## \>R@

_( n -- n )_ _( R: -- n )_

## ?

_( addr -- )_ Output signed contents of cell at addr.

## ?DO

- Immediate.
- In interpretation state, starts temporary definition.

Compilation: _( -- do-sys )_

Execution: _( limit start -- )_ Start DO loop, skip if limit=start.

## ?DUP

_( 0 -- 0 )_ | _( n1 -- n1 n2 )_ n2 = n1.

## ?LEAVE

- Compile-only.

_( f -- )_ Exit do loop if f is nonzero.

## @

_( addr -- n )_ Fetch n from addr.

## A"

_( [text<">] -- c-addr u )_ Parse text in input buffer, copy to allocated string.

## ABORT

_( -- )_ Execute -1 THROW.

## ABORT"

- Immediate.

Compilation/Interpretation: _( [text<">] -- )_

Execution: _( f -- )_
If f is true, display text and execute -2 THROW.

## ABS

_( n1 -- n2 )_ Take the absolute value of n1.

## ACCEPT

_( addr len -- u )_ get input line of up to len chars, stor at addr, u = # chars accepted

## ACONCAT

_( addr1 u1 addr2 u2 -- addr3 u1+u2 )_ Concatenate allocated strings,
freeing the originals.

## AGAIN

- Immediate.
- Compile-only.

Compilation: _( dest -- )_  Resolve dest.

Execution: _( -- )_ Jump to BEGIN.

## AHEAD

- Immediate.
- In interpretation state, starts temporary definition.

Compilation: _( -- orig )_

Execution: _( -- )_ Jump ahead as to the resolution of orig.

## ALIAS

_( [name1< >] [name2< >] -- )_ create name1, name1 is a synonym for name2

## ALIGN

_( u -- u )_ Align u (no-op in this implementation).

## ALIGNED

_( u1 -- u2 )_ u2 = next aligned address after u1.

## ALLOC-MEM

_( u -- c-addr )_ Allocate memory from heap.

## ALLOT

_( n -- )_ Allocate n bytes in the dictionary.

## ALSO

_( -- )_ Duplicate the first wordlist in the search order.

## AND

_( u1 u2 -- u3 )_ u3 = u1 & u2

## ASCII

- Immediate.

_( [word< >] -- char )_ Perform either CHAR or [CHAR] per the current compile state.

## AT-XY

_( u1 u2 -- )_ Place cursor at col u1 row u2 (uses ANSI escape sequence).

## BASE

_( -- a-addr )_ Variable containing current numeric base.

## BEGIN

- Immediate.
- In interpretation state, starts temporary definition.

Compilation: _( -- dest )_

Execution: _( -- )_ start a BEGIN loop

## BEHAVIOR

_( [name< >] -- )_ Return the first cell of the body of name, which should be a DEFER word.

## BELL

_( -- <bel> )_

## BETWEEN

_( n1|u1 n2|u2 n3|u3 -- f )_ f =  true if n2|u2 <= n1|u1 <= n3|u3, false otherwise

## BINARY

_( -- )_ Store 2 to BASE.

## BL

_( -- <space> )_

## BLANK

_( addr len -- )_ Fill memory with spaces.

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

_( n [name< >] -- )_ Allocate n bytes of memory, create definition that
returns the address of the allocated memory.

## BWJOIN

_( b.l b.h -- w )_ Join bytes into word.

## BYE

_( -- )_ Restore system stack pointer and exit Forth.

## BYTE-LOAD

_( addr xt -- )_ Evaluate FCode at addr with fetch function xt, saving and

## C!

_( char addr -- )_ Store char at addr.

## C,

_( char -- )_ Compile char into dictionary.

## C;

_( code-sys -- )_ Consume code-sys, end CODE or LABEL definition.

## C@

_( addr -- char )_ Fetch char from addr.

## CA+

_( u1 n -- u2 )_ u2 = u1 + n * size of char in bytes.

## CA1+

_( n1 -- n2 )_ n2 = n1 + size of char.

## CARRET

_( -- <cr> )_

## CASE

- Immediate.
- In interpretation state, starts temporary definition.

Compilation: _( -- case-sys )_ start a CASE...ENDCASE structure

Execution: _( -- )_

## CATCH

_( xt -- xi ... xj n|0 )_ Call xt, trap exception, and return it in n.

## CELL+

_( u1 -- u2 )_ u2 = u1 + size of cell in bytes.

## CELLS

_( n1 -- n2 )_ n2 = n1 * size of cell.

## CHAR

_( [word< >] -- char )_ Parse word from input stream, return value of first char.

## CHAR+

_( u1 -- u2 )_ u2 = u1 + size of char in bytes.

## CHARS

_( n1 -- n2 )_ n2 = n1 * size of char.

## CICOMP

_( addr1 addr2 u1 -- n1 )_ Case-insensitive compare two strings of length u1.

## CLEAR

_( ... -- )_ Empty stack.

## CMOVE

_( addr1 addr2 len -- )_ Move memory, startomg from the bottom.

## CMOVE>

_( addr1 addr2 len -- )_ Move memory, starting from the top.

## CODE

_( [name< >] -- code-sys )_ Create a new CODE definiion.

## COMP

_( addr1 addr2 u1 -- n1 )_ Compare two strings of length u1.

## COMPARE

_( addr1 u1 addr2 u2 -- n1 )_ Compare two strings.

## COMPILE

- Immediate.
- Compile-only.

_( -- )_ Compile code to compile the immediately following word which must resolve to an xt.
Better to use POSTPONE in most cases.

## COMPILE,

- Immediate.

_( xt -- )_ Compile xt into the dictionary.

## CONSTANT

_( n [name< >] -- )_ alias of VALUE, OF816 doesn't have true constants

## CONTEXT

_( -- wid )_ Return first wordlist in search order.

## CONTROL

- Immediate.

( [name< >] ) Parse name, place low 5 bits of first char on stack.
If compiling state, compile it as a literal.

## COUNT

_( addr -- addr+1 u )_ Count packed string at addr.

## CPEEK

_( addr -- char true )_ Access memory at addr, returning char.

## CPOKE

_( char addr -- true )_ Store char at addr.

## CR

_( -- )_ Emit a CR/LF combination, increment #LINE, set #OUT to 0.

## CREATE

_( [name< >] -- )_ Create a definition, when executed pushes the body address.

## D#

- Immediate.

( [number< >] n )  Parse number as decimal, compile as literal if compiling.

## D+

_( d1 d2 -- d3 )_ d3 = d1 + d2

## D-

_( d1 d2 -- d3 )_ d3 = d1 - d2

## D.

_( d -- )_ Output d.

## D.R

_( d u -- )_ Output d in a field of u chars.

## D>S

_( d -- n )_ Convert double-number to number.

## DABS

_( d1 -- d1|d2 )_ Take the absolute value of d1.

## DEBUG-MEM

_( -- )_ Display heap and temporary string information.

## DECIMAL

_( -- )_ Store 10 to BASE.

## DEFER

_( [name< >] -- )_ Create definition that executes the first word of the body as an xt.

## DEFINITIONS

_( -- )_ Set the compiler wordlist to the first wordlist in the search order.

## DEPTH

_( xu ... x1 -- xu ... x1 u )_

## DIGIT

_( char base -- digit true | char false )_ Attempt to convert char to digit.

## DNEGATE

_( d1 -- d2 )_ Negate d1.

## DO

- Immediate.
- In interpretation state, starts temporary definition.

Compilation: _( -- do-sys )_

Execution: _( limit start -- )_ Start DO loop.

## DOES>

- Immediate.
- Compile-only.

_( -- )_ alter execution semantics of most recently-created definition to
perform the execution semantics of the code following DOES>.

## DROP

_( x -- )_

## DUMP

_( addr len -- )_ Dump memory.

## DUP

_( n1 -- n1 n2 )_ n2 = n1.

## ELSE

- Immediate.
- Compile-only.

Compilation: _( if-sys -- else-sys )_

Execution: _( -- )_ ELSE clause of IF ... ELSE ... THEN.

## EMIT

_( char -- )_ Output char.

## END-CODE

- Immediate.
- Compile-only.

_( code-sys -- )_ Synonym for C;.

## ENDCASE

- Immediate.
- Compile-only.

Compilation: _( case-sys -- )_ Conclude a CASE...ENDCASE structure.

Execution: _( | n -- )_ Continue execution, dropping n if no OF matched.

## ENDOF

- Immediate.
- Compile-only.

Compilation; _( case-sys of-sys -- case-sys )_ Conclude an OF...ENDOF structure.

Execution: Continue execution at ENDCASE of case-sys.

## ENVIRONMENT?

_( c-addr u -- xn...x1 t | f )_ Environmental query.

## ERASE

_( addr len -- )_ Zero fill memory.

## EVAL

synonym for EVALUATE

## EVALUATE

_( xxn...xx1 addr u -- yxn...yx1 )_ Interpret text in addr u.

## EVEN

_( n1 -- n1|n2 )_ n2 = n1+1 if n1 is odd.

## EXECUTE

_( xt -- )_ execute xt, regardless of its flags

## EXIT

- Compile-only.

_( -- )_ Exit this word, to the caller.

## EXIT?

_( -- f )_ If #LINE >= 20, prompt user to continue and return false if they want to.

## EXPECT

_( addr len -- )_ get input line of up to len chars, stor at addr, actual len in SPAN

## FALSE

_( -- false )_ false = all zero bits

## FCODE-REVISION

_( -- u )_ Return FCode revision

## FERROR

_( -- )_ Display FCode IP and byte, throw exception -256.

## FIELD

Compilation: _( offset size [name< >] -- offset+size )_ create name
Execution of name: _( addr -- addr+offset)_

## FILL

_( addr len char -- )_ Fill memory with char.

## FIND

_( c-addr -- xt|0 )_ Find packed string word in search order, 0 if not found.

## FM/MOD

_( d n1 -- n2 n3 )_ Floored divide d by n1, giving quotient n3 and remainder n2.

## FORGET

_( [name< >] -- )_ Attempt to forget name and subsequent definitions in compiler
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

_( fcode# -- xt f )_ Get fcode#'s xt and immediacy.

## H#

- Immediate.

( [number< >] n )  Parse number as hexadecimal, compile as literal if compiling.

## HERE

_( -- addr )_ Return dictionary pointer.

## HEX

_( -- )_ Store 16 to BASE.

## HOLD

_( c -- )_ Place c in pictured numeric output.

## I

- Compile-only.

_( -- n )_ Copy inner loop index to stack.

## IF

- Immediate.
- In interpretation state, starts temporary definition.

Compilation: _( -- if-sys )_

Execution: _( n -- )_ Begin IF ... ELSE ... ENDIF.

## IMMEDIATE

_( -- )_ Mark last compiled word as an immediate word.

## INVERT

_( x1 -- x2 )_ Invert the bits in x1.

## J

- Compile-only.

_( -- n )_ Copy second-inner loop index to stack.

## KEY

_( -- char )_ wait for input char, return it

## KEY?

_( -- f )_ f = true if input char is ready, false otherwise

## L!

_( n addr -- )_ Store n at addr.

## L,

_( q -- )_ Compile cell q into dictionary.

## L@

_( addr -- n )_ Fetch n from addr.

## LA+

_( u1 n -- u2 )_ u2 = u1 + n * size of long in bytes.

## LA1+

_( n1 -- n2 )_ n2 = n1 + size of long.

## LABEL

_( [name< >] -- code-sys )_ Create a new LABEL definition.

## LAST

_( -- addr )_ Return address of last definition in current vocabulary.

## LBFLIP

_( q -- q' )_ Flip the byte order of quad.

## LBFLIPS

_( addr len -- )_ Perform LBFLIP on the cells in memory.

## LBSPLIT

_( u -- u1 ... u4 )_ u1 ... u4 = bytes of u.

## LCC

_( char -- char' )_ Lower case convert char.

## LEAVE

- Compile-only.

_( -- )_ Exit DO loop.

## LEFT-PARSE-STRING

_( str len char -- r-str r-len l-str l-len )_ Parse string for char, returning
the left and right sides.

## LINEFEED

_( -- <lf> )_

## LITERAL

- Immediate.

Compilation: _( n -- )_

Execution: _( -- n )_

## LOOP

- Immediate.
- Compile-only.

Compilation: _( do-sys -- )_

Execution: _( -- )_ Add 1 to loop index and continue loop if within bounds.

## LPEEK

_( addr -- cell true )_ Access memory at addr, returning cell.

## LPOKE

_( cell addr -- true )_ Store cell at addr.

## LSHIFT

_( u1 u2 -- u3 )_ u3 = u1 << u2

## LWFLIP

_( q -- q )_ Flip the word order of quad.

## LWFLIPS

_( addr len -- )_ Perform LWFLIP on the cells in memory.

## LWSPLIT

_( u -- u1 ... u2 )_ u1 ... u2 = words of u.

## M*

_( n1 n2 -- d )_ d = n1*n2

## MAX

_( n1 n2 -- n1|n2 )_ Return the greater of n1 or n2.

## MIN

_( n1 n2 -- n1|n2 )_ Return the smaller of n1 or n2.

## MOD

_( n1 n2 -- n3 )_ Divide n1 by n2, giving remainder n3.

## MOVE

_( addr1 addr2 len -- )_ Move memory.

## N>R

_( xu ... x0 u -- )_ _( R: -- x0 ... xu )_ remove u+1 items from parameter stack
and place on return stack.

## NA+

_( u1 n -- u2 )_ u2 = u1 + n * size of cell in bytes.

## NA1+

_( n1 -- n2 )_ n2 = n1 + size of cell.

## NEGATE

_( n1 -- n2 )_ Negate n1.

## NIP

_( x1 x2 -- x2 )_

## NOOP

_( -- )_ Do nothing.

## NOSHOWSTACK

_( -- )_ assuming STATUS is a defer, set it to NOOP

## NOT

_( x1 -- x2 )_ Invert the bits in x1.

## NR>

_( R: x0 ... xu -- )_ _( u -- xu ... x0 )_ remove u+1 items from return stack
and place on parameter stack.

## O#

- Immediate.

( [number< >] n )  Parse number as octal, compile as literal if compiling.

## OCTAL

_( -- )_ Store 8 to BASE.

## OF

- Immediate.
- Compile-only.

Compilation: _( case-sys -- case-sys of-sys )_ Begin an OF...ENDOF structure.

Execution: _( x1 x2 -- | x1 )_ Execute OF clause if x1 = x2, leave x1 on stack if not.

## OFF

_( addr -- )_ Store all zero bits in cell at addr.

## ON

_( addr -- )_ Store all one bits to cell at addr.

## ONLY

_( -- )_ Set the search order to contain only the system wordlist.

## OR

_( u1 u2 -- u3 )_ u3 = u1 | u2

## ORDER

_( -- )_ Display the current search order and compiler wordlist.

## OVER

_( x1 x2 -- x1 x2 x2 )_

## PACK

_( str len addr -- addr )_ Pack string into addr, similar to PLACE in some Forths.

## PAD

_( -- a-addr )_ return address of PAD

## PAGE

_( -- )_ Clear screen & home cursor (uses ANSI escape sequence).

## PARSE

_( char [text<char>] -- addr u )_ Parse text from input stream, delimited by char.

## PARSE-2INT

_( str len -- val.lo val.hi )_ Parse two integers from string in the form "n2,n2".

## PARSE-NAME

_( [word< >] -- addr u )_ Alias of PARSE-WORD.

## PARSE-WORD

_( [word< >] -- addr u )_ Parse word from input stream, return address and length.

## PICK

_( xu ... x1 x0 u -- xu ... x1 xu )_

## POSTPONE

- Immediate.

_( [name< >] -- )_ Compile the compilation semantics of name.

## PREVIOUS

_( -- )_ Remove the first wordlist in the search order.

## QUIT

_( -- )_ _( R: ... -- )_ Enter outer interpreter loop, aborting any execution.

## R+1

_( R: n1 -- n2 )_ n2 = n1 + 1

## R>

_( R: x -- )_ _( -- x )_

## R@

_( R: n -- n )_ _( -- n )_

## RB!

- Immediate.

_( byte addr -- )_ Perform FCode-equivalent RB!: store byte.

## RB@

- Immediate.

_( addr -- byte )_ Perform FCode-equivalent RB@: fetch byte.

## RDROP

_( R: n -- )_

## RECURSE

- Immediate.
- Compile-only.

_( -- )_ Compile the execution semantics of the most current definition.

## RECURSIVE

- Immediate.
- Compile-only.

_( -- )_ Make the current definition findable during compilation.

## REFILL

_( -- f )_ refill input buffer, f = true if that worked, false if not

## REPEAT

- Immediate.
- Compile-only.

Compilation: _( orig dest -- )_ Resolve orig and dest.

Execution: _( -- )_ Repeat BEGIN loop.

## RESET-ALL

_( -- )_ Reset the system.

## RESTORE-INPUT

_( xn...x1 n -- f )_ Restore current source input state, source ID must match current.

## RL!

- Immediate.

_( cell addr -- )_ Perform FCode-equivalent RL!, store cell.

## RL@

- Immediate.

_( addr -- cell )_ Perform FCode-equivalent RL@: fetch cell.

## ROLL

_( xu ... x0 u -- xu-1 .. x0 xu )_

## ROT

_( x1 x2 x3 -- x2 x3 x1 )_

## RSHIFT

_( u1 u2 -- u3 )_ u3 = u1 >> u2

## RW!

- Immediate.

_( word addr -- )_ Perform FCode-equivalent RW!: store word.

## RW@

- Immediate.

_( addr -- word )_ Perform FCode-equivalent RW@: fetch word.

## S"

- Immediate.

_( [text<">] -- addr u )_

## S.

_( n -- )_ Output n.

## S>D

_( n -- d )_ Convert number to double-number.

## SAVE-INPUT

## SEAL

_( -- )_ Set the search order to contain only the current top of the order.

## SEARCH

_( c-addr1 u1 c-addr2 u2 -- c-addr3 u3 flag )_ Search for substring.

## SEARCH-WORDLIST

_( c-addr u wid -- 0 | xt +-1 )_ Search wordlist for word.

## SEE

_( [text< >] -- )_ Attempt to decompile name.

## SET-CURRENT

_( wid -- )_ Set the compiler wordlist.

## SET-ORDER

_( widn ... wid1 n -- )_ Set dictionary search order.

## SET-TOKEN

_( xt fcode# f -- )_ Set fcode# to execute xt, immediacy f.

## SHOWSTACK

_( -- )_ assuming STATUS is a defer, set it to .S

## SIGN

_( n -- )_ Place - in pictured numeric output if n is negative.

## SIGNUM

_( n -- s )_ s = -1 if n is negative, 0 if 0, 1 if positive.

## SLITERAL

- Immediate.
- Compile-only.

Compiling: _( addr1 u -- )_ compile string literal into current def

Execution: _( -- addr2 u )_ return compiled string

## SM/REM

_( d n1 -- n2 n3 )_ Symmetric divide d by n1, giving quotient n3 and remainder n2.

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

_( u1 -- u2 u3 )_ u2 = closest square root <= to the true root, u3 = remainder.

## STATE

_( -- addr )_ Variable, zero if interpreting, nonzero if compiling.

## STRUCT

_( -- 0 )_

## SWAP

_( x1 x2 -- x2 x1 )_

## THEN

- Immediate.
- Compile-only.

Compilation: _( if-sys|else-sys -- )_

Execution: _( -- )_ Conclustion of IF ... ELSE ... THEN.

## THROW

_( n -- )_ Throw exception n if n is nonzero.

## TO

- Immediate.

_( n [name< >] -- )_ Change the first cell of the body of xt to n.  Can be used on
most words created with CREATE, DEFER, VALUE, etc. (even VARIABLE).

## TRUE

_( -- true )_ true = all one bits

## TUCK

_( x1 x2 -- x2 x1 x2 )_

## TYPE

_( addr u -- )_ Output string.

## U#

_( u1 -- u2 )_ Divide u1 by BASE, convert remainder to char and HOLD it, u2 = quotient.

## U#>

_( u -- )_ Conclude pictured numeric output.

## U#S

_( u -- 0 )_ Perform U# until quotient is zero.

## U*

_( u1 u2 -- u3 )_ u3 = u1*u2

## U.

_( u -- )_ Output u.

## U.0

_( u1 -- )_ Output u1 with no trailing space.

## U.R

_( u1 u2 -- )_ Output u1 in a field of u2 chars.

## U/MOD

_( u1 u2 -- u3 u4 )_ Divide u1 by u2, giving quotient u4 and remainder u3.

## U2/

_( u1 -- u2 )_ Shift n1 one bit right.

## U<

_( u1 u2 -- f )_ f = true if u1 < u2, false if not.

## U<=

_( u1 u2 -- f )_ f = true if u1 <= u2, false if not.

## U>

_( u1 u2 -- f )_ f = true if u1 > u2, false if not.

## U>=

_( u1 u2 -- f )_ f = true if u1 >= u2, false if not.

## UD/MOD

_( d1 n1 -- d2 n2 )_ d2, n2 = remainder and quotient of d1/n1

## UM*

_( u1 u2 -- ud )_ ud = u1*u2

## UM/MOD

_( ud u1 -- u2 u3 )_ Divide ud by u1, giving quotient u3 and remainder u2.

## UNALIGNED-L!

_( n addr -- )_ Store n at addr.

## UNALIGNED-L@

_( addr -- n )_ Fetch n from addr.

## UNALIGNED-W!

_( word addr -- )_ Store word at addr.

## UNALIGNED-W@

_( addr -- n )_ Fetch word from addr.

## UNLOOP

- Compile-only.

_( -- )_ _( R: loop-sys -- )_ Remove loop parameters from return stack.

## UNTIL

- Immediate.
- Compile-only.

Compilation: _( dest -- )_

Execution: _( x -- )_ UNTIL clause of BEGIN...UNTIL loop

## UNUSED

_( -- u )_ u = unused data space accounting for PAD and dynamic allocations

## UPC

_( char -- char' )_ Upper case convert char.

## VALUE

_( n [name< >] -- )_ Create a definition that pushes n on the stack,
n can be changed with TO.

## VARIABLE

_( [name< >] -- )_ Execute CREATE name and allocate one cell, initially a zero.

## VOCABULARY

_( "name"<> -- )_ Create a new named wordlist definition.  When name is executed,
put the WID of the wordlist at the top of the search order.
The WID is the address of the body of the named wordlist definition.

## W!

_( word addr -- )_ Store word at addr.

## W,

_( word -- )_ Compile word into dictionary.

## W@

_( addr -- word )_ Fetch word from addr.

## WA+

_( u1 n -- u2 )_ u2 = u1 + n * size of word in bytes.

## WA1+

_( n1 -- n2 )_ n2 = n1 + size of word.

## WBFLIP

_( w -- w' )_ Flip the byte order of w.

## WBFLIPS

_( addr len -- )_ Perform WBFLIP on the words in memory.

## WBSPLIT

_( u -- u1 .. u2 )_ u1 .. u2 = bytes of word u.

## WHILE

- Immediate.
- Compile-only.

Compilation: _( dest -- orig dest )_

Execution: _( x -- )_ WHILE clause of BEGIN...WHILE...REPEAT loop

## WITHIN

_( n1|u1 n2|u2 n3|u3 -- f )_ f =  true if n2|u2 <= n1|u1 < n3|u3, false otherwise

## WLJOIN

_( w.l w.h -- q )_ Join words into quad.

## WORD

_( char [text<char>] -- addr )_ Parse text from input stream delimited by char, return
address of WORD buffer containing packed string.

## WORDLIST

_( -- wid )_ Create a new wordlist.

## WORDS

_( -- )_ Output the words in the CONTEXT wordlist.

## WPEEK

_( addr -- word true )_ Access memory at addr, returning word.

## WPOKE

_( word addr -- true )_ Store word at addr.

## WSX

_( word -- sign-extended )_

## XOR

_( u1 u2 -- u3 )_ u3 = u1 ^ u2

## [

- Immediate.
- Compile-only.

_( -- )_ Enter interpretation state.

## [']

- Immediate.

_( [old-name< >] -- xt )_ Immediately parse old-name in input stream, return xt of word.

## [:

- Immediate.
- Compile-only.

Compilation: _( -- quot-sys )_ Start a quotation.

Execution: _( -- )_ Skip over quotation code.

## [CHAR]

- Immediate.
- Compile-only.

_( [word< >] -- char )_ Immediately perform CHAR and compile literal.

## [COMPILE]

- Immediate.

_( [name< >] -- )_ Compile name now.  Better to use POSTPONE.

## \

- Immediate.

_( [text<end>] -- )_ Discard the rest of the input buffer (or line during EVALUATE)

## ]

- Immediate.

_( -- )_ Enter compilation state.

