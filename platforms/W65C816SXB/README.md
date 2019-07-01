# W65C816SXB

This is a port to WDC's [W65C816SXB](https://wdc65xx.com/boards/w65c816sxb-engineering-development-system/)
development board.  To build it, change to the platform directory and run
build.sh.  This will output a binary named "forth" that is suitable for placing
in one of the Flash ROM banks of the W65C816SXB at $8000. Andrew Jacob's
[w65c816sxb-hacker](https://github.com/andrew-jacobs/w65c816sxb-hacker) is
suitable for this.  Note that OF816 currently uses the USB port as the console
device.

You may also create a completely custom ROM image that replaces the WDC monitor
with OF816, all that is required (assuming you are not going to use interrupts)
is to point the RESET vector to $8000.  It may be desirable to point the NMI
vector at a routine that resets the system stack pointer and jumps to
``_Forth_ui``.

While this platform provides the "reference" platform with regards to system
implementation, configuring it and making it work are an advanced topic.

**Note:**  None of WDC's tools are used to build OF816.


## Port Features

### Banked ROM Access

The platform words include ``$SXB-READROM`` ( rom_addr dest_addr size -- ).
This word allows copying size bytes from any bank in the ROM into dest_addr.

The rom_addr is an address of the form $bb00xxxx where bb is the bank number
(0-3) and xxxx is the physical address of the memory in bank 0.  I.e. the
valid ranges are $00008000-$0000FFFF, $01008000-$0100FFFF, etc.

### FCode/romfs ROM Loader

If FCode support is enabled, the word ``$SXB-ROMLDR`` is included in the
platform words.  This encapsulates ``fcode/romloader.fs`` and executing it will
cause the ROM Loader and romfs words to be installed (romfs support may be
disabled, see the source).

The ROM Loader keeps a $100-byte cache of the last ROM page read in order to
reduce the number of bank-switch/copy operations.

Once the ROM Loader and romfs are installed, the following words are available:

#### FCode Loader Words

``$SXB-ROM-FCODE-AT?`` ( rom-addr -- f ) f is true if there is a FCode magic
("MGFC") at the given ROM address.  rom-addr must be on a page boundary.

``$SXB-ROM-BYTE-LOAD`` ( rom-addr -- ) evaluate FCode at rom-addr, satisified
by the conditions of ``$SXB-ROM-FCODE-AT?``.

``$SXB-FC-BOOT`` ( -- ) search ROM at $1000-byte alignments for FCode identified
by ``$SXB-ROM-FCODE-AT?`` and evaluate it.

#### romfs Words

romfs words generally follow the ANS Forth File Access word set guidelines,
however they automatically throw non-zero IORs, therefore if the word returns
normally the IOR is always 0.  Consult the ANS standard for complete description
of stack items.

``INCLUDE`` ( <>"name" -- ... ) parse name and perform the function of INCLUDED.

``INCLUDED`` ( c-addr u -- ... ) evaluate romfs file named by c-addr u.

``OPEN-FILE`` ( c-addr u fam -- fileid 0 ) open romfs file, fam is discarded,
access is always read-only.

``READ-LINE`` ( c-addr u fileid - u2 f 0 ) read a line up to u bytes from file.

``READ-FILE`` ( c-addr u fileid - u2 0 ) read up to u bytes from file.

``FILE-POSITION`` ( fid -- u ) return read position in file

``CLOSE-FILE`` ( fileid -- 0 ) close romfs file

``ROMFS-LIST`` ( -- ) list files in romfs.

``$SXB-ROM-ROMFS-AT?`` ( rom-addr -- f ) f is true if there is a ROMFS magic
("MGFS") at the given ROM address.  rom-addr must be on a page boundary.

``$SXB-ROMFS`` ( -- u ) VALUE, zero if no romfs was found, otherwise contains
the ROM address of the romfs.
