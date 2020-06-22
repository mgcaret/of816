# OF816
OF816 is a [65C816](https://www.westerndesigncenter.com/wdc/w65c816s-chip.cfm)
Forth implementation heavily inspired by 
[Open Firmware (IEEE 1275-1994)](https://www.openfirmware.info/Welcome_to_OpenBIOS).

Note that OF816 is *not* an Open Firmware implementation (yet), but it has the
potential (and groundwork has been done) for it to become one.

## Features

Among its many features are:
  * Mostly platform-independent.  OF816 can be ported easily to new systems.
    * Ports currently exist for the following platforms:
      * [WDC W65C816SXB](https://wdc65xx.com/Single-Board-Computers/w65c816sxb/).
      * [Neon816](https://hackaday.io/project/164325-neon816).
      * [Apple IIgs](https://en.wikipedia.org/wiki/Apple_IIGS).
      * [C256 Foenix](https://c256foenix.com) via [this fork](https://github.com/aniou/of816).
      * GoSXB - an unreleased emulator designed for OF816 development.
    * New ports require the implementation of a handful of routines.
    * Simple instantiation of one or more Forths in a system.
  * 32-bit cells.
  * ROM-able.
    * The core system does not write outside of data space, except to the 65816
      direct page and stack.  
    * System variables are provisioned at the start of data space when the sytem
      is initialized.
  * Optional [FCode](https://www.openfirmware.info/Forth/FCode) support 
    (less Device Tree and Package functions).
  * [ANS Forth](http://lars.nocrew.org/dpans/dpans.htm)
    * Core, most of Core Ext, Exception, Search Order, and Search Order Ext word
      sets.
    * Smattering of words from other sets.
    * Good conformance test coverage.

## Goal

The goal of OF816 is to help get 65C816-based projects off the ground in terms
of development and testing.  With a little effort it can be brought up on a new
system and used to play around with new hardware.

OF816 is not designed for speed.  While reasonably performant, the primary goal
was compatibility with 32-bit Open Firmware's core word set, cell size, and
FCode. This allows the possibility of re-using existing Forth source and FCode
to develop hardware drivers, and potentially developing OF816 into a full Open
Firmware implementation.

## Resources

In addition to the links above, please see the ``LICENSE`` file, ``docs\``, and
the directories under ``platforms\``.

OF816 is licensed under a two-clause BSD license.
