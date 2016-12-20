#!/bin/bash
echo mysqltest start
rm -rf ./mysqltest_tidb-server
rm -rf ./mysql_test
rm -rf ./nohup.out

go build
go build -o mysqltest_tidb-server github.com/pingcap/tidb/tidb-server

if [ "${TIDB_TEST_STORE_NAME}" = "tikv" ]; then
    nohup ./mysqltest_tidb-server -P 4001 -join-concurrency=1 -status 10081 -lease 0 -L error -store tikv -path "${TIKV_PATH}" &
else
    nohup ./mysqltest_tidb-server -P 4001 -join-concurrency=1 -status 10081 -store memory -L error &
fi
SERVER_PID=$!

sleep 3

if [ -n "$1" ]; then
    if [ "$1" = "-record" ] && [ "$2" != "--log-level" ]; then
        ./mysql_test --record $2 --log-level=error
    elif [ "$1" = "-record"]; then
        rm -rf r/*
        ./mysql_test --record --log-level=error
    fi
else
    ./mysql_test --log-level=error
fi
EXIT_CODE=$?

kill -9 $SERVER_PID

echo mysqltest end
exit $EXIT_CODE
