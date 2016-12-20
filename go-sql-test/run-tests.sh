#!/bin/bash
echo gosqltest start
rm -rf ./gosqltest_tidb-server
rm -rf ./nohup.out

go build -o gosqltest_tidb-server github.com/pingcap/tidb/tidb-server

if [ "${TIDB_TEST_STORE_NAME}" = "tikv" ]; then
    nohup ./gosqltest_tidb-server -P 4001 -status 10081 -lease 0 -store tikv -path "${TIKV_PATH}" &
else
    nohup ./gosqltest_tidb-server -P 4001 -status 10081 -store memory &
fi
SERVER_PID=$!

sleep 3

MYSQL_TEST_CONCURRENT=1 MYSQL_TEST_ADDR=127.0.0.1:4001 MYSQL_TEST_DBNAME=test go test ./sqltest/...
EXIT_CODE=$?

kill -9 $SERVER_PID

echo gosqltest end
exit $EXIT_CODE
