# Open Firmware for OF816

This directory contains Forth source implementing Open Firmware on top of
OF816.  It is based on IBM's [Slimline Open Firmware](https://github.com/aik/SLOF)
that is notably used in IBM POWER systems and QEMU.

**There are Bugs**

The build script borrows tricks from SLOF to incorporate the C preprocessor
and remove comments and extra lines from the code, producing a single file
that can be used with EVALUATE.

SLOF is licensed under a BSD license, and since the files in this directory
are a derivative work, the license is reproduced in this directory as
SLOF-LICENSE.

