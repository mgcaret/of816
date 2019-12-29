#!/bin/bash
EXEBIN=${GOSXB:-gosxb}
exec ${EXEBIN} -load 0x200000:forth -rom-bank 0x20 -rom-file rom
