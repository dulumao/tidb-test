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
	"strings"
	"sync"
	"time"

	"github.com/juju/errors"
	"github.com/ngaut/log"
	"github.com/pingcap/tidb-test/stability_test/config"
	"golang.org/x/net/context"
)

// BackCase is for concurrent balance transfer.
type BankCase struct {
	cfg         *config.BankCaseConfig
	concurrency int
}

// NewBankCase returns the BankCase.
func NewBankCase(cfg *config.Config) Case {
	b := &BankCase{
		cfg:         &cfg.Suite.Bank,
		concurrency: cfg.Suite.Concurrency,
	}
	if b.cfg.TableNum <= 1 {
		b.cfg.TableNum = 1
	}
	return b
}

// Initialize implements Case Initialize interface.
func (c *BankCase) Initialize(ctx context.Context, db *sql.DB) error {
	for i := 0; i < c.cfg.TableNum; i++ {
		err := c.initDB(ctx, db, i)
		if err != nil {
			return err
		}
	}
	return nil
}

func (c *BankCase) initDB(ctx context.Context, db *sql.DB, id int) error {
	var index string
	if id > 0 {
		index = fmt.Sprintf("%d", id)
	}
	isDropped := c.tryDrop(db, index)
	if !isDropped {
		c.startVerify(ctx, db, index)
		return nil
	}

	mustExec(db, fmt.Sprintf("create table if not exists accounts%s (id BIGINT PRIMARY KEY, balance BIGINT NOT NULL)", index))
	var wg sync.WaitGroup

	// TODO: fix the error is NumAccounts can't be divided by batchSize.
	// Insert batchSize values in one SQL.
	batchSize := 100
	jobCount := c.cfg.NumAccounts / batchSize
	wg.Add(jobCount)

	ch := make(chan int, jobCount)
	for i := 0; i < c.concurrency; i++ {
		go func() {
			args := make([]string, batchSize)

			for {
				startIndex, ok := <-ch
				if !ok {
					return
				}

				start := time.Now()

				for i := 0; i < batchSize; i++ {
					args[i] = fmt.Sprintf("(%d, %d)", startIndex+i, 1000)
				}

				query := fmt.Sprintf("INSERT IGNORE INTO accounts%s (id, balance) VALUES %s", index, strings.Join(args, ","))
				insertF := func() error {
					_, err := db.Exec(query)
					return err
				}
				err := runWithRetry(ctx, 100, 3*time.Second, insertF)
				if err != nil {
					log.Fatalf("exec %s err %s", query, err)
				}

				log.Infof("[%s] insert %d accounts%s, takes %s", c, batchSize, index, time.Now().Sub(start))

				wg.Done()
			}
		}()
	}

	for i := 0; i < jobCount; i++ {
		ch <- i * batchSize
	}

	wg.Wait()
	close(ch)

	c.startVerify(ctx, db, index)
	return nil
}

func (c *BankCase) startVerify(ctx context.Context, db *sql.DB, index string) {
	c.verify(db, index)

	go func(index string) {
		ticker := time.NewTicker(c.cfg.Interval.Duration)
		defer ticker.Stop()

		for {
			select {
			case <-ticker.C:
				c.verify(db, index)
			case <-ctx.Done():
				return
			}
		}
	}(index)
}

// Execute implements Case Execute interface.
func (c *BankCase) Execute(db *sql.DB, index int) error {
	c.moveMoney(db)
	return nil
}

// String implements fmt.Stringer interface.
func (c *BankCase) String() string {
	return "bank"
}

//tryDrop will drop table if data incorrect and panic error likes Bad connect.
func (c *BankCase) tryDrop(db *sql.DB, index string) bool {
	var (
		count int
		table string
	)
	//if table is not exist ,return true directly
	query := fmt.Sprintf("show tables like 'accounts%s'", index)
	err := db.QueryRow(query).Scan(&table)
	switch {
	case err == sql.ErrNoRows:
		return true
	case err != nil:
		log.Fatal(err)
	}

	query = fmt.Sprintf("select count(*) as count from accounts%s", index)
	err = db.QueryRow(query).Scan(&count)
	if err != nil {
		log.Fatal(err)
	}
	if count == c.cfg.NumAccounts {
		return false
	}

	log.Infof("[%s] we need %d accounts%s but got %d, re-initialize the data again", c, c.cfg.NumAccounts, index, count)
	mustExec(db, fmt.Sprintf("drop table if exists accounts%s", index))
	return true
}

func (c *BankCase) verify(db *sql.DB, index string) {
	var total int

	start := time.Now()

	query := fmt.Sprintf("select sum(balance) as total from accounts%s", index)
	err := db.QueryRow(query).Scan(&total)
	if err != nil {
		bankVerifyFailedCounter.Inc()
		//log.Errorf("[%s] select sum err %v", c, err)
		return
	}
	bankVerifyDuration.Observe(time.Since(start).Seconds())

	check := c.cfg.NumAccounts * 1000
	if total != check {
		log.Fatalf("[%s]accouts%s total must %d, but got %d", c, index, check, total)
	}
}

func (c *BankCase) moveMoney(db *sql.DB) {
	var (
		from, to, id int
		index        string
	)
	for {
		from, to, id = rand.Intn(c.cfg.NumAccounts), rand.Intn(c.cfg.NumAccounts), rand.Intn(c.cfg.TableNum)
		if from == to {
			continue
		}
		break
	}
	if id > 0 {
		index = fmt.Sprintf("%d", id)
	}

	amount := rand.Intn(999)

	start := time.Now()

	err := c.execTransaction(db, from, to, amount, index)

	if err != nil {
		bankTxnFailedCounter.Inc()
		//log.Errorf("[%s] move money err %v", c, err)
		return
	}
	bankTxnDuration.Observe(time.Since(start).Seconds())
}

func (c *BankCase) execTransaction(db *sql.DB, from, to int, amount int, index string) error {
	tx, err := db.Begin()
	if err != nil {
		return errors.Trace(err)
	}

	defer tx.Rollback()

	rows, err := tx.Query(fmt.Sprintf("SELECT id, balance FROM accounts%s WHERE id IN (%d, %d) FOR UPDATE", index, from, to))
	if err != nil {
		return errors.Trace(err)
	}
	defer rows.Close()

	var (
		fromBalance int
		toBalance   int
		count       int = 0
	)

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
			log.Fatalf("[%s] got unexpected account %d", c, id)
		}

		count += 1
	}

	if err = rows.Err(); err != nil {
		return errors.Trace(err)
	}

	if count != 2 {
		log.Fatalf("[%s] select %d(%d) -> %d(%d) invalid count %d", c, from, fromBalance, to, toBalance, count)
	}

	if fromBalance >= amount {
		update := fmt.Sprintf(`
UPDATE accounts%s
  SET balance = CASE id WHEN %d THEN %d WHEN %d THEN %d END
  WHERE id IN (%d, %d)
`, index, to, toBalance+amount, from, fromBalance-amount, from, to)
		_, err = tx.Exec(update)
		if err != nil {
			return errors.Trace(err)
		}
	}

	return errors.Trace(tx.Commit())
}

func init() {
	RegisterSuite("bank", NewBankCase)
}
