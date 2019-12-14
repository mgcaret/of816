#!/bin/bash
set -e -x
cd $(dirname $0)
ca65 -I ../../inc Neon816.s -l Neon816.lst
ca65 -I ../../inc romboot.s -l romboot.lst
../../build.sh Neon816
ld65 -vm -C Neon816.l Neon816.o ../../forth.o ./romboot.o -m forth.map -o of816-neon.bin
ls -l of816-neon.bin
if which -s bin2hex; then
  bin2hex of816-neon.bin > of816-neon.hex
  ls -l of816-neon.hex
fi

