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

package suite

import (
	"database/sql"
	"fmt"
	"math/rand"

	"github.com/juju/errors"
	"github.com/ngaut/log"
)

// SimpleTransferCase is a simple bank transfer case.
type SimpleTransferCase struct {
	from int
	to   int
}

// NewSimpleTransferCase creates the SimpleTransferCase.
func NewSimpleTransferCase(from, to int) *SimpleTransferCase {
	t := &SimpleTransferCase{
		from: from,
		to:   to,
	}

	return t
}

// String implements fmt.Stringer interface.
func (t *SimpleTransferCase) String() string {
	return "simple_transfer"
}

// SetUp implements Case SetUp interface.
func (t *SimpleTransferCase) SetUp(db *sql.DB) error {
	mustExec(db, "drop table if exists test_simple_transfer")
	mustExec(db, "create table test_simple_transfer (id int, balance int, primary key(id))")
	mustExec(db, "insert into test_simple_transfer values (1, 1000), (2, 1000)")

	return nil
}

// TearDown implements Case TearDown interface.
func (t *SimpleTransferCase) TearDown(db *sql.DB) error {
	return nil
}

// Execute implements Case Execute interface.
func (t *SimpleTransferCase) Execute(db *sql.DB) error {
	err := t.transfer(db, t.from, t.to)
	t.from, t.to = t.to, t.from
	if err != nil {
		return errors.Trace(err)
	}

	return nil
}

func (t *SimpleTransferCase) transfer(db *sql.DB, from, to int) error {
	tx, err := db.Begin()
	if err != nil {
		return errors.Trace(err)
	}

	defer tx.Rollback()

	balance := rand.Intn(10) + 1

	query := fmt.Sprintf("update test_simple_transfer set balance = balance - %d where id = %d", balance, from)
	if _, err = tx.Exec(query); err != nil {
		return errors.Errorf("exec %s err %v", query, err)
	}

	query = fmt.Sprintf("update test_simple_transfer set balance = balance + %d where id = %d", balance, to)
	if _, err = tx.Exec(query); err != nil {
		return errors.Errorf("exec %s err %v", query, err)
	}

	if err = tx.Commit(); err != nil {
		return errors.Trace(err)
	}

	log.Debugf("transfer %d from %d to %d ok", balance, from, to)

	var total int
	query = "select sum(balance) as total from test_simple_transfer"
	err = db.QueryRow(query).Scan(&total)
	if err != nil {
		return errors.Errorf("query %s err %v", query, err)
	}

	if total != 2000 {
		log.Fatalf("%s total must 2000, but got %d", t, total)
	}

	return nil
}
