#!/bin/bash
echo tidbtest start
rm -rf ./tidb_test_tidb-server
rm -rf ./tidb_test
rm -rf ./nohup.out

go build
go build -o tidb_test_tidb-server github.com/pingcap/tidb/tidb-server

if [ "${TIDB_TEST_STORE_NAME}" = "tikv" ]; then
    nohup ./tidb_test_tidb-server -P 4001 -status 10081 -lease 0 -store tikv -path "${TIKV_PATH}" &
    SERVER_PID="${SERVER_PID} ${!}"
    sleep 5
    ./tidb_test -parallel 1 -L "error"
else
    for i in `seq 8`
    do
        nohup ./tidb_test_tidb-server -P $((4000+$i)) -status $((10080+$i)) -store memory &
        SERVER_PID="${SERVER_PID} ${!}"
    done
    sleep 5
    ./tidb_test -parallel 8 -L "error"
fi
EXIT_CODE=$?

kill -9 $SERVER_PID

echo tidbtest end
exit $EXIT_CODE
