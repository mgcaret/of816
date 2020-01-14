#!/bin/bash
cd `dirname $0`
./index.rb ../asm/forth-dictionary.s | ./index2md.rb - "Forth Dictionary" > ../docs/forth_dictionary.md
