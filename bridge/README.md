## example

Assume we start a TiKV with `127.0.0.1:20160`, let's use `127.0.0.1:21160` as its advertise address. 

```bash
./tidb-bridge -delay-accept=false -reset-listen=false -conn-fault-rate 0.05 127.0.0.1:21160 127.0.0.1:20160 
```