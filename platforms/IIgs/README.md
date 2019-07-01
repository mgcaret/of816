# OF816 for Apple IIgs

This is a port to the Apple IIgs system, the most commercially-successful
personal computer to use the 65C816.  The build.sh script builds a ProDOS SYS
file (note: not a GS/OS S16 file) that can be launched from GS/OS or ProDOS 8,
or even as the PRODOS file on a disk with a ProDOS boot block.

The port has the following system-specific features:
  * ``BYE`` returns to the launching OS.
  * Data space allocated from the GS ToolBox Memory Manager.
  * Console I/O through the slot 3 Pascal 1.1 fimrware interface.
  * ANSI terminal emulation as required by IEEE 1725-1994, except (for now)
    Insert Character and Delete Character, with additional non-required codes.
  * GS Toolbox call support.
  * ProDOS 8 MLI call support.
  * Some pre-canned spaces reserved in bank 0 for buffers, etc.

## Building

You may need to modify the build script.  It currently uses AppleCommander (a
Java-based Apple II disk image utility) to make a disk image suitable for
emulators.

## Platform-Specific Words

  * ``LINE#`` ( -- u ) return cursor vertical position.
  * ``COLUMN#`` ( -- u ) return cursor horizontal position.
  * ``$GS-USERID`` ( -- u ) return the ToolBox user ID of the Forth system.
  * ``$GS-TOOLCALL`` ( i\*n i tbyte1 j tybet2 tool# -- j\*n ) Call Apple IIgs
    toolbox call tool#, putting i items on the return stack before the call,
    with sizes specified in the bits in tbyte1 (0 = word, 1 = long), and
    retrieving j items from the return stack after the call, with sizes
    specified by the bits in tbyte2.  Note that the parameters go onto the
    return stack in the opposite order they are on the parameter stack.
  * ``$P8-CALL`` ( call# addr ) call ProDOS 8 function call#, with paramter
    list at addr.
  * ``$P8-BUFS`` ( -- addr ) return address of memory that can be used for
    ProDOS 8 buffers.
  * ``$P8-#BUFS`` ( -- u ) the total number of $400-byte buffers at ``$P8-BUFS``
  * ``$P8-PPAD`` ( -- addr ) address of a $100-byte scratchpad that can be used
    as a space to assemble ProDOS call parameters.
  * ``$P8-RWBUF`` ( -- addr ) address of a $100-byte space that can be used for
    a data buffer for ProDOS calls.
  * ``$P8-BLKBUF`` ( -- addr ) address of a $400-byte space that can be used
    as a block data buffer to implement the block word set.

Note that none of the File or Block word sets are implemented, but they may
be implemented on top of the above.

Some pre-canned toolbox calls:

  * ``_TOTALMEM`` ( -- u ) return size of memory installed in system.
  * ``_READBPARAM`` ( u1 -- u2 ) read battery RAM parameter u1.
  * ``_READTIMEHEX`` ( -- u1 u2 u3 u4 ) read time in hex format.
  * ``_READASCIITIME`` ( addr -- ) read 20 byte time string into buffer at addr.
  * ``_FWENTRY`` ( addr y x a -- y x a p ) call firmware entry in bank 0.
  * ``_SYSBEEP`` ( -- ) play the system bell.
  * ``_SYSFAILMGR`` ( addr u -- ) call fatal error handler, u = error code and
    addr = address of packed string message or 0 for default message.

Example implementation of the pre-canned system calls to show how
``$GS-TOOLCALL`` is used:

```
HEX
: _TOTALMEM 0 0 1 1 1D02 $GS-TOOLCALL ;
: _READBPARAM 1 0 1 0 C03 $GS-TOOLCALL ;
: _READTIMEHEX 0 0 4 0 D03 $GS-TOOLCALL ;
: _READASCIITIME 1 1 0 0 F03 $GS-TOOLCALL ;
: _FWENTRY 4 0 4 0 2403 $GS-TOOLCALL ;
: _SYSBEEP 0 0 0 0 2C03 $GS-TOOLCALL ;
: _SYSFAILMGR 2 2 ( %10 ) 0 0 1503 $GS-TOOLCALL ;
```

## Internals

The Apple IIgs port initializes the GS Toolbox if necessary, and then requests
memory for the data space from the Memory Manager (amount defined in 
``platform-config.inc``).  This memory is released when ``BYE`` is executed.

The startup code captures the Pascal I/O vectors for slot 3 and puts them in 
page 3, to be later used by the System Interface Function.

Bank 0 memory map:

```
+--------------------------------+ $FFFF
|                                |
| ROM                            |
|                                |
+--------------------------------+ $D000
| I/O                            |
+--------------------------------+ $C000
+ ProDOS global page             |
+--------------------------------| $BF00
|                                |
|                                |
| Forth System                   | 
|                                |
|                                |
+--------------------------------| $2000
| BLKBUF ($400)                  |
| IOBUF0-2 ($400 each)           |
+--------------------------------+ $1000
| PPAD ($100)                    |
| RWBUF ($100)                   |
|--------------------------------| $0E00
| Forth Return Stack             |
+--------------------------------| $0B00
| Forth Parameter Stack          |
+--------------------------------| $0900
| Forth Direct Page              |
+--------------------------------| $0800
| Text Page 0 (screen)           |
+--------------------------------| $0400
| Sys. Vectors and Scratch       |
+--------------------------------| $0300
| System Input Buffer (unused)   |
+--------------------------------| $0200
| System Return Stack            |
+--------------------------------| $0100
| System Direct Page             |
+--------------------------------| $0000
```
