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

package nemesis

import (
	"time"

	"github.com/juju/errors"
	"github.com/ngaut/log"
	"github.com/pingcap/tidb-test/cluster_test/pkg/cluster"
)

// Nemesis introduces failures across the cluster inspired by Jepsen.
type Nemesis interface {
	// Execute executes the nemesis.
	Execute(c *cluster.Cluster, names ...string) error

	// String implements fmt.Stringer interface.
	String() string
}

// KillNemesis kill the service first, waits some time and then starts again.
type KillNemesis struct {
	WaitTime time.Duration
}

// Execute implements Nemesis Execute interface.
func (n *KillNemesis) Execute(c *cluster.Cluster, names ...string) error {
	if err := c.Kill(names...); err != nil {
		// If kill failed, we log an error here and then
		log.Errorf("kill %v err %s", names, err)
	}

	time.Sleep(n.WaitTime)

	err := c.Start(names...)

	return errors.Trace(err)
}

// String implements fmt.Stringer interface.
func (n *KillNemesis) String() string {
	return "kill"
}
