// Copyright 2015 PingCAP, Inc.
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
	"math/rand"
	"strconv"
	"strings"
	"time"

	_ "github.com/go-sql-driver/mysql"
	"github.com/juju/errors"
	"github.com/ngaut/log"
	"github.com/peterh/liner"
	"github.com/pingcap/tidb/util/printer"
)

var (
	dataSourceName = flag.String("dsn", "root@tcp(localhost:4000)/test?strict=true", "dataSource name")
	line           *liner.State
	db             *sql.DB
)

const (
	createTableQl = `
		BEGIN;
                CREATE TABLE weather (
                  ID                INTEGER,
                  Station           CHAR(32),
                  InsertTime        TIMESTAMP,
                  ObservTime        TIMESTAMP,
                  BatteryStatus     CHAR(16),
                  WindVelocity      INTEGER,
                  WindDirect        INTEGER,
                  WindVelocity2     INTEGER,
                  WindDirect2       INTEGER,
                  WindVelocity10    INTEGER,
                  WindDirect10      INTEGER,
                  MaxWind           INTEGER,
                  Rain              INTEGER
                );
		CREATE TABLE fileSend (
		  LogTime           TIMESTAMP,
		  FileName          VARCHAR(255),
		  FileSize          INTEGER,
		  IniName           VARCHAR(255),
		  IniSize           INTEGER,
		  LocalDir          VARCHAR(255),
		  DestHost          VARCHAR(255),
		  SendRoute         VARCHAR(255),
		  DType             VARCHAR(32),
		  CType             VARCHAR(32),
		  TakeTime          INTEGER,
		  BackDir           VARCHAR(255),
		  ComputerName      VARCHAR(64)
		);
		COMMIT;
`
	dropTableQl = `BEGIN; DROP TABLE IF EXISTS weather; DROP TABLE IF EXISTS fileSend; COMMIT;`

	usage = `
Commands:
  <query>                  Excute a SQL query.
  !setup                   Create tables.
  !insert-weather <size>   Insert random weather data into database.
  !insert-file    <size>   Insert random fileSend data into database.
  !cleanup                 Cleanup tables and data.

Options:
  -dns:            Datasource name.
`

	insertBatchSize = 2000
)

func main() {
	flag.Parse()

	line = liner.NewLiner()
	line.SetCtrlCAborts(true)
	defer line.Close()

	var err error
	db, err = sql.Open("mysql", *dataSourceName)
	if err != nil {
		log.Fatal(errors.ErrorStack(err))
	}
	defer db.Close()

	fmt.Println(usage)

	for {
		input, err := line.Prompt("weather-test> ")
		if err != nil {
			log.Fatal(errors.ErrorStack(err))
		}
		line.AppendHistory(input)

		var cmd, args string
		if input == "" {
			continue
		}
		if input[0] == '!' {
			sp := strings.SplitN(input, " ", 2)
			if len(sp) >= 1 {
				cmd = sp[0]
			}
			if len(sp) >= 2 {
				args = sp[1]
			}
		} else {
			args = input
		}

		switch cmd {
		case "!setup":
			cmdSetup(args)
		case "!insert-weather":
			cmdInsertWeather(args)
		case "!insert-file":
			cmdInsertFileSend(args)
		case "!cleanup":
			cmdCleanup(args)
		default:
			cmdQuery(args)
		}
	}
}

func cmdSetup(args string) {
	_, err := db.Exec(dropTableQl)
	if err != nil {
		fmt.Println(errors.ErrorStack(err))
		return
	}

	_, err = db.Exec(createTableQl)
	if err != nil {
		fmt.Println(errors.ErrorStack(err))
		return
	}

	fmt.Println("OK!")
}

func cmdInsertWeather(args string) {
	n, err := strconv.Atoi(args)
	if err != nil {
		fmt.Println(usage)
		return
	}

	start := time.Now()
	t, _ := time.Parse("20060102 15:04:05", "20150101 00:00:00")

	var tx *sql.Tx
	for i := 1; i <= n; i++ {
		if tx == nil {
			var err error
			tx, err = db.Begin()
			if err != nil {
				fmt.Println(errors.ErrorStack(err))
				return
			}
		}

		stmt, err := tx.Prepare("INSERT INTO weather VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)")
		if err != nil {
			fmt.Println(errors.ErrorStack(err))
			return
		}

		_, err = stmt.Exec(i,
			fmt.Sprintf("STATION%d", i%insertBatchSize),
			t.Add(time.Millisecond*time.Duration(rand.Int()%5000)),
			t.Add(time.Millisecond*time.Duration(rand.Int()%30000)),
			"Normal",
			rand.Int()%300,
			rand.Int()%360,
			rand.Int()%300,
			rand.Int()%360,
			rand.Int()%300,
			rand.Int()%360,
			rand.Int()%300,
			rand.Int()%10)
		if err != nil {
			fmt.Println(errors.ErrorStack(err))
			return
		}

		if i%insertBatchSize == 0 || i == n {
			err = tx.Commit()
			if err != nil {
				fmt.Println(errors.ErrorStack(err))
				return
			}

			tx = nil
			elapsed := time.Since(start).Seconds()
			fmt.Printf("%v rows inserted, %.2f seconds elapsed.\n", i, elapsed)
		}
	}
}

func cmdInsertFileSend(args string) {
	n, err := strconv.Atoi(args)
	if err != nil {
		fmt.Println(usage)
		return
	}

	start := time.Now()
	minTime, _ := time.Parse("20060102 15:04:05", "20150101 00:00:00")
	maxTime, _ := time.Parse("20060102 15:04:05", "20150107 23:59:59")

	var tx *sql.Tx
	for i := 1; i < n; i++ {
		if tx == nil {
			var err error
			tx, err = db.Begin()
			if err != nil {
				fmt.Println(errors.ErrorStack(err))
				return
			}
		}

		stmt, err := tx.Prepare("INSERT INTO fileSend VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)")
		if err != nil {
			fmt.Println(errors.ErrorStack(err))
			return
		}

		_, err = stmt.Exec(
			minTime.Add(time.Duration(rand.Int()%int(maxTime.Sub(minTime)))),
			fmt.Sprintf("FileName%v", i),
			rand.Int()%65535,
			fmt.Sprintf("IniName%v", i),
			rand.Int()%65536,
			"/home",
			fmt.Sprintf("Host%v", rand.Int()%10),
			"Default",
			"Default",
			"Default",
			rand.Int()%10,
			"/tmp",
			fmt.Sprintf("Serv%v", rand.Int()%2))
		if err != nil {
			fmt.Println(errors.ErrorStack(err))
			return
		}

		if i%insertBatchSize == 0 || i == n {
			err = tx.Commit()
			if err != nil {
				fmt.Println(errors.ErrorStack(err))
				return
			}

			tx = nil
			elapsed := time.Since(start).Seconds()
			fmt.Printf("%v rows inserted, %.2f seconds elapsed.\n", i, elapsed)
		}
	}
}

func cmdQuery(args string) {
	start := time.Now()

	rows, err := db.Query(args)
	if err != nil {
		fmt.Println(errors.ErrorStack(err))
		return
	}
	defer rows.Close()

	printRows(rows)

	elapsed := time.Since(start).Seconds()
	fmt.Printf("%.2f seconds elapsed.\n", elapsed)
}

func cmdCleanup(args string) {
	_, err := db.Exec(dropTableQl)
	if err != nil {
		fmt.Println(errors.ErrorStack(err))
		return
	}

	fmt.Println("OK!")
}

func printRows(rows *sql.Rows) error {
	cols, err := rows.Columns()
	if err != nil {
		return errors.Trace(err)
	}

	values := make([][]byte, len(cols))
	scanArgs := make([]interface{}, len(values))
	for i := range values {
		scanArgs[i] = &values[i]
	}

	var datas [][]string
	for rows.Next() {
		err := rows.Scan(scanArgs...)
		if err != nil {
			return errors.Trace(err)
		}

		data := make([]string, len(cols))
		for i, value := range values {
			if value == nil {
				data[i] = "NULL"
			} else {
				data[i] = string(value)
			}
		}

		datas = append(datas, data)
	}

	// For `cols` and `datas[i]` always has the same length,
	// no need to check return validity.
	result, _ := printer.GetPrintResult(cols, datas)
	fmt.Printf("%s", result)
	return nil
}
