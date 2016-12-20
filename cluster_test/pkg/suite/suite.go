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
	"time"

	"github.com/juju/errors"
	"github.com/ngaut/log"
)

// Case is a test case for running cluster.
type Case interface {
	// SetUp initializes the case.
	SetUp(db *sql.DB) error
	// Execute executes the case.
	Execute(db *sql.DB) error

	// TearDown tears down the case.
	TearDown(db *sql.DB) error

	// String implements fmt.Stringer interface.
	String() string
}

func mustExec(db *sql.DB, query string, args ...interface{}) sql.Result {
	r, err := db.Exec(query, args...)
	if err != nil {
		log.Fatalf("exec %s err %v", query, err)
	}
	return r
}

type suiteCase struct {
	c      Case
	ok     uint64
	failed uint64
	total  time.Duration
}

// Suite wraps all test cases.
type Suite struct {
	cases []*suiteCase
}

// NewSuite creates the test suite.
func NewSuite() *Suite {
	s := &Suite{
		cases: make([]*suiteCase, 0),
	}

	return s
}

// Register registers a test case.
func (s *Suite) Register(c Case) {
	s.cases = append(s.cases, &suiteCase{
		c:      c,
		ok:     0,
		failed: 0,
	})
}

// SetUp initialize the suite.
func (s *Suite) SetUp(db *sql.DB) error {
	for _, c := range s.cases {
		if err := c.c.SetUp(db); err != nil {
			return errors.Trace(err)
		}
	}
	return nil
}

// TearDown tears down the suite.
func (s *Suite) TearDown(db *sql.DB) error {
	for _, c := range s.cases {
		if err := c.c.TearDown(db); err != nil {
			return errors.Trace(err)
		}
	}
	return nil
}

// Execute executes all test cases once.
func (s *Suite) Execute(db *sql.DB) {
	for _, c := range s.cases {
		start := time.Now()
		if err := c.c.Execute(db); err != nil {
			c.failed++
			log.Errorf("execute %s failed %v", c.c, err)
		} else {
			c.ok++
		}
		c.total += time.Now().Sub(start)
	}
}

// Output outputs all test cases information.
func (s *Suite) Output() {
	for _, c := range s.cases {
		fmt.Printf("Run %s: ok %d, failed %d, cost %s\n", c.c, c.ok, c.failed, c.total)
		c.total = 0
	}
}
