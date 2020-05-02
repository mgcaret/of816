#!/bin/bash
EXEBIN=${GOSXB:-gosxb}
cd `dirname $0`
ROMFSOPTS=
if [ -r romfs ]; then
  ROMFSOPTS="-load 0x220000:romfs -rom-bank 0x22"
fi
exec ${EXEBIN} -load 0x200000:forth -rom-bank 0x20 ${ROMFSOPTS} -rom-file rom
