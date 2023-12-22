#!/usr/bin/env bash
set -o errexit -o nounset

TMP=$(mktemp -d)
mkdir -p $TMP/src/parent/child

ln -s $PWD/.swcrc $TMP
ln -s $PWD/src/index.ts $TMP/src
ln -s $PWD/src/parent/index.ts $TMP/src/parent
ln -s $PWD/src/parent/child/index.ts $TMP/src/parent/child

cd $TMP
ls -alR
~/Downloads/swc-darwin-x64_v1.3.100 compile --config-file .swcrc --out-dir dist/swc src
grep import dist/swc/src/index.js
grep import dist/swc/src/parent/index.js
