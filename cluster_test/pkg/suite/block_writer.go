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
	"math/rand"
	"sync"
	"time"

	"github.com/juju/errors"
	"github.com/satori/go.uuid"
)

// must lock own rand for concurrent use.
type lockedSource struct {
	lk  sync.Mutex
	src rand.Source
}

func (r *lockedSource) Int63() (n int64) {
	r.lk.Lock()
	n = r.src.Int63()
	r.lk.Unlock()
	return
}

func (r *lockedSource) Seed(seed int64) {
	r.lk.Lock()
	r.src.Seed(seed)
	r.lk.Unlock()
}

// BlockWriterCase writes blocks of random data into db.
type BlockWriterCase struct {
	MinBlockSizeBytes int
	MaxBlockSizeBytes int

	bws []*blockWriter
}

type blockWriter struct {
	minSize    int
	maxSize    int
	id         string
	blockCount uint64
	rand       *rand.Rand
}

// NewBlockWriterCase creates the BlockWriterCase.
func NewBlockWriterCase(concurrency int, minBlockSizeBytes int, maxBlockSizeBytes int) *BlockWriterCase {
	c := &BlockWriterCase{
		MinBlockSizeBytes: minBlockSizeBytes,
		MaxBlockSizeBytes: maxBlockSizeBytes,
		bws:               make([]*blockWriter, concurrency),
	}

	for i := 0; i < concurrency; i++ {
		c.bws[i] = c.newBlockWriter()
	}

	return c
}

// String implements fmt.Stringer interface.
func (c *BlockWriterCase) String() string {
	return "block_writer"
}

// SetUp implements Case SetUp interface.
func (c *BlockWriterCase) SetUp(db *sql.DB) error {
	mustExec(db, "drop table if exists test_block_writer")
	mustExec(db, `
CREATE TABLE IF NOT EXISTS test_block_writer (
      block_id BIGINT NOT NULL,
      writer_id VARCHAR(64) NOT NULL,
      block_num BIGINT NOT NULL,
      raw_bytes BLOB NOT NULL,
      PRIMARY KEY (block_id, writer_id, block_num)
)`)

	return nil
}

// TearDown implements Case TearDown interface.
func (c *BlockWriterCase) TearDown(db *sql.DB) error {
	return nil
}

// Execute implements Case Execute interface.
func (c *BlockWriterCase) Execute(db *sql.DB) error {
	concurrency := len(c.bws)
	ch := make(chan error, concurrency)
	for i := 0; i < concurrency; i++ {
		go c.bws[i].execute(db, ch)
	}

	for i := 0; i < concurrency; i++ {
		err := <-ch
		if err != nil {
			return errors.Trace(err)
		}
	}
	return nil
}

func (c *BlockWriterCase) newBlockWriter() *blockWriter {
	source := rand.NewSource(int64(time.Now().UnixNano()))
	return &blockWriter{
		id:         uuid.NewV4().String(),
		rand:       rand.New(&lockedSource{src: source}),
		blockCount: 0,
		minSize:    c.MinBlockSizeBytes,
		maxSize:    c.MaxBlockSizeBytes,
	}
}

func (bw *blockWriter) randomBlock() []byte {
	blockSize := bw.rand.Intn(bw.maxSize-bw.minSize) + bw.minSize
	blockData := make([]byte, blockSize)
	for i := range blockData {
		blockData[i] = byte(bw.rand.Int() & 0xff)
	}
	return blockData
}

func (bw *blockWriter) execute(db *sql.DB, ch chan error) {
	blockID := bw.rand.Int63()
	blockData := bw.randomBlock()
	bw.blockCount++

	_, err := db.Exec(`INSERT INTO test_block_writer (block_id, writer_id, block_num, raw_bytes) VALUES (?, ?, ?, ?)`,
		blockID, bw.id, bw.blockCount, blockData)
	ch <- errors.Trace(err)
}
