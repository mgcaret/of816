#!/bin/bash
set -e -x
toke fcode/romloader.fs
ruby mkromfs.rb romfs fs/*
ca65 -I ../../inc W65C816SXB.s -l W65C816SXB.lst
../../build.sh W65C816SXB
ld65 -C W65C816SXB.l -S 0x8000 W65C816SXB.o ../../forth.o -m forth.map -o forth
ls -l forth

