#!/bin/bash

# This script tokenizes FCode via toke and prepends a small header for identification
# by the ROM scanner (currently only implemented for the W65C816SXB).

cd `dirname ${0}`
if [ -r "${1}.fs" ]; then
  toke "${1}.fs"
  echo -n "MGFC" | cat - "${1}.fc" > ${1}.rom
else
  echo "No source for ${1}!"
fi
