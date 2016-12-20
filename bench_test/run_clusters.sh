#!/bin/bash

pkill -f -9  "bench"

sleep 1

#rm -rf var 
if [ ! -d "./var" ]; then
    mkdir var
fi
nohup ./bin/bench-pd-server -config=pd_metric.toml  -L=info --data-dir ./var/defautl.etcd  --log-file ./var/pd.log -peer-urls=http://127.0.0.1:52380  -client-urls=http://127.0.0.1:52379&

sleep 5

export RUST_BACKTRACE=1
nohup ./bin/bench-tikv-server --pd 127.0.0.1:52379 -L info -A 127.0.0.1:50161 --advertise-addr 127.0.0.1:50161 -s ./var/store1 --log-file ./var/1.log --config tikv_config.toml &
nohup ./bin/bench-tikv-server --pd 127.0.0.1:52379 -L info -A 127.0.0.1:50162 --advertise-addr 127.0.0.1:50162 -s ./var/store2 --log-file ./var/2.log --config tikv_config.toml &
nohup ./bin/bench-tikv-server --pd 127.0.0.1:52379 -L info -A 127.0.0.1:50163 --advertise-addr 127.0.0.1:50163 -s ./var/store3 --log-file ./var/3.log --config tikv_config.toml &


sleep 3

nohup ./bin/bench-tidb-server -P="50004" -metrics-addr="http://127.0.0.1:9091" -metrics-interval=15 -store=tikv -L info  -path="127.0.0.1:52379/pd" -status="50080" --log-file ./var/tidb.log &
