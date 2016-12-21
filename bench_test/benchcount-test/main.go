package main

import (
	"database/sql"
	"flag"
	"fmt"
	"math"
	"os"
	"os/exec"
	"time"

	_ "github.com/go-sql-driver/mysql"
	"github.com/ngaut/log"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/push"
)

var (
	mysqlHost     = flag.String("mh", "127.0.0.1", "mysql Host, used to store result")
	mysqlPort     = flag.Int("mP", 3306, "mysql port, used to store result")
	mysqlUser     = flag.String("mu", "root", "mysql user, used to store result")
	mysqlPassword = flag.String("mp", "root", "mysql password, used to store result")
	mysqlDB       = flag.String("md", "benchresult", "mysql database, used to store result")
	alertAddr     = flag.String("aa", "https://hooks.slack.com/services/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", "alert address")

	host            = flag.String("h", "127.0.0.1", "host address")
	port            = flag.Int("P", 50004, "host port")
	user            = flag.String("u", "root", "set user of the database")
	password        = flag.String("p", "", "set password of the database ")
	dbname          = flag.String("D", "test", "set the default database name")
	rownum          = flag.Int("R", 10000000, "the row num of table")
	tablename       = flag.String("T", "benchcount", "the default table name")
	pushgatewayAddr = flag.String("S", "", "Pushgateway Address")

	tidbVersion = os.Getenv("TIDB_VERSION")
	tikvVersion = os.Getenv("TIKV_VERSION")
	pdVersion   = os.Getenv("PD_VERSION")

	countElapse = prometheus.NewGauge(
		prometheus.GaugeOpts{
			Namespace: "benchcount",
			Name:      "elapse_time",
			Help:      "select(*) from elapse time seconds.",
		})
)

func createDB(user string, password string, host string, port int, dbname string) (*sql.DB, error) {
	dbaddr := fmt.Sprintf("%s:%s@tcp(%s:%d)/%s?charset=utf8", user, password, host, port, dbname)
	db, err := sql.Open("mysql", dbaddr)
	if err != nil {
		return nil, err
	}
	return db, nil
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

func pushResultMysql(currentCountTime float64) {
	db, err := createDB(*mysqlUser, *mysqlPassword, *mysqlHost, *mysqlPort, *mysqlDB)
	if err != nil {
		log.Error(err)
	}
	defer db.Close()

	var lastCountTime float64
	var lastTidbVer, lastTikvVer, lastPdVer string
	if err := db.QueryRow("SELECT tidb_version, tikv_version, pd_version, bench_avg_time FROM benchcount order by id desc limit 1").Scan(&lastTidbVer, &lastTikvVer, &lastPdVer, &lastCountTime); err != nil {
		log.Error(err)
	}
	var msg string
	if currentCountTime >= lastCountTime*1.1 {
		msg = fmt.Sprintf("*[WARNING] Performance is down*\n [tidb_version:%s tikv_version:%s pd_version:%s] \n[last_tidb_version:%s last_tikv_version:%s last_pd_version:%s] \n benchcount_test spend more than 10 percent, last:[%f], current:[%f] \n (http://office.pingcap.net:28080/job/BENCH_TEST_ON_UCLOUD/)", tidbVersion[0:8], tikvVersion[0:8], pdVersion[0:8], lastTidbVer[0:8], lastTikvVer[0:8], lastPdVer[0:8], lastCountTime, currentCountTime)
	}

	if currentCountTime <= lastCountTime*0.9 {
		msg = fmt.Sprintf("*[Info] Performance improved*\n  [tidb_version:%s tikv_version:%s pd_version:%s]\n [last_tidb_version:%s last_tikv_version:%s last_pd_version:%s] \n  benchcount_test reduce more than 10 percent, last:[%f], current:[%f] \n (http://office.pingcap.net:28080/job/BENCH_TEST_ON_UCLOUD/)", tidbVersion[0:8], tikvVersion[0:8], pdVersion[0:8], lastTidbVer[0:8], lastTikvVer[0:8], lastPdVer[0:8], lastCountTime, currentCountTime)
	}

	if msg != "" {
		err = alert(msg)
		if err != nil {
			log.Errorf("alert failed:%s\n", err)
		}
	}

	_, err = db.Exec("INSERT INTO benchcount(tidb_version,tikv_version,pd_version,bench_avg_time) VALUES(?,?,?,?)", tidbVersion, tikvVersion, pdVersion, currentCountTime)
	if err != nil {
		log.Fatal(err)
	}

}

func scanTable(db *sql.DB) {
	var count int
	sql := fmt.Sprintf("SELECT count(*) FROM %s", *tablename)
	if err := db.QueryRow(sql).Scan(&count); err != nil {
		log.Fatal(err)
	}
	if count != *rownum {
		log.Fatal("row num not correct")
	}
}

func main() {
	db, err := createDB(*user, *password, *host, *port, *dbname)
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	prometheus.MustRegister(countElapse)
	var totalTime, min, max float64
	min = math.MaxFloat64
	max = math.SmallestNonzeroFloat64
	for i := 0; i < 10; i++ {
		start := time.Now()
		scanTable(db)
		end := time.Since(start).Seconds()
		if min > end {
			min = end
		}
		if end > max {
			max = end
		}
		totalTime += end
		countElapse.Set(end)
		if *pushgatewayAddr == "" {
			continue
		}
		if err := push.AddCollectors("benchcount", nil, *pushgatewayAddr, countElapse); err != nil {
			log.Error(err)
		}
	}
	avgTime := (totalTime - max - min) / 8
	pushResultMysql(avgTime)

	log.Infof("[benchcount]: Use time %g seconds\n", avgTime)
}
