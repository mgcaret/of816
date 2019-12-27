#!/bin/bash
set -e -x
ca65 -I ../../inc GoSXB.s -l GoSXB.lst
../../build.sh GoSXB
ld65 -C GoSXB.l -S 0x8000 GoSXB.o ../../forth.o -m forth.map -o forth
ca65 -I ../../inc romboot.s -l romboot.lst
ld65 -C romboot.l -S 0x0000 romboot.o -m romboot.map -o rom
ls -l rom forth

