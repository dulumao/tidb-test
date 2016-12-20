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
	"time"

	"github.com/ngaut/log"
	"github.com/pingcap/tidb-test/stability_test/config"
	"github.com/twinj/uuid"
	"golang.org/x/net/context"
)

const blockWriterBatchSize = 20

// BlockWriterCase is for concurrent writing blocks.
type BlockWriterCase struct {
	cfg *config.BlockWriterCaseConfig
	bws []*blockWriter
}

type blockWriter struct {
	minSize         int
	maxSize         int
	id              string
	blockCount      uint64
	rand            *rand.Rand
	blockDataBuffer []byte
	values          []string
	index           int
}

// NewBlockWriterCase returns the BlockWriterCase.
func NewBlockWriterCase(cfg *config.Config) Case {
	c := &BlockWriterCase{
		cfg: &cfg.Suite.BlockWriter,
	}
	if c.cfg.TableNum < 1 {
		c.cfg.TableNum = 1
	}

	c.initBlocks(cfg.Suite.Concurrency)

	return c
}

func (c *BlockWriterCase) initBlocks(concurrency int) {
	c.bws = make([]*blockWriter, concurrency)
	for i := 0; i < concurrency; i++ {
		c.bws[i] = c.newBlockWriter()
	}
}

func (c *BlockWriterCase) newBlockWriter() *blockWriter {
	source := rand.NewSource(int64(time.Now().UnixNano()))
	return &blockWriter{
		id:              uuid.NewV4().String(),
		rand:            rand.New(source),
		blockCount:      0,
		minSize:         128,
		maxSize:         1024,
		blockDataBuffer: make([]byte, 1024),
		values:          make([]string, blockWriterBatchSize),
	}
}

// Insert blockWriterBatchSize values in one SQL.
//
// TODO: configure it from outside.

func (bw *blockWriter) batchExecute(db *sql.DB, tableNum int) {
	// buffer values
	for i := 0; i < blockWriterBatchSize; i++ {
		blockID := bw.rand.Int63()
		blockData := bw.randomBlock()
		bw.blockCount++
		bw.values[i] = fmt.Sprintf("(%d,'%s',%d,'%s')", blockID, bw.id, bw.blockCount, blockData)
	}
	start := time.Now()
	var (
		err   error
		index string
	)

	if bw.index > 0 {
		index = fmt.Sprintf("%d", bw.index)
	}
	_, err = db.Exec(
		fmt.Sprintf(
			"INSERT INTO block_writer%s (block_id, writer_id, block_num, raw_bytes) VALUES %s",
			index, strings.Join(bw.values, ",")),
	)

	if err != nil {
		blockWriteFailedCounter.Inc()
		log.Errorf("[block writer] insert err %v", err)
		return
	}
	bw.index = (bw.index + 1) % tableNum
	blockBatchWriteDuration.Observe(time.Since(start).Seconds())
}

func (bw *blockWriter) randomBlock() []byte {
	blockSize := bw.rand.Intn(bw.maxSize-bw.minSize) + bw.minSize

	randString(bw.blockDataBuffer, bw.rand)
	return bw.blockDataBuffer[:blockSize]
}

// Initialize implements Case Initialize interface.
func (c *BlockWriterCase) Initialize(ctx context.Context, db *sql.DB) error {
	for i := 0; i < c.cfg.TableNum; i++ {
		var s string
		if i > 0 {
			s = fmt.Sprintf("%d", i)
		}
		mustExec(db, fmt.Sprintf("CREATE TABLE IF NOT EXISTS block_writer%s %s", s, `
	(
      block_id BIGINT NOT NULL,
      writer_id VARCHAR(64) NOT NULL,
      block_num BIGINT NOT NULL,
      raw_bytes BLOB NOT NULL,
      PRIMARY KEY (block_id, writer_id, block_num)
)`))
	}
	return nil
}

// Execute implements Case Execute interface.
func (c *BlockWriterCase) Execute(db *sql.DB, index int) error {
	c.bws[index].batchExecute(db, c.cfg.TableNum)
	return nil
}

// String implements fmt.Stringer interface.
func (c *BlockWriterCase) String() string {
	return "block_writer"
}

func init() {
	RegisterSuite("block_writer", NewBlockWriterCase)
}