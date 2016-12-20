#!/bin/bash
echo ddl_test start

if [ ! -f ./ddltest_tidb-server ]; then
    go build -o ddltest_tidb-server github.com/pingcap/tidb/tidb-server
fi
rm -rf ./ddltest/tidb_log_file_*
go test ./... -timeout 60m -v $@

echo ddl_test end
