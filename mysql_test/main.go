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
	"fmt"
	"io/ioutil"
	"os"
	"strings"

	"github.com/docopt/docopt-go"
	_ "github.com/go-sql-driver/mysql"
	"github.com/juju/errors"
	"github.com/ngaut/log"
	"github.com/pingcap/tidb"
	"github.com/pingcap/tidb/ast"
	"github.com/pingcap/tidb/context"
	"github.com/pingcap/tidb/util/mock"
)

var usage = `
	Usage: mysql_test [options] [<tests>...]

options:
	--record                       Record the test output in the result file
	--log-level=<loglevel>         set log level: info, warn, error, debug [default: error]
`

var (
	mdb    *sql.DB
	record bool
)

type query struct {
	Query string
	Line  int
}

type tester struct {
	name string

	tx *sql.Tx

	buf bytes.Buffer

	// enable query log will output origin statement into result file too
	// use --disable_query_log or --enable_query_log to control it
	enableQueryLog bool

	singleQuery bool

	// check expected error, use --error before the statement
	// see http://dev.mysql.com/doc/mysqltest/2.0/en/writing-tests-expecting-errors.html
	expectedErrs []string

	// only for test, not record, every time we execute a statement, we should read the result
	// data to check correction.
	resultFD *os.File
	// ctx is used for Compile sql statement
	ctx context.Context
}

func newTester(name string) *tester {
	t := new(tester)

	t.name = name
	t.enableQueryLog = true
	t.ctx = mock.NewContext()

	return t
}

func (t *tester) Run() error {
	queries, err := t.loadQueries()
	if err != nil {
		return errors.Trace(err)
	}

	if err = t.openResult(); err != nil {
		return errors.Trace(err)
	}

	var s string
	defer func() {
		if t.tx != nil {
			log.Errorf("transaction is not committed correctly, rollback")
			t.rollback()
		}

		if t.resultFD != nil {
			t.resultFD.Close()
		}
	}()

LOOP:
	for _, q := range queries {
		s = q.Query
		if strings.HasPrefix(s, "--") {
			// clear expected errors
			t.expectedErrs = nil

			switch s {
			case "--enable_query_log":
				t.enableQueryLog = true
			case "--disable_query_log":
				t.enableQueryLog = false
			case "--single_query":
				t.singleQuery = true
			case "--halt":
				// if we meet halt, we will ignore following tests
				break LOOP
			default:
				if strings.HasPrefix(s, "--error") {
					t.expectedErrs = strings.Split(strings.TrimSpace(strings.TrimLeft(s, "--error")), ",")
				} else if strings.HasPrefix(s, "--echo") {
					echo := strings.TrimSpace(strings.TrimLeft(s, "--echo"))
					t.buf.WriteString(echo)
					t.buf.WriteString("\n")
				}
			}
		} else {
			if err = t.execute(q); err != nil {
				return errors.Trace(err)
			}
		}
	}

	return t.flushResult()
}

func (t *tester) loadQueries() ([]query, error) {
	data, err := ioutil.ReadFile(t.testFileName())
	if err != nil {
		return nil, err
	}

	seps := bytes.Split(data, []byte("\n"))
	queries := make([]query, 0, len(seps))
	newStmt := true
	for i, v := range seps {
		v := bytes.TrimSpace(v)
		s := string(v)
		// we will skip # comment here
		if strings.HasPrefix(s, "#") {
			newStmt = true
			continue
		} else if strings.HasPrefix(s, "--") {
			queries = append(queries, query{Query: s, Line: i + 1})
			newStmt = true
			continue
		} else if len(s) == 0 {
			continue
		}

		if newStmt {
			queries = append(queries, query{Query: s, Line: i + 1})
		} else {
			lastQuery := queries[len(queries)-1]
			lastQuery.Query = fmt.Sprintf("%s\n%s", lastQuery.Query, s)
			queries[len(queries)-1] = lastQuery
		}

		// if the line has a ; in the end, we will treat new line as the new statement.
		newStmt = strings.HasSuffix(s, ";")
	}
	return queries, nil
}

func (t *tester) execute(query query) error {
	if len(query.Query) == 0 {
		return nil
	}

	list, err := tidb.Parse(t.ctx, query.Query)
	if err != nil {
		return err
	}

	for _, st := range list {
		var qText string
		if t.singleQuery {
			qText = query.Query
		} else {
			qText = st.Text()
		}
		offset := t.buf.Len()
		if t.enableQueryLog {
			t.buf.WriteString(qText)
			t.buf.WriteString("\n")
		}

		switch st.(type) {
		case *ast.BeginStmt:
			t.tx, err = mdb.Begin()
			if err != nil {
				t.rollback()
				break
			}
		case *ast.CommitStmt:
			err = t.commit()
			if err != nil {
				t.rollback()
				break
			}
		case *ast.RollbackStmt:
			err = t.rollback()
			if err != nil {
				break
			}
		default:
			if t.tx != nil {
				err = t.executeStmt(qText)
				if err != nil {
					break
				}
			} else {
				// if begin or following commit fails, we don't think
				// this error is the expected one.
				if t.tx, err = mdb.Begin(); err != nil {
					t.rollback()
					break
				}

				err = t.executeStmt(qText)
				if err != nil {
					t.rollback()
					break
				} else {
					if err = t.commit(); err != nil {
						t.rollback()
						break
					}
				}
			}
		}

		if err != nil && len(t.expectedErrs) > 0 {
			// TODO: check whether this err is expected.
			// but now we think it is.

			// output expected err
			t.buf.WriteString(fmt.Sprintf("%s\n", err))
			err = nil
		}
		// clear expected errors after we execute the first query
		t.expectedErrs = nil
		t.singleQuery = false

		if err != nil {
			return errors.Errorf("run \"%v\" at line %d err %v", st.Text(), query.Line, err)
		}

		if !record {
			// check test result now
			gotBuf := t.buf.Bytes()[offset:]
			buf := make([]byte, t.buf.Len()-offset)
			if _, err = t.resultFD.ReadAt(buf, int64(offset)); err != nil {
				return errors.Errorf("run \"%v\" at line %d err, we got \n%s\nbut read result err %s", st.Text(), query.Line, gotBuf, err)
			}

			if !bytes.Equal(gotBuf, buf) {
				return errors.Errorf("run \"%v\" at line %d err, we need:\n%s\nbut got:\n%s\n", st.Text(), query.Line, buf, gotBuf)
			}
		}
	}

	return err
}

func (t *tester) commit() error {
	err := t.tx.Commit()
	if err != nil {
		return err
	}
	t.tx = nil
	return nil
}

func (t *tester) rollback() error {
	if t.tx == nil {
		return nil
	}
	err := t.tx.Rollback()
	t.tx = nil
	return err
}

func (t *tester) executeStmt(query string) error {
	if tidb.IsQuery(query) {
		rows, err := t.tx.Query(query)
		if err != nil {
			return errors.Trace(err)
		}
		cols, err := rows.Columns()
		if err != nil {
			return errors.Trace(err)
		}

		for i, c := range cols {
			t.buf.WriteString(c)
			if i != len(cols)-1 {
				t.buf.WriteString("\t")
			}
		}
		t.buf.WriteString("\n")

		values := make([][]byte, len(cols))
		scanArgs := make([]interface{}, len(values))
		for i := range values {
			scanArgs[i] = &values[i]
		}

		for rows.Next() {
			err := rows.Scan(scanArgs...)
			if err != nil {
				return errors.Trace(err)
			}

			var value string
			for i, col := range values {
				// Here we can check if the value is nil (NULL value)
				if col == nil {
					value = "NULL"
				} else {
					value = string(col)
				}
				t.buf.WriteString(value)
				if i < len(values)-1 {
					t.buf.WriteString("\t")
				}
			}
			t.buf.WriteString("\n")
		}
		err = rows.Err()
		if err != nil {
			return errors.Trace(err)
		}
	} else {
		// TODO: rows affected and last insert id
		_, err := t.tx.Exec(query)
		if err != nil {
			return errors.Trace(err)
		}
	}
	return nil
}

func (t *tester) openResult() error {
	if record {
		return nil
	}

	var err error
	t.resultFD, err = os.Open(t.resultFileName())
	return err
}

func (t *tester) flushResult() error {
	if !record {
		return nil
	}
	return ioutil.WriteFile(t.resultFileName(), t.buf.Bytes(), 0644)
}

func (t *tester) testFileName() string {
	// test and result must be in current ./t the same as MySQL
	return fmt.Sprintf("./t/%s.test", t.name)
}

func (t *tester) resultFileName() string {
	// test and result must be in current ./r, the same as MySQL
	return fmt.Sprintf("./r/%s.result", t.name)
}

func loadAllTests() ([]string, error) {
	// tests must be in t folder
	files, err := ioutil.ReadDir("./t")
	if err != nil {
		return nil, err
	}

	tests := make([]string, 0, len(files))
	for _, f := range files {
		if f.IsDir() {
			continue
		}

		// the test file must have a suffix .test
		name := f.Name()
		if strings.HasSuffix(name, ".test") {
			name = strings.TrimSuffix(name, ".test")

			// if we use record and the result file exists, skip generating
			if record && resultExists(name) {
				continue
			}

			tests = append(tests, name)
		}
	}

	return tests, nil
}

func resultExists(name string) bool {
	resultFile := fmt.Sprintf("./r/%s.result", name)

	if _, err := os.Stat(resultFile); err != nil {
		if os.IsNotExist(err) {
			return false
		}
	}
	return true
}

func main() {
	args, err := docopt.Parse(usage, nil, true, "mysql_test v0.1", true)
	if err != nil {
		log.Fatal(err)
	}

	if args["--log-level"] != nil {
		log.SetLevelByString(args["--log-level"].(string))
	}

	dbName := "test"
	mdb, err = sql.Open("mysql", "root@tcp(localhost:4001)/"+dbName+"?strict=true")
	if err != nil {
		log.Fatalf("Open db err %v", err)
	}

	defer func() {
		log.Warn("close db")
		mdb.Close()
	}()

	log.Warn("Create new db", mdb)

	if _, err = mdb.Exec("USE test"); err != nil {
		log.Fatalf("Executing Use test err[%v]", err)
	}

	var tests []string
	if v := args["<tests>"]; v != nil {
		tests = v.([]string)
	}

	if v := args["--record"]; v != nil {
		record = v.(bool)
	}

	// we will run all tests if no tests assigned
	if len(tests) == 0 {
		if tests, err = loadAllTests(); err != nil {
			log.Fatalf("load all tests err %v", err)
		}
	}

	if !record {
		log.Infof("running tests: %v", tests)
	} else {
		log.Infof("recording tests: %v", tests)
	}

	for _, t := range tests {
		if strings.Contains(t, "--log-level") {
			continue
		}
		tr := newTester(t)
		if err = tr.Run(); err != nil {
			log.Fatalf("run test [%s] err: %v", t, err)
		} else {
			log.Infof("run test [%s] ok", t)
		}
	}

	println("\nGreat, All tests passed")
}