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
	"net"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"

	"github.com/juju/errors"
	"github.com/ngaut/log"
)

// Cluster manages whole cluster using docker-compose command.
type Cluster struct {
	ComposeFile string
	ProjectName string
}

// NewCluster creates the cluster using docker-compose for management.
func NewCluster(composeFile string, projectName string) *Cluster {
	var err error
	composeFile, err = filepath.Abs(composeFile)
	if err != nil {
		panic(err)
	}

	c := &Cluster{
		ComposeFile: composeFile,
		ProjectName: projectName,
	}

	return c
}

func (c *Cluster) createCommand(command string, cmdArgs ...string) *exec.Cmd {
	args := []string{
		"-f", c.ComposeFile,
		"-p", c.ProjectName,
		command,
	}

	args = append(args, cmdArgs...)

	log.Debugf("run [%s %s] for %s", command, strings.Join(cmdArgs, " "), c.ProjectName)

	cmd := exec.Command("docker-compose", args...)
	return cmd
}

func (c *Cluster) execute(command string, cmdArgs ...string) error {
	cmd := c.createCommand(command, cmdArgs...)
	return errors.Trace(cmd.Run())
}

// Create creates the cluster and starts.
func (c *Cluster) Create() error {
	return c.execute("up", "-d")
}

// Destroy destroys the cluster.
func (c *Cluster) Destroy() error {
	return c.execute("down")
}

// Start starts services.
func (c *Cluster) Start(names ...string) error {
	return c.execute("start", names...)
}

// Stop stops services.
func (c *Cluster) Stop(names ...string) error {
	return c.execute("stop", names...)
}

// Kill kills services
func (c *Cluster) Kill(names ...string) error {

	return c.execute("kill", names...)
}

// Pause pauses services
func (c *Cluster) Pause(names ...string) error {
	return c.execute("pause", names...)
}

// UnPause unpauses services.
func (c *Cluster) UnPause(names ...string) error {
	return c.execute("unpause", names...)
}

// Port returns the public port for a port binding.
func (c *Cluster) Port(name string, privatePort uint16) (uint16, error) {
	output, err := c.createCommand("port", name, strconv.FormatUint(uint64(privatePort), 10)).Output()
	if err != nil {
		return 0, errors.Trace(err)
	}

	if output == nil {
		return 0, errors.New("no public port")
	}

	_, portStr, err := net.SplitHostPort(string(output))
	if err != nil {
		return 0, errors.Trace(err)
	}

	port, err := strconv.ParseUint(strings.TrimSpace(portStr), 10, 16)
	if err != nil {
		return 0, errors.Trace(err)
	}

	return uint16(port), nil
}

// State returns the state for the service, up|paused|exit
func (c *Cluster) State(name string) (string, error) {
	output, err := c.createCommand("ps", name).Output()
	if err != nil {
		return "", errors.Trace(err)
	}

	if output == nil {
		return "", errors.New("no state")
	}

	// get the state for ps output.
	seps := strings.Split(string(output), "\n")
	if len(seps) < 3 {
		return "", errors.Errorf("invalid ps out %q", output)
	}

	// For our case, the command and state is separated by ...
	seps = strings.Split(seps[2], "...")
	if len(seps) < 2 {
		return "", errors.Errorf("invalid ps out %q", output)
	}

	seps = strings.Fields(seps[1])

	return strings.ToLower(strings.TrimSpace(seps[0])), nil
}
