#!/bin/bash

echo xormtest start
rm -rf ./xormtest_tidb-server
rm -rf ./nohup.out
rm -rf ./data
go build -o xormtest_tidb-server github.com/pingcap/tidb/tidb-server

if [ "${TIDB_TEST_STORE_NAME}" = "tikv" ]; then
    nohup ./xormtest_tidb-server -P 4001 -join-concurrency=1 -status 10081 -lease 0 -L error -store tikv -path "${TIKV_PATH}" &
else
    nohup ./xormtest_tidb-server -P 4001 -join-concurrency=1 -status 10081 -store memory -L error &
fi
SERVER_PID=$!

sleep 3
EXIT_CODE=$?

cd ../vendor/github.com/go-xorm/tests/ && sh ./run_tests.sh mysql
kill -9 $SERVER_PID

echo xormtest end
exit $EXIT_CODE
