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
	"time"

	"github.com/ngaut/log"
	"github.com/pingcap/tidb-test/stability_test/config"
	"golang.org/x/net/context"
)

//this case for test TiKV perform when write small datavery frequently
type SmallWriterCase struct {
	sws []*smallDataWriter
}

const smallWriterBatchSize = 20

//the small data is a int number
type smallDataWriter struct {
	rand   *rand.Rand
	values []string
}

//NewSmallWriterCase returns the smallWriterCase.
func NewSmallWriterCase(cfg *config.Config) Case {
	c := &SmallWriterCase{}

	c.initSmallDataWriter(cfg.Suite.Concurrency)
	return c
}

func (c *SmallWriterCase) initSmallDataWriter(concurrency int) {
	c.sws = make([]*smallDataWriter, concurrency)
	for i := 0; i < concurrency; i++ {
		source := rand.NewSource(int64(time.Now().UnixNano()))
		c.sws[i] = &smallDataWriter{
			rand:   rand.New(source),
			values: make([]string, smallWriterBatchSize),
		}
	}
}

// Initialize implements Case Initialize interface.
func (c *SmallWriterCase) Initialize(ctx context.Context, db *sql.DB) error {
	mustExec(db, "create table if not exists small_writer(id bigint auto_increment, data bigint, primary key(id))")

	return nil
}

// Execute implements Case Execute interface.
func (c *SmallWriterCase) Execute(db *sql.DB, index int) error {
	c.sws[index].batchExecute(db)
	return nil
}

// String implements fmt.Stringer interface.
func (c *SmallWriterCase) String() string {
	return "small_writer"
}

// Insert values.
func (sw *smallDataWriter) batchExecute(db *sql.DB) {
	var err error
	for i := 0; i < smallWriterBatchSize; i++ {
		start := time.Now()
		_, err = db.Exec(
			fmt.Sprintf(
				"INSERT INTO small_writer (data) VALUES (%d)",
				sw.rand.Int()),
		)

		if err != nil {
			smallWriteFailedCounter.Inc()
			log.Errorf("[small writer] insert err %v", err)
			return
		}
		smallWriteDuration.Observe(time.Since(start).Seconds())
	}
}

func init() {
	RegisterSuite("block_writer", NewSmallWriterCase)
}
