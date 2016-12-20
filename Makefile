all: test cleanup

test: mysqltest tidbtest gormtest xormtest gosqltest sqllogictest benchtest cleanup

benchtest: benchcount benchkv bencholtp

tidbtest: vendor
	@cd tidb_test && ./run-tests.sh

mysqltest: vendor
	@cd mysql_test && ./run-tests.sh

xormtest: vendor
	@cd xorm_test && ./run-tests.sh

gormtest: vendor
	@cd gorm_test && ./run-tests.sh
	
gosqltest: vendor
	@cd go-sql-test && ./run-tests.sh

sqllogictest: vendor
	@cd sqllogic_test && ./run-tests.sh

fuzztest: vendor
	@cd fuzz_test && ./run-tests.sh

ddltest: vendor
	@cd ddl_test && ./run-tests.sh

massiveddltest: vendor
	@cd massived_ddl_test && ./run-tests.sh

clustertest:
	@cd cluster_test && go build .

stabilitytest:
	@cd stability_test && go build . 

tidb-bridge:
	@cd bridge && go build -o tidb-bridge .

benchcount:
	@cd bench_test/benchcount-test && go build .

benchkv:
	@cd bench_test/benchkv-test && go build .

bencholtp:
	@cd bench_test/bench-oltp && go build .

tikv: export TIDB_TEST_STORE_NAME=tikv
tikv: vendor tikv-env test

tikv-env:
ifndef TIKV_PATH
	$(error Please define TIKV_PATH for tikv tests, the format is 'etcd_host:port')
endif

vendor:
	rm -rf vendor && ln -s _vendor/vendor vendor

cleanup:
	rm -rf vendor
