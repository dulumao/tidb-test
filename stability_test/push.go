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

package main

import (
	"time"

	"github.com/ngaut/log"
	"github.com/pingcap/tidb-test/stability_test/config"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/push"
)

const zeroDuration = time.Duration(0)

// pushPrometheus pushes metrics to Prometheus Pushgateway.
func pushPrometheus(job, addr string, interval time.Duration) {
	for {
		err := push.FromGatherer(
			job, push.HostnameGroupingKey(),
			addr,
			prometheus.DefaultGatherer,
		)
		if err != nil {
			log.Errorf("could not push metrics to Prometheus Pushgateway: %v", err)
		}

		time.Sleep(interval)
	}
}

// PushMetrics pushs metircs in background.
func PushMetrics(cfg *config.Config) {
	metirc := cfg.Metric
	if metirc.Interval.Duration == zeroDuration || len(metirc.Address) == 0 {
		log.Info("disable Prometheus push client")
		return
	}

	log.Info("start Prometheus push client")

	interval := metirc.Interval.Duration
	go pushPrometheus(metirc.Job, metirc.Address, interval)
}
