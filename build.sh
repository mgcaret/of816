#!/bin/bash
cd `dirname ${0}`
PLATFORM=""
ADD_OPTS=""
if [ -n "${1}" -a -d "platforms/${1}" ]; then
  PLATFORM="${1}"
  ADD_OPTS="${ADD_OPTS} -I platforms/${PLATFORM}/inc"
fi
export PLATFORM
echo ".define PLATFORM \"${PLATFORM}\"" > platform.inc
set -e -x
ca65 ${ADD_OPTS} -I inc forth.s -l forth.lst

