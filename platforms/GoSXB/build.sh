#!/bin/bash
set -e -x
cd $(dirname $0)
if [ -r fcode/romfs.fs ]; then
  toke fcode/romfs.fs
fi
if [ -d romfs_files ]; then
  cd romfs_files
  ../mkromfs.rb ../romfs * */**
  cd ..
fi
ca65 -I ../../inc GoSXB.s -l GoSXB.lst
../../build.sh GoSXB
ld65 -C GoSXB.l -S 0x8000 GoSXB.o ../../forth.o -m forth.map -o forth
ca65 -I ../../inc romboot.s -l romboot.lst
ld65 -C romboot.l -S 0x0000 romboot.o -m romboot.map -o rom
ls -l rom forth

