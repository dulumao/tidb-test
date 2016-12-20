#!/bin/bash
echo gormtest start
cd gorm
rm -rf ./gormtest_tidb-server
rm -rf ./nohup.out
rm -rf ./data

go build
go build -o gormtest_tidb-server github.com/pingcap/tidb/tidb-server
if [ "${TIDB_TEST_STORE_NAME}" = "tikv" ]; then
    nohup ./gormtest_tidb-server -lease 0 -store tikv -path "${TIKV_PATH}" &
else
    nohup ./gormtest_tidb-server --path=data &
fi
SERVER_PID=$!

sleep 3
go test -log-level=error
EXIT_CODE=$?

kill -9 $SERVER_PID

echo gormtest end
exit $EXIT_CODE
