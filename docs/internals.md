# OF816 Internals

## System Description

OF816 is a portable direct-threaded ANS Forth system for the WDC 65C816
processor.

The system features 32-bit code and data cells, and implements a 32-bit virtual
address space (truncated to 24-bit physical addresses).

## Code Organization

The main file ``forth.s`` is the sole source file that is directly given to the
assembler.  This file brings in all the other source via ca65's ``.include``
directive.

### Include Files

#### ``config.inc``

In the top level directory, ``config.inc`` contains configuration
options for the build in the form of ca65 ``.define`` directives.

#### ``platform.inc``

Additionally, when ``build.sh`` is executed it creates a ``platform.inc`` file
that sets the platform to build. ``PLATFORM`` is defined as a blank value if no
platform is given.  Otherwise, if a platform is passed to ``build.sh`` and a
directory in ``platforms/`` exists that matches, ``PLATFORM`` will be set to
that value.

#### ``inc/macros.inc``

Macros for the system are in this and include dictionary macros,
shortcut macros for common Forth operations (e.g. ``NEXT``), and other items.

This also contains some system-specific equates and constants not included
in ``inc/equates.inc``.

#### ``inc/equates.inc``

Contains general equates for the system, including direct page, system interface
function codes, compiler constants, characters, etc.

### Source Code

The non-platform source code is in ``asm/`` and contains the following files.

#### ``asm/compiler.s``

Contains support routines related to the the Forth compiler and appending
to data space in general.

#### ``asm/env-dictionary.s``

Contains the environmental queries dictionary.

#### ``asm/fcode.s``

Contains most of the FCode support code, less a few items that end up in the
Forth dictionary.  This code is assembled in the "FCode" segment.

#### ``asm/forth-dictionary.s``

Contains all of the Forth dictionary, including headerless helper words.

#### ``asm/interpreter.s``

Contains the inner interpreter and supporting code.

#### ``asm/mathlib.s``

Contains routines for basic math operations that need to be used by native
code, as well as the integer multiplication and division routines.

#### ``asm/memmgr.s``

Contains memory management routines, including the heap allocator and fast
memory move routines.

#### ``asm/system.s``

Contains the system entry points, initial system variables, and system
interfacing routines.

### Platform Files

Each platform is expected to provide at least the following files when a build
is created for a specific platform. Other files may be included by these files.

A platform will typically also have code that instantiates the interpreter and
is linked with the built ``forth.o`` as well as a linker configuration file.

#### ``platform-config.inc``

If the platform allows for additional configuration defines, these should be
placed here.

#### ``platform-lib.s``

This file should contain the necessary platform-specific code and will often
contain all system interfacing that occurs when the system is instantiated.

#### ``platform-words.s``

This file should contain any additonal entries that are to appear in the Forth
dictionary.

## Forth Interpreter

For reference on the basic construction and operation of a Forth interpreter,
see _Threaded Interpretive Languages_ by R.G. Loeligern (Byte, 1981).

### System Registers

The Forth system interpreter registers are implemented as follows:

**I** (IP): The Instruction register is implemented on the direct page as the
32-bit pointer **IP**.  The IP always points to the byte immediately before the
next Forth code cell.

**WA/CA**: Being a direct-threaded interpreter, word address and code address
are effectively the same.  The WA/CA register in this system is ephemeral
in that the next code address to execute is typically held in the 65816 A+Y
registers and then the lower 24-bits pushed onto the stack and finally executed
via RTL.

**RS**: The Forth return stack register is the 65816 stack register.

**SP**: The Forth paramter stack register is the 65816 X register.

**WR/XR/YR/ZR**: Direct-page working registers for use by primitives.

### Main Inner Interpreter Routines

The inner interpreter consists of the routines in ``interpreter.s`` that
explicitly implement the inner interpreter as well as all routines that support
execution of Forth code.

The main portion of the inner interpreter consists of the following routines.

**``_enter``**: enter (or nest) the Forth interpreter.

This routine swaps the 24-bit return address on the 65816 return stack for the
32-bit Forth IP and begins interpreting Forth code cells.

The net effect is that when entered via JSL, the old IP is saved, and the next
Forth code cell to be executed is immediately after the JSL instruction.

Shortcut macro: ``ENTER``.

**``_next``**: fetch and execute the next Forth code cell.  This is the usual
method to exit Forth primitives.

Shortcut macros: ``NEXT`` (same-segment/bank), ``LNEXT`` (different segment/
bank).

**``__next::run``**: Execute Forth code beginning with the Forth XT in the
65816 AY registers.

Shortcut macros: ``RUN``

The Forth word ``EXECUTE`` is implemented (in pseudo-code) as:  POP AY; RUN.

**``_exit_next``**: Restore previous IP from return stack and execute the next
code cell.  This is the usual method to exit Forth secondaries.

Shortcut macro: ``EXIT``.

**``_exit_code``**:  Swap the 32-bit previous IP on the return stack with the
24 low bits of the Forth IP and resume native code execution via RTL.

The net effect is to resume native code execution after this word is executed
as a Forth XT.

Shortcut macro: ``CODE``.

Multiple ``ENTER``s and ``CODE``s may be used to freely mix Forth and native
code.

## Dictionary

### Dictionary Format

The dictionary format is as follows:

```
+---------+--------------------------------------------------------|
| Size    | Use                                                    |
+---------+--------------------------------------------------------|
| 4 bytes | Link to previous word (0 if end of dictionary)         |
| 1 byte  | Name length + $80 (high bit always set) if $80, noname |
| n bytes | Name                                                   |
| 1 byte  | Flags                                                  |
| m bytes | Code                                                   |
+---------+--------------------------------------------------------|

Flags bits:
+-----+-------------------------------+
| 7   | Immediate                     |
| 6   | Compile-only                  |
| 5   | Protected (not FORGETtable)   |
| 4   | Trigger temporary definition  |
| 3   | Smudged (not found in search) |
| 2-0 | unused                        |
+-----+-------------------------------+
```

### Word Lists/WIDs

WIDs are pointers to wordlist objects.

A wordlist object consists of two cells.  The first cell points to the head
(most recently-defined definition) of the wordlist.  The second cell is either
0 or contains an XT, the name of which is used for the name of the wordlist
for display purposes (e.g. when ``ORDER`` is executed).  Typically the XT's
execution semantics are to place the given wordlist at the top of the search
order.

### Dictionary Macros

``macros.inc`` provides macros for creating dictionaries/definitions.  They are
not all documented here, but a brief overview is:

A dictionary is begun with ``dstart <name>`` and finished with ``dend``.

In between are one or more definitioons created with ``dword`` or ``hword``
and ``eword``.  ``dword <label>,"<NAME>"[,<flags>]`` creates a definition with a
header and ``hword <label>,"<NAME>"[,<flags>]`` creates a headerless (noname)
definition.  Flags are generally meaningless in a headerless definition.

The label is created at the execution token address of the definition, which is
always the flags byte, which is one byte less than the actual executable code.

The name must always be in capital letters, however dictionary searches are
case-insensitive.

### Primitive Definitions

A typical primitive is defined as follows:

```
dword my_word,"MY-WORD"
<native code>
NEXT
eword
```

### Secondary Definitions

A secondary that called the above primitive would be defined as:

```
dword my_word_secondary,"MY-WORD-SECONDARY"
ENTER
.dword my_word
EXIT
eword
```

Here, ``ENTER`` nests the interpreter and ``EXIT`` un-nests the interpreter
and executes NEXT.
