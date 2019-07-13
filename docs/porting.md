# Porting OF816

OF816's base system is usable either as a library of sorts or as the basis of a
port to a particular platform.  The main build script in the root directory,
when given no platform argument, will create a forth.o in the same location that
may be linked at any address with ld65.

A specific platform may be supported by creating a platforms/<name> directory
and populating it.  The best way to see how to do this is to examine the
existing ports.

## Linker/Segments

When creating a ld65 configuration file, the following segments must be
configured/placed:
  * ZEROPAGE - a bss segment for the direct page.  The system will initialize
    this.
  * FSystem - The main system.  ROMable.
  * FCode - Place as an optional segment.  May be located in a separate bank.
    ROMable.

Segments may *not* cross bank boundaries.

## Using as a "Library"

To use OF816 as a library, set your options in config.inc and run build.sh.
The resulting Forth.o may be linked as per above and placed in RAM or ROM.

Currently the beginning of the FSystem segment has a jump table with two entries
that may be called using JSL:

### FSystem+$0: ``_Forth_initialize``

This call initializes the Forth interpreter.  This should be called with the
direct page register set to the address you wish the Forth interpreter to use.
The other registers need not contain any specific values.

The 65C816 stack should contain the following items when ``_Forth_initialize``
is called:

```
+--------- Top of Stack ----------+
| System Memory High              | 32-bit
| System Memory Low               | 32-bit
| Stack Top      |                  16-bit
| Stack Bottom   |                  16-bit
| Return Stk Top |                  16-bit
| System Interface Function       | 32-bit
-------- Bottom of Stack ---------+
```

System Memory High and Low define the data space used by Forth.  This space must
be contiguous and may cross bank boundaries.  The Low address points to the
first usable byte in data space, and the High address points to the byte
immediately after the last usable byte in data space.

The Stack Top and Stack bottom define the addresses of the Forth parameter stack
*relative to the direct page*.  The stack grows downward as the 65C816 does, but
the stack pointer (X register) points to the first entry of the Forth stack
(rather than the first unused byte). The Top is the address immediately after
the first usable cell.  The Bottom value is the address of the last usable cell.
Note this reverse of sense with regard to how items on the stack are referred.

The Return Stack Top is the address in Bank 0 that has the highest usable
address of the return stack to be used by Forth.  Calls to Forth will save the
return stack pointer upon entry and restore it on exit.

To meet the standards to which OF816 strives for and prevent ``ENVIRONMENT?``
from lying, the parameter stack and return stack must be at least 64 cells in
size (256 bytes).

The System Interface Function is described in its own section, below.

The system does not use any absolute addresses (though platform ports might),
so it is entirely possible to initialize more than one Forth in a system.  An
external task manager could multitask these, in theory.  Subsequent calls to an
initialized Forth require only that the direct page be correctly set.

### FSystem+$3: ``_Forth_ui``

This should be called with the direct page set to the Forth direct page used
when ``_Forth_initialize`` was called.  This function enters the outer
interpreter (the user interface of Forth) and does not return until ``BYE``
is executed.

## Using as a Port

The system may be specifically ported to a platform.  This has the advantage of
allowing platform-specific words to be defined as well as providing a means to
initialize other parts of the system prior to initializing the Forth system.

The best way to see how to do a platform port is to examine the Apple IIgs and
W65C816SXB ports included with OF816.

Ports must still define their System Interface Function and use the jump table
described above, but the code may use internals of the Forth system for ease of
implementation and compactness.

## The System Interface Function

When ``_Forth_initialize`` is called, one of the parameters passed to it is the
System Interface Function.  This function is used to allow for extra
initialization of the system as well as provide console and other services.

The System Interface Function is always called with the following:
  * Called via JSL.
  * Processor in native mode with long registers.
  * Direct page and return stack pointers are the Forth system values.
  * A register: Function code (values described below).  Function codes < $8000
    are reserved to be defined by the Forth system.  Function codes >= $8000
    may be defined by the platform port.
  * X register: Forth stack pointer (relative to direct page).  The Forth stack
    consists of 32-bit cells and grows downward.
  * Y register: Current depth of Forth stack.

The System Interface Function must exit with the following:
  * Return via RTL, with the processor mode, direct page, and return stack
    intact.
  * Have the expected Forth parameter stack effects.
  * The A and Y registers contain the high and low words of a throw code or zero
    if successful.
  * Carry set if an error occurred (``THROW`` will be executed in most cases).
  * Carry clear if no error occurred.

### System Interface Function Codes

#### $0000 - Pre Initialize Platform ( -- )

This is called immediately before the inner interpreter is entered for the first
time for initialization, so that last-minute platform initialization may occur.

This routine is not checked for errors.

#### $0001 - Post Initialize Platform ( -- )

This is called immediately after the inner interpreter exits from
initialization, so that additional platform-specific initialization may occur.

This routine is not checked for errors.

#### $0002 - Emit Character ( char -- )

This routine should emit a the given character to the console output device.

#### $0003 - Input Ready Query ( -- f )

Return with f true (all bits set, typically) if there is a character ready to
be read from the console input device.

#### $0004 - Input Character ( -- char )

Recieve char from the console device, waiting for it to arrive.

#### $0005 - FCode List Pointer ( -- address ) currently not used

When FCode support is built into the Forth system, this function should return either
zero, or the address of one or more cells containing the addresses of tokenized FCode 
to evaluate at initialization time.  The list should end with a zero.

The system trusts that there is FCode at each address in the list and calls 1 BYTE-LOAD
for each address in the list.

#### $0006 - Reset-All ( -- ) reboot the system as if the power had been cycled

When this call is made, it should reset the system as if the power had been
recycled.  If this is not possible for the platform, it should return an
exception code.
