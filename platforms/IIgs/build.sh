#!/bin/bash
ACMD=~/bin/AppleCommander-ac-1.5.0.jar
set -e -x
cd $(dirname $0)
ca65 -I ../../inc IIgs.s -l IIgs.lst
../../build.sh IIgs
ld65 -C IIgs.l -S 0x8000 IIgs.o ../../forth.o -m forth.map -o forth
ls -l forth
if [ -r "${ACMD}" ]; then
  java -jar ${ACMD} -pro140 forth.po FORTH
  java -jar ${ACMD} -p forth.po FORTH SYS < forth
fi

