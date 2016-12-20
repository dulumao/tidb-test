/*
 * 1) prepare
 * sysbench --test=./sysbench/oltp.lua --mysql-host=${host} --mysql-port=${port} --mysql-user=${user}
 * --mysql-password=${passwd} --oltp-tables-count=10 --oltp-table-size=10000000 --rand-init=on prepare
 *
 * 2) run
 * sysbench --test=./sysbench/oltp.lua --mysql-host=${host} --mysql-port=${port} --mysql-user=${user}
 * --mysql-password=${passwd} --oltp-tables-count=10 --oltp-table-size=10000000 --num-threads=${threads}
 * --oltp-read-only=off --report-interval=60 --rand-type=uniform --max-time=600 --percentile=99
 * --max-requests=1000000000 run
 *
 *
 * OLTP test statistics:
 *   queries performed:
 *       read:                            2101540
 *       write:                           600440
 *       other:                           300220
 *       total:                           3002200
 *   transactions:                        150110 (2501.72 per sec.)
 *   read/write requests:                 2701980 (45030.91 per sec.)
 *   other operations:                    300220 (5003.43 per sec.)
 *   ignored errors:                      0      (0.00 per sec.)
 *   reconnects:                          0      (0.00 per sec.)
 *
 * General statistics:
 *   total time:                          60.0028s
 *   total number of events:              150110
 *   total time taken by event execution: 479.8373s
 *   response time:
 *        min:                                  1.06ms
 *        avg:                                  3.20ms
 *        max:                                306.37ms
 *        approx.  99 percentile:              13.83ms
 *
 * Threads fairness:
 *   events (avg/stddev):           18763.7500/272.53
 *   execution time (avg/stddev):   59.9797/0.00
 */

package sysbench

import (
	"bytes"
	"fmt"
	"log"
	"os/exec"
	"regexp"
	"strconv"
	"strings"
)

func Prepare(host string, port int, user, passwd string, tCount, tSize int64) error {
	var err error
	createDBArgs := fmt.Sprintf(`/usr/bin/mysql -h%s -P%d -u%s -e"create database IF NOT EXISTS sbtest"`,
		host, port, user)
	fmt.Println("prepare command: ", createDBArgs)
	cmdCreate := exec.Command("/bin/sh", "-c", createDBArgs)
	if err = cmdCreate.Run(); err != nil {
		fmt.Println("create database failed", err)
		return err
	}

	cmdStr := fmt.Sprintf(`sysbench --test=./sysbench/oltp.lua --mysql-host=%s --mysql-port=%d --mysql-user=%s --mysql-password=%s --oltp-tables-count=%d --oltp-table-size=%d --rand-init=on prepare`,
		host, port, user, passwd, tCount, tSize)
	fmt.Println("prepare command: ", cmdStr)
	cmd := exec.Command("/bin/sh", "-c", cmdStr)
	if err := cmd.Run(); err != nil {
		fmt.Println("run sysbench prepare failed", err)
		return err
	}

	return nil
}

func Run(host string, port int, user, passwd string, tCount, tSize, threads, maxTime int64) (error, string) {
	cmdStr := fmt.Sprintf(`sysbench --test=./sysbench/oltp.lua --mysql-host=%s --mysql-port=%d --mysql-user=%s --mysql-password=%s --oltp-tables-count=%d --oltp-table-size=%d --num-threads=%d --oltp-read-only=off --report-interval=60 --rand-type=uniform --max-time=%d --percentile=99 --max-requests=1000000000 run`,
		host, port, user, passwd, tCount, tSize, threads, maxTime)
	cmd := exec.Command("/bin/sh", "-c", cmdStr)
	fmt.Println("run command: ", cmdStr)
	var out bytes.Buffer
	cmd.Stdout = &out
	if err := cmd.Run(); err != nil {
		fmt.Println("run sysbench run failed", err)
		return err, ""
	}

	return nil, out.String()
}

func ExtractOltpTps(oltpResult string) float64 {
	regOltp := regexp.MustCompile("transactions:[ ]+[0-9]+[ ]+[(][0-9.]+ per sec.[)]")
	tpsInfo := regOltp.Find([]byte(oltpResult))
	if tpsInfo == nil {
		log.Fatal("can't extract OLTP tps")
	}

	pieces := strings.Split(string(tpsInfo), "(")
	if len(pieces) != 2 {
		log.Fatal("split tps Info error")
	}

	tps, err := strconv.ParseFloat(strings.Split(pieces[1], " ")[0], 64)
	if err != nil {
		log.Fatal("parse tps failed")
	}

	return tps
}

func ExtarctOltpAvgLatency(oltpResult string) float64 {
	regAvg := regexp.MustCompile("avg:[ ]+[0-9.]+ms")
	avgInfo := regAvg.Find([]byte(oltpResult))
	if avgInfo == nil {
		log.Fatal("can't extract avg latency")
	}

	pieces := strings.Split(string(avgInfo), ":")
	if len(pieces) != 2 {
		log.Fatal("split avg latency failed")
	}

	var avgLatency float64
	if _, err := fmt.Sscanf(pieces[1], "%fms", &avgLatency); err != nil {
		log.Fatal("parse avg latency failed")
	}

	return avgLatency
}

func ExtractOltpApprox99(oltpResult string) float64 {
	regApprox := regexp.MustCompile("approx.[ ]+99 percentile:[ ]+[0-9.]+ms")
	approxIndo := regApprox.Find([]byte(oltpResult))
	if approxIndo == nil {
		log.Fatal("can't extract approx")
	}

	pieces := strings.Split(string(approxIndo), ":")
	if len(pieces) != 2 {
		log.Fatal("split approx failed")
	}

	var approx float64
	if _, err := fmt.Sscanf(pieces[1], "%fms", &approx); err != nil {
		log.Fatal("parse approx failed")
	}

	return approx
}

func Clean(host string, port int, user, passwd string) error {
	cmdStrArgs := fmt.Sprintf(`/usr/bin/mysql -h%s -P%d -u%s -e"drop database if exists sbtest"`, host, port, user)
	fmt.Println("clean command: ", cmdStrArgs)
	cmd := exec.Command("/bin/sh", "-c", cmdStrArgs)
	if err := cmd.Run(); err != nil {
		fmt.Println("run drop database failed", err)
		return err
	}
	return nil
}
