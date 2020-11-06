# Open Firmware for OF816

This directory contains Forth source implementing Open Firmware on top of
OF816.  It is based on IBM's [Slimline Open Firmware](https://github.com/aik/SLOF)
that is notably used in IBM POWER systems and QEMU.

**There are Bugs**
* Package instances don't quite work right.

Working features:
* Device tree.
* Properties.

Unimplemented features:
* FCode additions (to-do).
* nvram (board-level addon).
* Framebuffer/display support (to-do).
* Device probing (to-do).
* Support packages (to-do).
* FCode debugging and Forth source-level debugging (probably won't do).
* Client interface.
* Other miscellania.

Difficulties:
* SLOF is based on a 64-bit system.  The basic stuff ports to 32-bit
  easily enough, but the cool stuff like FAT and ext2 support rely on
  the 64-bit extensions.

The build script borrows tricks from SLOF to incorporate the C preprocessor
and remove comments and extra lines from the code, producing a single file
that can be used with EVALUATE.

SLOF is licensed under a BSD license, and since the files in this directory
are a derivative work, the license is reproduced in this directory as
SLOF-LICENSE.

