# Getting Started

## References

[IEEE 1275-1994](http://www.openbios.org/data/docs/of1275.pdf)

[ANS Forth X3.215-1994](http://lars.nocrew.org/dpans/dpans.htm)

## Basics

OF816 implements ANS Forth as described by IEEE 1275-1994, but lacking the
packages system and Device Tree features.  It is advisable to read the above
documents as well as a Forth tutorial.

### System Information

OF816 is a portable Forth system.  The bulk of the system is self-contained and
may be linked by itself and placed in the ROM or RAM of a target system
(restriction: code segments must not cross bank boundaries).  The host system
can then configure and instantiate the interpreter via a jump table.  Creating
a specific port allows the easy inclusion of platform-specific words and
routines, and allows leveraging of Forth components to implement the system
interface.

The source code is logically broken down into config, macros, equates, the two
dictionaries, routines pertaining to interpretation/run-time, routines
pertaining to compilation, math library, memory management library, and FCode
evaluation.

FCode may be created with the
[OpenBIOS FCode suite](https://www.openfirmware.info/FCODE_suite).  Get the
FCode into ROM or RAM and use ``<addr> 1 byte-load`` to evaluate it.  See the
W65C816SXB for example FCode to useful things, such as scan for and load
additonal FCode.

### Included Ports

  * [W65C816SXB](https://wdc65xx.com/boards/w65c816sxb-engineering-development-system/).
  * Apple IIgs.

See the README files in each port's directory under /platforms for build & 
installation instructions.

## Configuration and Build

The system may be configured by changing values in ``config.inc``.  Each option
is described in that file.  Note that changing the options may affect the
conformance statments that appear in this document, and/or the supported
features of the resulting system.

OF816 is assembled and linked with the ``ca65`` assembler and ``ld65`` linker
from the [cc65 toolchain](https://github.com/cc65/cc65).  To build a basic
cc65 object file with the basic system (no platform-specific code), execute
build.sh in the project root directory.

Each platform port has their own method to build an image, see the directories
for each platform under ``platforms/``.

## Porting/System Implementation

See porting.md for instructions on how to port OF816 to your platform including
implementing the system interface.

## Conformance

### ANS Conformance

  * Providing the Core word set.
  * Providing ``.(``, ``.R``, ``0<>``, ``0>``, ``2>R``, ``2R@``, ``:NONAME``,
    ``<>``, ``?DO``, ``AGAIN``, ``CASE``, ``COMPILE,``, ``ENDCASE``, ``ENDOF``,
    ``ERASE``, ``EXPECT``, ``FALSE``, ``HEX``, ``NIP``, ``PAD``, ``PARSE``,
    ``PICK``, ``REFILL``, ``RESTORE-INPUT``, ``ROLL``, ``SAVE-INPUT``,
    ``SOURCE-ID``, ``SPAN``, ``TO``, ``TRUE``, ``TUCK``, ``U.R``, ``U>``,
    ``UNUSED``, ``VALUE``, ``WITHIN``, ``[COMPILE]``, and ``\`` from the Core
    Extensions word set.
  * Providing ``2CONSTANT``, ``D+``, ``D-``, ``D.R``, ``D>S``, ``DABS``,
    ``DNEGATE``, and ``2ROT`` from thge Double-Number word set.
  * Providing the Exception word set.
  * Providing the Facility word set.
  * Providing Programming-Tools word set.
  * Providing ``;CODE``, ``AHEAD``, ``BYE``, ``CODE``, ``FORGET``, and ``STATE``
    from the Programming-Tools Extensions word set.
  * Providing the Search Order word set.
  * Providing ``-TRAILING``, ``BLANK``, ``CMOVE``, ``CMOVE>``, ``COMPARE``,
    ``SEARCH``, and ``SLITERAL`` from the String word set.

#### Implementation-defined Options

See IEEE 1275-1994 section 2.4.3 "ANS Forth compatibility" for
implementation-defined options that are defined by that standard, with the
following exeptions/differences:
  * Method of selection of console input and output device:  Always defined by
    the system interface.
  * Packed strings are limited to 255 bytes as in Open Firmware.  However,
    counted strings may be larger and in practice most words that operate with
    strings will accept strings of at least 65535 bytes.
  * The maximum string length for ``ENVIRONMENT?`` queries is 128.
  * The size of the console's input buffer is normally 128 but may be changed at
    assembly time.

Items from IEEE 1275-1994 that remain implementation-defined are defined in
OF816 as follows:
  * Aligned address requirements:  None.  The 65C816 CPU does not have alignment
    restrictions. Words that influence alignment or are affected by alignment
    are no-ops or equivalent to their unaligned counterparts.
  * Behavior of ``EMIT`` for non-graphic values:  The character is passed to the
    system interface to be handled in a manner defined by that interface.
  * Control-flow stack: The parameter stack.
  * Console input and output device:  Defined by the system interface functions.
  * Exception abort sequence:  If ``CATCH`` is not used, an error message is
    displayed and control is returned to the user via ``QUIT``.
  * Input line terminator: CR (0x0D).
  * Methods of dictionary compilation: appended to the data space afer the
    previous definition.
  * Methods of memory space management:  There is one data space, it can be
    allocated by traditional methods (``ALLOT``, etc.) from the bottom, and can
    be allocated by ``ALLOC-MEM`` and freed by ``FREE-MEM`` from the top.
  * Minimum search order:  The minimum search order contains forth-wordlist.  In
    the event the search order is empty, the current compiler word list is
    searched.
  * Size of the scratch area who is addressed in ``PAD``: ``PAD`` is optional,
    size set at assembly time.  Dynamically moves as the dictionary grows.
  * Non-standard words using ``PAD``: none.
  * The current definition can be found after ``DOES>``
  * Source and format of display by ``SEE``: list of names and addresses.
    Output not guaranteed to be correct/complete for built-in words.

Other notes:
  * ``WORD`` shares its buffer with the pictured numeric output.  The normal
    size meets IEEE 1275-1994, but it may be changed at assembly time.

### Forth Interpreter IEEE 1275-1994 Conformance

The command mode of the interpreter currently *does not* implement any of the
editing features described by IEEE 1725-1994.

The following parts of IEEE 1275-1994 are implemented in the main interpreter
("user interface") of OF816:
  * The entirety of section 7.3 "Forth command group."
  * From section 7.4: ``RESET-ALL``.
  * From section 7.5: ``SHOWSTACK``, ``NOSHOWSTACK``, ``WORDS``, ``SEE``,
    ``(SEE)``.

The following are not implemented:
  * The entirety of section 7.4 "Administration command group."
  * Most of section 7.5 except those noted above.
  * The entirety of section 7.6.
  * The entirety of section 7.7.

### FCode Evaluator IEEE 1275-1994 Conformance

#### Supported FCodes

When FCode support is included, the following FCodes **are** available.
Generally, any caveats mentioned for words of the Forth interpreter apply to the
associated FCodes.
  * All the FCodes from subsections 5.3.2.1, 5.3.2.2, 5.3.3.2, 5.3.3.3, 5.3.3.4.
  * All the FCodes from subsection 5.3.3.1 *except* 0xC0 ``INSTANCE``.
  * All the FCodes from subsection 5.3.3.3.
  * 0x240 ``LEFT-PARSE-STRING`` and 0x11B ``PARSE-2INT`` from section 5.3.4.
  * All the FCodes from subsections 5.3.7.1 and 5.3.7.2.
  * All the FCodes from subsection 5.3.7.6 *except* 0x11F ``NEW-DEVICE``, 0x127
    ``FINISH-DEVICE``, and 0x23F ``SET-ARGS``.

#### Unimplemented FCodes

The following FCodes **are not** available:
  * All the fcodes from section 5.3.4 ("Package access") *except* 0x240
    ``LEFT-PARSE-STRING`` and 0x11B ``PARSE-2INT``.
  * All the fcodes from section 5.3.5 ("Property management").
  * All the FCodes from section 5.3.6 ("Display device management").
  * All the FCodes from subsections 5.3.7.3, 5.3.7.4, and 5.3.7.5.
  * 0x11F ``NEW-DEVICE``, 0x127 ``FINISH-DEVICE``, and 0x23F ``SET-ARGS`` from
    subsection 5.3.7.6.

## Implementation-specific Words

 The following implementation-specific words are present:
 
  * ``$ENV?-WL`` ( -- wid ) return the wordlist for environmental queries.
  * ``CICOMP`` ( addr1 addr2 u1 -- n1 ) case-insensitive version of ``COMP``.
  * ``CONTEXT`` ( -- wid ) return the wordlist at the top of the search order.
  * ``SEAL`` ( -- ) set the search order to contain only the current
    ``CONTEXT``.
  * ``$DIRECT`` ( -- a-addr ) provide the address of the 65C816 Direct Page used
    by Forth.
  * ``$FORGET`` ( xt -- ) attempt to forget the word at xt and subsequent
    definitions.
  * ``VOCABULARY`` ( "name"< > -- ) create a named vocabulary.
  * ``$EMPTY-WL`` ( -- WID ) create a new completely empty wordlist without even
    the root words.
  * ``:TEMP`` ( ... -- ... ) start a temporary definition, execute it when ; is
    executed.  Exposes the underlying implementation for interpretation
    semantics of various control-flow words such as ``DO``...``LOOP`` and
    others.
  * ``%DEFER``, ``%VARIABLE``, ``%BUFFER``, ``%VALUE`` (only when FCode is
    enabled) ( -- ) compile the execution behavior of these types of words after
    FCode executes a token-creating word.
  * ``$2VALUE`` ( n1 n2 c-addr u -- ) create a ``2VALUE``.
  * ``$VALUE`` ( n c-addr u -- ) create a ``VALUE``
  * ``$CREATE`` ( c-addr u -- ) make a create word.
  * ``ACONCAT`` ( c-addr1 u1 c-addr2 u2 -- c-addr3 u3 ) assuming the stack
    contains two strings held in memory allocated by ``ALLOC-MEM``, concatenate
    them into a new string and ``FREE-MEM`` the originals.
  * ``A"`` ( "string"<"> -- c-addr u ) parse string and place it in memory
    allocated by ``ALLOC-MEM``.
  * ``>NAME`` ( xt -- c-addr u ) find name or text representation of xt.  May
    use the word/pictured numeric output buffer.
  * ``>LINK`` ( xt -- c-addr ) find link field of xt, 0 if none (noname).
  * ``$BYTE-EXEC`` ( addr xt -- ) (only when FCode is enabled) evaluate FCode at
    addr, fetching with xt.  Do not save or restore evaluator state
    (cf. ``BYTE-LOAD``).
  * ``SQRTREM`` ( u1 -- u2 u3 ) calculate closest integer root less than or
    equal to the actual square root of u1, leaving u3 as the remainder.
  * ``$TMPSTR`` ( c-addr1 u1 -- c-addr2 u2 ) copy string into the next temporary
    string buffer and return the copy.  This exposes the underlying
    implementation of interpretation semantics for ``S"`` and ``"``.
  * ``$SYSIF`` ( ... callnum -- ... ) make calls to the system-specific
    interfacing.
  * ``DEBUG-MEM`` ( -- ) display memory managed by ``ALLOC-MEM``/``FREE-MEM``.
  * ``BSX`` ( byte -- n ) byte sign-extend
  * ``WSX`` ( word -- n ) word sign-extend
  * ``$MEMTOP`` ( -- addr ) variable holding top of memory (byte immediately
    after data space)
  * ``[:`` and ``;]`` [quotations](http://www.forth200x.org/quotations.txt). 
  * Others I probably forgot.

Note that individual platform ports may provide their own additional words.
