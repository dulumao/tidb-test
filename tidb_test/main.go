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
	"bytes"
	"database/sql"
	"flag"
	"fmt"
	"io/ioutil"
	"math"
	"os"
	"regexp"
	"runtime/debug"
	"strconv"
	"strings"
	"sync"
	"time"

	_ "github.com/go-sql-driver/mysql"
	"github.com/juju/errors"
	"github.com/ngaut/log"
	"github.com/pingcap/tidb"
	"github.com/pingcap/tidb/ast"
	"github.com/pingcap/tidb/context"
	"github.com/pingcap/tidb/util/mock"
)

var (
	logLevel = flag.String("L", "debug", "log level")
	parallel = flag.Int("parallel", 4, "parallel")

	testdata    []string
	rawTestData []string
	ctx         context.Context
)

// http://en.wikipedia.org/wiki/Join_(SQL)#Sample_tables
const sample = `
     BEGIN;
		CREATE TABLE department (
			DepartmentID   int,
			DepartmentName text
		);
		INSERT INTO department VALUES
			(31, "Sales"),
			(33, "Engineering"),
			(34, "Clerical"),
			(35, "Marketing")
		;
		CREATE TABLE employee (
			LastName     text,
			DepartmentID int
		);
		INSERT INTO employee VALUES
			("Rafferty", 31),
			("Jones", 33),
			("Heisenberg", 33),
			("Robinson", 34),
			("Smith", 34),
			("Williams", NULL)
		;
     COMMIT;
`

func init() {
	tests, err := ioutil.ReadFile("ql.t")
	if err != nil {
		log.Fatal("ReadFile Error: ", err)
	}

	a := bytes.Split(tests, []byte("\n-- "))
	pre := []byte("-- ")
	pres := []byte("S ")
	for _, v := range a {
		if strings.TrimLeft(string(v), " \t")[0] == '*' {
			continue
		}
		rawTestData = append(rawTestData, string(append(pre, v...)))
		switch {
		case bytes.HasPrefix(v, pres):
			v = append(pre, v...)
			v = append([]byte(sample), v...)
		default:
			v = append(pre, v...)
		}
		testdata = append(testdata, string(v))
	}
	ctx = mock.NewContext()

	tidb.SetSchemaLease(0)
}

func mustErr(test string, err error, expErr string) {
	// TODO: should check error message expErr == err.String()
	if err == nil || expErr == "" {
		log.Fatal("FAIL: ", test, "must get an error!")
	}
}

func mustOk(test string, err error, expErr string, re *regexp.Regexp) {
	s := err.Error()
	if re == nil {
		log.Fatal(test, errors.ErrorStack(err))
	}

	if !re.MatchString(s) {
		log.Error(errors.ErrorStack(err))
		log.Fatal("FAIL: ", test, "error doesn't match:", s, "expected", expErr)
	}
}

func chkResult(got string, rst string) bool {
	got = strings.TrimSpace(got)
	rst = strings.TrimSpace(rst)
	a := strings.Split(rst, "\n")
	for i, v := range a {
		a[i] = strings.TrimSpace(v)
	}
	e := strings.Join(a, "\n")

	b := strings.Split(got, "\n")
	for i, v := range b {
		b[i] = strings.TrimSpace(v)
	}
	g := strings.Join(b, "\n")

	if g != e {
		return false
	}
	return true
}

func formatOutput(xi interface{}) string {
	switch v := xi.(type) {
	case bool, float32, float64, int64, uint64, []byte, time.Time:
		return fmt.Sprintf("%v", v)
	case string:
		return v
	default:
		panic("unsupported output format")
	}
}

func executeLine(tx *sql.Tx, txnLine string) (string, error) {
	buffer := bytes.NewBufferString("")
	if tidb.IsQuery(txnLine) {
		rows, err := tx.Query(txnLine)
		if err != nil {
			return "", err
		}
		cols, err := rows.Columns()
		if err != nil {
			return "", err
		}

		for i, c := range cols {
			buffer.WriteString(fmt.Sprintf("\"%s\"", c))
			if i != len(cols)-1 {
				buffer.WriteString(", ")
			}
		}
		buffer.WriteString("\n")

		values := make([]interface{}, len(cols))
		scanArgs := make([]interface{}, len(values))
		for i := range values {
			scanArgs[i] = &values[i]
		}

		for rows.Next() {
			err := rows.Scan(scanArgs...)
			if err != nil {
				return "", err
			}

			var value string
			buffer.WriteString("[")
			for i, col := range values {
				// Here we can check if the value is nil (NULL value)
				if col == nil {
					value = "<nil>"
				} else {
					value = formatOutput(col)
				}
				buffer.WriteString(value)
				if i < len(values)-1 {
					buffer.WriteString(" ")
				}
			}
			buffer.WriteString("]\n")
		}
		err = rows.Err()
		if err != nil {
			return "", err
		}
	} else {
		// TODO: rows affected and last insert id
		_, err := tx.Exec(txnLine)
		if err != nil {
			return "", err
		}
	}
	return buffer.String(), nil
}

func runParallel() {
	defer os.RemoveAll("var")

	total := len(testdata)
	step := (total + *parallel - 1) / (*parallel)
	wg := &sync.WaitGroup{}
	for i := 0; i < *parallel; i++ {
		wg.Add(1)
		go runTest(i, i*step, int(math.Min(float64(step), float64(total-i*step))), wg)
	}
	wg.Wait()
	println("\nGreat, All tests passed")
}

func runTest(id, startIdx, count int, wg *sync.WaitGroup) (panicked error) {
	defer func() {
		wg.Done()
		if e := recover(); e != nil {
			switch x := e.(type) {
			case error:
				panicked = x
			default:
				panicked = errors.Errorf("%v", e)
			}
		}
		if panicked != nil {
			log.Errorf("PANIC: %v\n%s", panicked, debug.Stack())
		}
	}()

	dbName := "test"
	mdb, err := sql.Open("mysql", "root@tcp(localhost:"+strconv.Itoa(id+4001)+")/"+dbName+"?strict=true")
	if err != nil {
		log.Fatal(err)
	}
	defer mdb.Close()

	// select specific test to run
	for _, test := range testdata[startIdx : startIdx+count] {
		a := strings.Split(test+"|", "|")

		// query, expected result set
		q, rset := a[0], strings.TrimSpace(a[1])
		q = fmt.Sprintf("drop database %s; create database %s;  use %s; ", dbName, dbName, dbName) + q
		var expErr string
		if len(a) < 3 {
			log.Fatal(test)
		}
		// expected error
		var re *regexp.Regexp
		if expErr = a[2]; expErr != "" {
			re = regexp.MustCompile("(?i:" + strings.TrimSpace(expErr) + ")")
		}

		q = strings.Replace(q, "&or;", "|", -1)
		q = strings.Replace(q, "&oror;", "||", -1)

		list, err := tidb.Parse(ctx, q)
		if err != nil {
			mustErr(test, err, expErr)
			continue
		}
		log.Info(q)
		print(".")
		var tx *sql.Tx
		for i, st := range list {
			switch st.(type) {
			case *ast.BeginStmt:
				tx, err = mdb.Begin()
				if err != nil {
					tx.Rollback()
					continue
				}
			case *ast.CommitStmt:
				err := tx.Commit()
				if err != nil {
					tx.Rollback()
					continue
				}
			case *ast.DropDatabaseStmt, *ast.CreateDatabaseStmt, *ast.UseStmt:
				tx, err = mdb.Begin()
				if err != nil {
					log.Fatal("error ", err)
				}
				_, err = executeLine(tx, st.Text())
				if err != nil {
					tx.Rollback()
					continue
				}
				tx.Commit()
			case *ast.RollbackStmt:
				tx.Rollback()
			default:
				if tx != nil {
					log.Info(st)
					output, err := executeLine(tx, st.Text())
					if err != nil {
						tx.Rollback()
						continue
					}
					if (i + 1) != len(list) {
						continue
					}
					if ok := chkResult(output, rset); !ok {
						log.Fatal("error ", q, "\nExcept:\n", rset, "\nGot:\n", output)
					}
				} else {
					tx, err = mdb.Begin()
					if err != nil {
						log.Fatal("error ", err)
					}
					output, err := executeLine(tx, st.Text())
					if err != nil {
						tx.Rollback()
						continue
					}
					if ok := chkResult(output, rset); !ok {
						log.Fatal("error ", q, "\nExcept:\n", rset, "\nGot:\n", output)
					}
					err = tx.Commit()
					if err != nil {
						tx.Rollback()
						continue
					}
				}
			}
		}
		if err != nil {
			mustOk(test, err, expErr, re)
		}
	}

	return
}

func main() {
	flag.Parse()
	log.SetLevelByString(*logLevel)
	runParallel()
}
