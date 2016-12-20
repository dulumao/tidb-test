#!/bin/bash
echo sqllogic_test start
rm -rf ./sqllogic_test_tidb-server
rm -rf ./sqllogic_test
rm -rf ./nohup.out

go build
go build -o sqllogic_test_tidb-server github.com/pingcap/tidb/tidb-server

if [ "${SQLLOGIC_TEST_PATH}" = "" ]; then
	# Set default sqllogic test case path to ./test.
	export SQLLOGIC_TEST_PATH=./test
fi

if [ "${TIDB_TEST_STORE_NAME}" = "tikv" ]; then
    nohup ./sqllogic_test_tidb-server -P 4001 -status 10081 -lease 0 -L error -store tikv -path "${TIKV_PATH}" &
    SERVER_PID="${SERVER_PID} ${!}"
    sleep 5
    ./sqllogic_test -log-level=error -skip-error -parallel=1 -p ${SQLLOGIC_TEST_PATH}
else
    for i in `seq 8`
    do
        nohup ./sqllogic_test_tidb-server -P $((4000+$i)) -status $((10080+$i)) -L error -store memory &
        SERVER_PID="${SERVER_PID} ${!}"
    done
    sleep 5
    ./sqllogic_test -log-level=error -skip-error -parallel=8 -p ${SQLLOGIC_TEST_PATH}
fi
EXIT_CODE=$?

kill -9 $SERVER_PID

echo sqllogic_test end
exit $EXIT_CODE
