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

package cluster

import (
	"fmt"
	"strings"

	"github.com/juju/errors"
	"github.com/pingcap/tidb-test/stability_test/config"
	"golang.org/x/net/context"
)

// binaryNode is for Binary type service in node.
type awsNode struct {
	ssh     *sshNode
	name    string
	user    string
	command []string
	wrap    string
}

// New bianry Node
func awsNodeFactory(cfg config.ServiceConfig) Node {
	b := &awsNode{
		ssh:     newSSHNode(cfg),
		name:    cfg.Name,
		command: cfg.Command,
		user:    cfg.SSH.User,
	}

	return b
}

// Start implements Node Start interface.
func (b *awsNode) Start() error {
	serverName := b.name[:strings.Index(b.name, "-")]
	command := fmt.Sprintf("/home/%s/deploy/bin/svc -u /home/%s/deploy/status/%s", b.user, b.user, serverName)
	err := b.ssh.execCmd(command)
	if err != nil {
		return errors.Trace(err)

	}
	return nil
}

// Stop implements Node Stop interface.
func (b *awsNode) Stop() error {
	return nil
}

// Kill implements Node Kill interface
func (b *awsNode) Kill() error {
	serverName := b.name[:strings.Index(b.name, "-")]
	command := fmt.Sprintf("/home/%s/deploy/bin/svc -k  /home/%s/deploy/status/%s;/home/%s/deploy/bin/svc -d  /home/%s/deploy/status/%s", b.user, b.user, serverName, b.user, b.user, serverName)
	err := b.ssh.execCmd(command)
	if err != nil {
		return errors.Trace(err)

	}
	return nil
}

// IsRunning implements Node IsRunning interface.
func (b *awsNode) IsRunning() (bool, error) {
	return true, nil
}

// Execute implements Node Execute interface.
func (b *awsNode) Execute(ctx context.Context, command string) error {
	cmdCh := make(chan error)
	go func() {
		err := b.ssh.execCmd(command)
		cmdCh <- errors.Trace(err)
	}()
	select {
	case err := <-cmdCh:
		return err
	case <-ctx.Done():
		return ctx.Err()
	}
}

// Name implements Node Name interface.
func (b *awsNode) Name() string {
	return b.name
}

func init() {
	RegisterNode("aws", awsNodeFactory)
}
