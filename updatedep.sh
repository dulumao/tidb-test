#!/bin/bash
if [ "$1" == "-h" ] ; then
    echo "Usage: $0 [package]"
    echo "    Update dependency package in vendor."
    echo "    Make sure the package to be updated is on master branch."
    echo "    If [package] is not provided, it updates 'github.com/pingcap/tidb/...'"
    echo ""
    exit 0
fi

rm -rf Godeps vendor && mv _vendor/* .
if [ $# -eq 1 ]; then
    go get -u -v -d $1
    godep update $1
elif [ $# -eq 0 ]; then
    go get -u -v -d github.com/pingcap/tidb
    godep update github.com/pingcap/tidb/...
    cd vendor/github.com/pingcap/tidb && make parser && cd -
else
    echo "Invalid argument count."
fi
mv Godeps vendor _vendor/
