
/*
 * create table order (
 * 	id int(20) not null auto_increment,
 *	user_id int(20)
 *	time datetime,
 *	type int(10),
 *	info varchar(255),
 *	primary key (`id`),
 *	key `time_idx` (`time`),
 * );
 *
 * select count(*) from order;
 * select count(id) from order where time > x and time < y;
 * select count(user_id) from order where time > x and time < y;
 *
 */

package main

import (
	"database/sql"
	"fmt"
	"flag"
	"os"
	"log"

	_ "github.com/go-sql-driver/mysql"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/push"
	"time"
)

var (
	host            = flag.String("h", "127.0.0.1", "host address")
	port            = flag.Int("P", 50004, "host port")
	user            = flag.String("u", "root", "set user of the database")
	password        = flag.String("p", "", "set password of the database ")
	dbname          = flag.String("D", "test", "set the default database name")
	rownum          = flag.Int("R", 10000000, "the row num of table")
	tablename       = flag.String("T", "nl_mob_app_error_trace", "the default table name")
	timestart	= flag.String("B", "2016-10-01 00:00:00", "the begin time")
	timeend		= flag.String("E", "2016-10-08 00:00:00", "the end time")
	pushgatewayAddr = flag.String("S", "127.0.0.1:9091", "Pushgateway Address")

	tidbVersion = os.Getenv("TIDB_VERSION")
	tikvVersion = os.Getenv("TIKV_VERSION")
	pdVersion   = os.Getenv("PD_VERSION")
	constLables = prometheus.Labels{"tikv": tikvVersion, "tidb": tidbVersion, "pd": pdVersion}

	scanallElapse = prometheus.NewGauge(
		prometheus.GaugeOpts{
			Namespace:   "bench-scan",
			Name:        "scan-all",
			Help:        "select count(*) from t elapse time seconds.",
			ConstLabels: constLables,
		})

	scansecondaryElapse = prometheus.NewGauge(
		prometheus.GaugeOpts{
			Namespace:   "bench-scan",
			Name:        "scan-secondary",
			Help:        "select count(id) from t where time > x and time < y elapse time seconds.",
			ConstLabels: constLables,
		})

	scanmixedElapse = prometheus.NewGauge(
		prometheus.GaugeOpts{
			Namespace:   "bench-scan",
			Name:        "scan-mixed",
			Help:        "select count(use_id) from t where time > x and time < y elapse time seconds.",
			ConstLabels: constLables,
		})
)

func createDB() (*sql.DB, error) {
	dbaddr := fmt.Sprintf("%s:%s@tcp(%s:%d)/%s?charset=utf8", *user, *password, *host, *port, *dbname)
	db, err := sql.Open("mysql", dbaddr)
	if err != nil {
		return nil, err
	}
	return db, nil
}

func ScanAll(db *sql.DB) {
	var count int
	sql := fmt.Sprintf("SELECT COUNT(*) FROM %s", *tablename)
	if err := db.QueryRow(sql).Scan(&count); err != nil {
		log.Printf("Scan all failed, err %v", err)
		return
	}
	if count != *rownum {
		log.Fatal("row count not match")
	}
}

func ScanSecondaryIndex(db *sql.DB) {
	var count int
	sql := fmt.Sprintf("SELECT COUNT(id) FROM %s WHERE time > '%s' and time < '%s'",
		*tablename, *timestart, *timeend)
	if err := db.QueryRow(sql).Scan(&count); err != nil {
		log.Fatal(err)
	}
}

// scan secondary index + primary index
func ScanMixed(db *sql.DB) {
	var count int
	sql := fmt.Sprintf("SELECT COUNT(user_id) FROM %s WHERE time > '%s' and time < '%s'",
		*tablename, *timestart, *timeend)
	if err := db.QueryRow(sql).Scan(&count); err != nil {
		log.Fatal(err)
	}
}

func main() {
	// connect to db
	db, err := createDB()
	if err != nil {
		log.Fatal(err)
	}

	// scan all
	{
		prometheus.MustRegister(scanallElapse)
		start := time.Now()
		ScanAll(db)
		elapsed := time.Since(start).Seconds()
		scanallElapse.Set(elapsed)
		log.Printf("Use time %g seconds", elapsed)
		if err := push.AddCollectors("bench-scan", nil, *pushgatewayAddr, scanallElapse); err != nil {
			log.Fatal(err)
		}
	}

	// scan secondary index
	{
		prometheus.MustRegister(scansecondaryElapse)
		start := time.Now()
		ScanSecondaryIndex(db)
		elapsed := time.Since(start).Seconds()
		scansecondaryElapse.Set(elapsed)
		log.Printf("Use time %g seconds", elapsed)
		if err := push.AddCollectors("bench-scan", nil, *pushgatewayAddr, scansecondaryElapse); err != nil {
			log.Fatal(err)
		}
	}

	// scan mixed
	{
		prometheus.MustRegister(scanmixedElapse)
		start := time.Now()
		ScanMixed(db)
		elapsed := time.Since(start).Seconds()
		scanmixedElapse.Set(elapsed)
		log.Printf("Use time %g seconds", elapsed)
		if err := push.AddCollectors("bench-scan", nil, *pushgatewayAddr, scanmixedElapse); err != nil {
			log.Fatal(err)
		}
	}
}
