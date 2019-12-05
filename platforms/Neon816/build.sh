#!/bin/bash
set -e -x
ca65 -I ../../inc Neon816.s -l Neon816.lst
ca65 -I ../../inc romboot.s -l romboot.lst
../../build.sh Neon816
ld65 -C Neon816.l -S 0x8000 Neon816.o ../../forth.o ./romboot.o -m forth.map -o of816-neon.bin
ls -l of816-neon.bin
if which -s bin2hex; then
  hex2bin of816-neon.bin > of816-neon.hex
  ls -l of816-neon.hex
fi

