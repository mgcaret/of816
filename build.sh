#!/bin/bash
cd `dirname ${0}`
PLATFORM=""
if [ -n "${1}" -a -d "platforms/${1}" ]; then
  PLATFORM="${1}"
fi
export PLATFORM
echo ".define PLATFORM \"${PLATFORM}\"" > platform.inc
set -e -x
ca65 -I inc forth.s -l forth.lst

