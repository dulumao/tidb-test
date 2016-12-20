#!/bin/bash
rm -rf var

go get github.com/dvyukov/go-fuzz/go-fuzz
go get github.com/dvyukov/go-fuzz/go-fuzz-build

mkdir -p var
cd var

echo "begin to build fuzz test archive"
go-fuzz-build github.com/pingcap/tidb-test/fuzz_test/fuzz
echo "run infinite fuzz test, please use ctrl + c to stop it......"
go-fuzz -bin=./fuzz-fuzz.zip -workdir=./
