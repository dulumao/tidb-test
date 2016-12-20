#!/bin/bash
echo massive ddl test start
rm -rf ./massive-ddl-server
rm -rf ./nohup.out

go build
go build -o massiveddl_tidb-server github.com/pingcap/tidb/tidb-server

if [ "${TIDB_TEST_STORE_NAME}" = "tikv" ]; then
    nohup ./massiveddl_tidb-server -P 4001 -join-concurrency=1 -status 10081 -lease 0 -L error -store tikv -path "${TIKV_PATH}" &
else
    nohup ./massiveddl_tidb-server -P 4001 -join-concurrency=1 -status 10081 -store memory -L error &
fi
SERVER_PID=$!

sleep 3

./massive_ddl_test 

EXIT_CODE=$?

kill -9 $SERVER_PID

echo massive ddl test end
exit $EXIT_CODE
