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
	"log"
	"math/rand"

	"github.com/juju/errors"
)

// MultiTransferCase is a multi bank transfer case.
type MultiTransferCase struct {
	MaxTransfer int
	NumAccounts int
	Concurrency int
}

// NewMultiTransferCase creates the MultiTransferCase.
func NewMultiTransferCase(numAccounts int, concurrency int, maxTransfer int) *MultiTransferCase {
	t := &MultiTransferCase{
		MaxTransfer: maxTransfer,
		NumAccounts: numAccounts,
		Concurrency: concurrency,
	}

	return t
}

// String implements fmt.Stringer interface.
func (t *MultiTransferCase) String() string {
	return "mutli_transfer"
}

// SetUp implements Case SetUp interface.
func (t *MultiTransferCase) SetUp(db *sql.DB) error {
	mustExec(db, "drop table if exists test_multi_transfer")
	mustExec(db, "create table test_multi_transfer (id BIGINT PRIMARY KEY, balance BIGINT NOT NULL)")

	for i := 0; i < t.NumAccounts; i++ {
		mustExec(db, fmt.Sprintf("insert into test_multi_transfer (id, balance) values (%d, 1000)", i))
	}

	return nil
}

// TearDown implements Case TearDown interface.
func (t *MultiTransferCase) TearDown(db *sql.DB) error {
	return nil
}

// Execute implements Case Execute interface.
func (t *MultiTransferCase) Execute(db *sql.DB) error {
	if err := t.execute(db); err != nil {
		return errors.Trace(err)
	}

	return nil
}

func (t *MultiTransferCase) execute(db *sql.DB) error {
	ch := make(chan error, t.Concurrency)
	for i := 0; i < t.Concurrency; i++ {
		go t.moveMoney(db, ch)
	}

	for i := 0; i < t.Concurrency; i++ {
		err := <-ch
		if err != nil {
			return errors.Trace(err)
		}
	}

	var total int
	query := "select sum(balance) as total from test_multi_transfer"
	err := db.QueryRow(query).Scan(&total)
	if err != nil {
		return errors.Errorf("query %s err %v", query, err)
	}

	check := t.NumAccounts * 1000
	if total != check {
		log.Fatalf("%s total must %d, but got %d", t, check, total)
	}

	return nil
}

func (t *MultiTransferCase) moveMoney(db *sql.DB, ch chan error) {
	var from, to int
	for {
		from, to = rand.Intn(t.NumAccounts), rand.Intn(t.NumAccounts)
		if from == to {
			continue
		}
		break
	}

	amount := rand.Intn(t.MaxTransfer)

	err := t.execTransaction(db, from, to, amount)

	ch <- err
}

func (t *MultiTransferCase) execTransaction(db *sql.DB, from, to int, amount int) error {
	tx, err := db.Begin()
	if err != nil {
		return errors.Trace(err)
	}

	defer tx.Rollback()

	rows, err := tx.Query(fmt.Sprintf("SELECT id, balance FROM test_multi_transfer WHERE id IN (%d, %d) FOR UPDATE", from, to))
	if err != nil {
		return errors.Trace(err)
	}
	defer rows.Close()

	var fromBalance, toBalance int
	for rows.Next() {
		var id, balance int
		if err = rows.Scan(&id, &balance); err != nil {
			return errors.Trace(err)
		}
		switch id {
		case from:
			fromBalance = balance
		case to:
			toBalance = balance
		default:
			log.Fatalf("got unexpected account %d", id)
		}
	}

	if err = rows.Err(); err != nil {
		return errors.Trace(err)
	}

	if fromBalance >= amount {
		update := fmt.Sprintf(`
UPDATE test_multi_transfer
  SET balance = CASE id WHEN %d THEN %d WHEN %d THEN %d END
  WHERE id IN (%d, %d)
`, to, toBalance+amount, from, fromBalance-amount, from, to)
		_, err = tx.Exec(update)
		if err != nil {
			return errors.Trace(err)
		}
	}

	return errors.Trace(tx.Commit())
}
