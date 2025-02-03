#!/bin/bash
set -e -x
cd $(dirname $0)
if [ -r fcode/romfs.fs ]; then
  toke fcode/romfs.fs
fi
if [ -d romfs_files ]; then
  ../../ofw/build.sh
  cp ../../ofw/out/of-blob.fs romfs_files/of.fs
  cd romfs_files
  ../mkromfs.rb ../romfs * */**
  cd ..
fi
ca65 -I ../../inc GoSXB.s -l GoSXB.lst
../../build.sh GoSXB
ld65 -C GoSXB.l -S 0x8000 GoSXB.o ../../forth.o -m forth.map -o forth
ca65 -I ../../inc romboot.s -l romboot.lst
ld65 -C romboot.l -S 0x0000 romboot.o -m romboot.map -o rom
ld65 -C romboot-small.l -S 0x0000 romboot.o -m romboot-small.map -o smallrom
ls -l smallrom rom forth romfs

