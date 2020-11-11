#!/bin/bash
set -ex
cd `dirname $0`
mkdir -p out
cpp -w -nostdinc -traditional-cpp -undef -P -C -I. of.fs > out/of-blob.tmp
sed -e 's/^[	 ]*//' < out/of-blob.tmp \
  | sed -e '/^\\[	 ]/d' \
  | sed -e 's/[	 ]\\[	 ].+$//' \
  | sed -e '/^([	 ][^)]*[	 ])[	 ]*$/d' \
  | sed -e '/^$/d' > out/of-blob.fs

rm -f out/of-blob.tmp

