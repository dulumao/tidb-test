package main

import (
	"database/sql"
	"flag"
	"fmt"
	"log"
	"os"

	_ "github.com/go-sql-driver/mysql"

	"github.com/pingcap/tidb-test/bench_test/bench-oltp/sysbench"
	"os/exec"
)

var (
	host           = flag.String("h", "127.0.0.1", "host address")
	port           = flag.Int("P", 50004, "host port")
	user           = flag.String("u", "root", "set user of the database")
	password       = flag.String("p", "", "set password of the database ")
	oltpTableCount = flag.Int64("tc", 10, "table count")
	oltpTableSize  = flag.Int64("ts", 1000000, "table size")
	oltpThreads    = flag.Int64("tt", 32, "sysbench threads")
	maxTime        = flag.Int64("t", 600, "oltp max-time(secs)")
	alertAddr      = flag.String("aa", "https://hooks.slack.com/services/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", "alert address")

	cmd           = flag.String("command", "run", "[prepare] [run] [clean]")
	mysqlHost     = flag.String("mh", "127.0.0.1", "mysql Host, used to store result")
	mysqlPort     = flag.Int("mP", 3306, "mysql port, used to store result")
	mysqlUser     = flag.String("mu", "root", "mysql user, used to store result")
	mysqlPassword = flag.String("mp", "root", "mysql password, used to store result")
	mysqlDb       = flag.String("md", "benchresult", "mysql database, used to store result")

	tidbVersion = os.Getenv("TIDB_VERSION")
	tikvVersion = os.Getenv("TIKV_VERSION")
	pdVersion   = os.Getenv("PD_VERSION")
)

func alert(msg string) error {
	cmdStr := fmt.Sprintf(`curl -X POST --data-urlencode 'payload={"channel": "#dt", "username": "Alert", "text": "%s"}' %s`,
		msg, *alertAddr)
	cmd := exec.Command("/bin/sh", "-c", cmdStr)
	if err := cmd.Run(); err != nil {
		return err
	}

	return nil
}

func alertOnException(currentTps, currentAvgLatency, currentApprox float64) error {
	dbaddr := fmt.Sprintf("%s:%s@tcp(%s:%d)/%s?charset=utf8", *mysqlUser, *mysqlPassword, *mysqlHost, *mysqlPort, *mysqlDb)
	db, err := sql.Open("mysql", dbaddr)
	if err != nil {
		return err
	}
	defer db.Close()

	var lastTps, lastAvgLatency, lastApprox float64
	if err := db.QueryRow("SELECT tps, avg_latency, approx99 FROM oltp order by id desc limit 1").Scan(&lastTps, &lastAvgLatency, &lastApprox); err != nil {
		return err
	}

	if currentTps*1.1 < lastTps {
		msg := fmt.Sprintf("[WARNING][tidb version: %s, tikv version: %s, pd version: %s] Tps reduced by more than 10 percent, last tps[%f], current tps[%f]",
			tidbVersion, tikvVersion, pdVersion, lastTps, currentTps)
		if err := alert(msg); err != nil {
			fmt.Println("alert tps failed", err)
		}
	}

	if currentAvgLatency > lastAvgLatency*1.1 {
		msg := fmt.Sprintf("[WARNING][tidb version: %s, tikv version: %s, pd version: %s] avg latency increased by more than 10 percent, last avg lentency[%f], current avg latency[%f]",
			tidbVersion, tikvVersion, pdVersion, lastAvgLatency, currentAvgLatency)
		if err := alert(msg); err != nil {
			fmt.Println("alert latency failed", err)
		}
	}

	if currentTps > lastTps*1.1 {
		msg := fmt.Sprintf("[CHEERS][tidb version: %s, tikv version: %s, pd version: %s] Tps increase more than 10 percent, last tps[%f], current tps[%f]",
			tidbVersion, tikvVersion, pdVersion, lastTps, currentTps)
		if err := alert(msg); err != nil {
			fmt.Println("cheers tps failed", err)
		}
	}

	if currentAvgLatency < lastAvgLatency*0.9 {
		msg := fmt.Sprintf("[CHEERS][tidb version: %s, tikv version: %s, pd version: %s] avg latency reduced by more than 10 percent, last avg latency [%f], current avg latency[%f]",
			tidbVersion, tikvVersion, pdVersion, lastAvgLatency, currentAvgLatency)
		if err := alert(msg); err != nil {
			fmt.Println("cheers latency failed", err)
		}
	}

	return nil
}

func pushResult(threads int64, tps float64, avgLatency float64, approx float64) error {
	var err error

	dbaddr := fmt.Sprintf("%s:%s@tcp(%s:%d)/%s?charset=utf8", *mysqlUser, *mysqlPassword, *mysqlHost, *mysqlPort, *mysqlDb)
	db, err := sql.Open("mysql", dbaddr)
	if err != nil {
		return err
	}
	defer db.Close()

	stmt, err := db.Prepare("INSERT INTO oltp(tidb, tikv, pd, threads, tps, avg_latency, approx99, time) values (?, ?, ?, ?, ?, ?, ?, now())")
	if err != nil {
		return err
	}
	_, err = stmt.Exec(tidbVersion, tikvVersion, pdVersion, threads, tps, avgLatency, approx)
	if err != nil {
		return err
	}
	return nil
}

func main() {
	flag.Parse()

	if *cmd == "prepare" {
		if err := sysbench.Prepare(*host, *port, *user, *password, *oltpTableCount, *oltpTableSize); err != nil {
			log.Fatal("sysbench perpare failed", err)
		}
		fmt.Println("sysbench prepare finished")

	} else if *cmd == "run" {
		err, oltpOutput := sysbench.Run(*host, *port, *user, *password, *oltpTableCount, *oltpTableSize, *oltpThreads, *maxTime)
		if err != nil {
			log.Fatal("sysbench run failed", err)
		}
		tps := sysbench.ExtractOltpTps(oltpOutput)
		avgLatency := sysbench.ExtarctOltpAvgLatency(oltpOutput)
		approx99 := sysbench.ExtractOltpApprox99(oltpOutput)

		// alert on abnormal
		alertOnException(tps, avgLatency, approx99)

		// push result to mysql
		if err := pushResult(*oltpThreads, tps, avgLatency, approx99); err != nil {
			log.Fatal("push result to mysql failed", err)
		}

		fmt.Println("sysbench run finished")

	} else if *cmd == "clean" {
		if err := sysbench.Clean(*host, *port, *user, *password); err != nil {
			log.Fatal("sysbench clean failed", err)
		}

		fmt.Println("clean sysbench tables finished")
	}
}
