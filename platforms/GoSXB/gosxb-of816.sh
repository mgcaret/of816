#!/bin/bash
EXEBIN=${GOSXB:-gosxb}
cd `dirname $0`
ROMFSOPTS=
if [ -z "$1" ] && [ -r romfs ]; then
  ROMFSOPTS="-add-rom 0x220000:romfs"
fi
exec ${EXEBIN} -add-rom 0x200000:forth ${ROMFSOPTS} -rom rom
