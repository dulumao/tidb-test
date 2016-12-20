// Copyright 2016 PingCAP, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// See the License for the specific language governing permissions and
// limitations under the License.

package main

import (
	"database/sql"
	"flag"
	"fmt"
	"os"
	"os/exec"
	"sync"
	"time"

	_ "github.com/go-sql-driver/mysql"
	"github.com/ngaut/log"
	"github.com/pingcap/tidb/kv"
	"github.com/pingcap/tidb/store/tikv"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/push"
)

var (
	store kv.Storage

	mysqlHost     = flag.String("mh", "127.0.0.1", "mysql Host, used to store result")
	mysqlPort     = flag.Int("mP", 3306, "mysql port, used to store result")
	mysqlUser     = flag.String("mu", "root", "mysql user, used to store result")
	mysqlPassword = flag.String("mp", "root", "mysql password, used to store result")
	mysqlDb       = flag.String("md", "benchresult", "mysql database, used to store result")
	alertAddr     = flag.String("aa", "https://hooks.slack.com/services/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", "alert address")

	dataCnt   = flag.Int("N", 1000000, "data num")
	workerCnt = flag.Int("C", 400, "concurrent num")
	pdAddr    = flag.String("pd", "localhost:52379", "pd address")
	valueSize = flag.Int("V", 5, "value size in byte")

	pushgatewayAddr = flag.String("P", "127.0.0.1:9091", "Pushgateway Address")

	tidbVersion = os.Getenv("TIDB_VERSION")
	tikvVersion = os.Getenv("TIKV_VERSION")
	pdVersion   = os.Getenv("PD_VERSION")

	txnCounter = prometheus.NewCounter(
		prometheus.CounterOpts{
			Namespace: "benchkv",
			Subsystem: "txn",
			Name:      "total",
			Help:      "Counter of txns.",
		})

	txnRolledbackCounter = prometheus.NewCounter(
		prometheus.CounterOpts{
			Namespace: "benchkv",
			Subsystem: "txn",
			Name:      "failed_total",
			Help:      "Counter of rolled back txns.",
		})

	txnDurations = prometheus.NewHistogram(
		prometheus.HistogramOpts{
			Namespace: "benchkv",
			Subsystem: "txn",
			Name:      "durations_histogram_seconds",
			Help:      "Txn latency distributions.",
			Buckets:   prometheus.ExponentialBuckets(0.0005, 2, 13),
		})

	txnElapse = prometheus.NewGauge(
		prometheus.GaugeOpts{
			Namespace: "benchkv",
			Subsystem: "txn",
			Name:      "elapse_time",
			Help:      "elapse time seconds.",
		})
)

func Init() {
	driver := tikv.Driver{}
	var err error
	store, err = driver.Open(fmt.Sprintf("tikv://%s", *pdAddr))
	if err != nil {
		log.Fatal(err)
	}

	prometheus.MustRegister(txnCounter)
	prometheus.MustRegister(txnRolledbackCounter)
	prometheus.MustRegister(txnDurations)
	prometheus.MustRegister(txnElapse)

}

// without conflict
func batchRW(value []byte) {
	wg := sync.WaitGroup{}
	base := *dataCnt / *workerCnt
	wg.Add(*workerCnt)
	for i := 0; i < *workerCnt; i++ {
		go func(i int) {
			defer wg.Done()
			for j := 0; j < base; j++ {
				txnCounter.Inc()
				start := time.Now()
				k := base*i + j
				txn, err := store.Begin()
				if err != nil {
					log.Fatal(err)
				}
				key := fmt.Sprintf("key_%d", k)
				txn.Set([]byte(key), value)
				err = txn.Commit()
				if err != nil {
					txnRolledbackCounter.Inc()
					txn.Rollback()
				}
				txnDurations.Observe(time.Since(start).Seconds())
			}
		}(i)
	}
	wg.Wait()
}

func alert(msg string) error {
	cmdStr := fmt.Sprintf(`curl -X POST --data-urlencode 'payload={"channel": "#dt", "username": "Alert", "text": "%s"}' %s`,
		msg, *alertAddr)
	cmd := exec.Command("/bin/sh", "-c", cmdStr)
	if err := cmd.Run(); err != nil {
		return err
	}

	return nil
}

func pushResultMysql(currentBenchTime float64) {
	dbaddr := fmt.Sprintf("%s:%s@tcp(%s:%d)/%s?charset=utf8", *mysqlUser, *mysqlPassword, *mysqlHost, *mysqlPort, *mysqlDb)
	db, err := sql.Open("mysql", dbaddr)
	if err != nil {
		log.Error(err)
	}
	defer db.Close()

	var lastBenchTime float64
	var lastTidbVer, lastPdVer, lastTikvVer string
	if err := db.QueryRow("SELECT tidb_version, tikv_version, pd_version, bench_avg_time FROM benchkv order by id desc limit 1").Scan(&lastTidbVer, &lastTikvVer, &lastPdVer, &lastBenchTime); err != nil {
		log.Error(err)
	}
	var msg string
	if currentBenchTime >= lastBenchTime*1.1 {
		msg = fmt.Sprintf("*[WARNING] Performance is down *\n [tidb_version:%s tikv_version:%s pd_version:%s]\n [last_tidb_version:%s last_tikv_version:%s last_pd_version:%s] \n benchkv_test spend more than 10 percent ,last:[%f], current:[%f] \n (http://office.pingcap.net:28080/job/BENCH_TEST_ON_UCLOUD/)", tidbVersion, tikvVersion, pdVersion, lastTidbVer, lastTikvVer, lastPdVer, lastBenchTime, currentBenchTime)
	}

	if currentBenchTime <= lastBenchTime*0.9 {
		msg = fmt.Sprintf("*[Info] Performance improved* \n [tidb_version:%s tikv_version:%s pd_version:%s] \n [last_tidb_version:%s last_tikv_version:%s last_pd_version:%s] \n benchkv_test reduce more than 10 percent,last:[%f], current:[%f] (http://office.pingcap.net:28080/job/BENCH_TEST_ON_UCLOUD/)", tidbVersion, tikvVersion, pdVersion, lastTidbVer, lastTikvVer, lastPdVer, lastBenchTime, currentBenchTime)
	}

	if msg != "" {
		err = alert(msg)
		if err != nil {
			log.Errorf("alert failed:%s\n", err)
		}
	}
	_, err = db.Exec("INSERT INTO benchkv(tidb_version,tikv_version,pd_version,bench_avg_time) VALUES(?,?,?,?)", tidbVersion, tikvVersion, pdVersion, currentBenchTime)
	if err != nil {
		log.Fatal(err)
	}

}

func main() {
	flag.Parse()
	log.SetLevelByString("error")
	Init()

	value := make([]byte, *valueSize)

	var totalTime float64
	for i := 0; i < 3; i++ {
		t := time.Now()

		batchRW(value)
		elapseTime := time.Since(t).Seconds()
		txnElapse.Set(elapseTime)
		if err := push.AddCollectors("benchkv", nil, *pushgatewayAddr, txnCounter, txnRolledbackCounter, txnDurations, txnElapse); err != nil {
			log.Fatal(err)
		}

		totalTime += elapseTime
	}

	avgTime := totalTime / 3
	pushResultMysql(avgTime)

	fmt.Printf("\nelapse:%v, total %v ,tidb:%s , tikv:%s , pd:%s \n", avgTime, *dataCnt, tidbVersion, tikvVersion, pdVersion)
}
