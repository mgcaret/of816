#!/bin/bash
set -e -x
ca65 -I ../../inc Neon816.s -l Neon816.lst
../../build.sh Neon816
ld65 -C Neon816.l -S 0x8000 Neon816.o ../../forth.o -m forth.map -o forth
ls -l forth

