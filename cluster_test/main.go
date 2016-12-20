package main

import (
	"database/sql"
	"flag"
	"fmt"
	"math/rand"
	"os"
	"os/signal"
	"strings"
	"sync"
	"sync/atomic"
	"syscall"
	"time"

	_ "github.com/go-sql-driver/mysql"
	"github.com/juju/errors"
	"github.com/ngaut/log"
	"github.com/pingcap/tidb-test/cluster_test/pkg/cluster"
	"github.com/pingcap/tidb-test/cluster_test/pkg/nemesis"
	"github.com/pingcap/tidb-test/cluster_test/pkg/suite"
)

var (
	composeFile = flag.String("compose-file", "./docker/docker-compose.yml", "Cluster docker compose file")
	projectName = flag.String("project", "cluster_test", "Docker compose project name")
	autoDestory = flag.Bool("auto-destory", false, "If true, destroy the docker cluster after test successfully finished")
	host        = flag.String("host", "127.0.0.1", "Host")
	password    = flag.String("pass", "", "MySQL password")
	logLevel    = flag.String("L", "info", "Log level")

	count = flag.Uint64("count", 10000000, "Total test loop count")

	filterPd   = flag.Bool("filter-pd", false, "Don't disturb pd")
	filterTikv = flag.Bool("filter-tikv", false, "Don't disturb tikv")
	filterTiDB = flag.Bool("filter-tidb", false, "Don't disturb tidb")

	randomKill = flag.Bool("random-kill", true, "Random kill one or multi services")

	testSingleTrans = flag.Bool("test-single-trans", true, "Test single transfer case")
	testMultiTrans  = flag.Bool("test-multi-trans", true, "Test multi transfer case")
	testBlockWrite  = flag.Bool("test-block-write", true, "Test block write case")

	dozeTime = flag.Int64("doze-time", 30, "Sleep time (seconds) after cluster up")
)

var (
	services = [][]string{
		[]string{"pd1", "pd2", "pd3"},
		[]string{"tikv1", "tikv2", "tikv3"},
		[]string{"tidb1", "tidb2", "tidb3"},
	}
)

func registerCases(s *suite.Suite) {
	if *testSingleTrans {
		s.Register(suite.NewSimpleTransferCase(1, 2))
	}

	if *testMultiTrans {
		s.Register(suite.NewMultiTransferCase(999, 5, 999))
	}

	if *testBlockWrite {
		s.Register(suite.NewBlockWriterCase(5, 256, 1024))
	}
}

func registerNemesises(nc *nemesisClient) {
	if *randomKill {
		nc.Register(&nemesis.KillNemesis{WaitTime: time.Duration(*dozeTime) * time.Second})
	}
}

func main() {
	flag.Parse()

	log.SetLevelByString(*logLevel)

	c := cluster.NewCluster(*composeFile, *projectName)
	err := c.Create()
	if err != nil {
		log.Fatal(err)
	}

	defer func() {
		if *autoDestory {
			c.Destroy()
		}
	}()

	time.Sleep(time.Duration(*dozeTime) * time.Second)
	checkAllUp(c)

	port, err := c.Port("haproxy", 4000)
	if err != nil {
		log.Fatal(err)
	}

	db, err := openDB(port)
	if err != nil {
		log.Fatal("connect to db failed, abort!")
	}
	defer db.Close()

	sc := make(chan os.Signal, 1)
	signal.Notify(sc,
		syscall.SIGHUP,
		syscall.SIGINT,
		syscall.SIGTERM,
		syscall.SIGQUIT)

	quited := int64(0)
	nc := newNemesisClient()

	go func() {
		sig := <-sc
		log.Warnf("receive signal %d, closing", sig)
		nc.Close()
		atomic.StoreInt64(&quited, 1)
	}()

	s := suite.NewSuite()
	registerCases(s)

	if err := s.SetUp(db); err != nil {
		log.Fatalf("suite sets up failed %v", err)
	}

	registerNemesises(nc)

	nc.wg.Add(1)
	go nc.Run(c)

	start := time.Now()
	i := uint64(0)

	last := start
	for i = 1; i <= *count && atomic.LoadInt64(&quited) == 0; i++ {
		s.Execute(db)

		if i%1000 == 0 {
			now := time.Now()
			fmt.Printf("Run test, loop %d, cost %s\n", i, now.Sub(last))
			s.Output()
			fmt.Println("--------------------------------------")
			last = now
		}
	}

	log.Infof("test over")

	// Try to quit nemesis and up all services than do TearDown.
	nc.Close()
	checkAllUp(c)

	if err := s.TearDown(db); err != nil {
		log.Errorf("suite tears down failed %v", err)
	}

	fmt.Printf("Finish test, loop %d, cost %s\n", i, time.Now().Sub(start))
	s.Output()
}

func shuffle(a []int) {
	for i := range a {
		j := rand.Intn(i + 1)
		a[i], a[j] = a[j], a[i]
	}
}

type nemesisClient struct {
	sync.Mutex

	ns      []nemesis.Nemesis
	running bool
	wg      sync.WaitGroup
	quit    chan struct{}
}

func newNemesisClient() *nemesisClient {
	nc := &nemesisClient{
		ns:      make([]nemesis.Nemesis, 0),
		quit:    make(chan struct{}, 1),
		running: false,
	}

	return nc
}

func (nc *nemesisClient) Register(n nemesis.Nemesis) {
	nc.ns = append(nc.ns, n)
}

func (nc *nemesisClient) Close() {
	nc.Lock()
	defer nc.Unlock()
	if !nc.running {
		return
	}

	close(nc.quit)
	nc.wg.Wait()
	nc.running = false
}

func (nc *nemesisClient) Run(c *cluster.Cluster) {
	defer nc.wg.Done()

	nc.running = true

	groupIndices := make([]int, 0, len(services))
	for i := 0; i < len(services); i++ {
		name := services[i][0]
		if (*filterPd && strings.HasPrefix(name, "pd")) ||
			(*filterTikv && strings.HasPrefix(name, "tikv")) ||
			(*filterTiDB && strings.HasPrefix(name, "tidb")) {
			continue
		}

		groupIndices = append(groupIndices, i)
	}

	nextNemesis := 0
	for {
		select {
		case <-time.After(time.Duration(*dozeTime) * time.Second):
			checkAllUp(c)

			if len(groupIndices) == 0 || len(nc.ns) == 0 {
				continue
			}

			// random select some service groups first.
			count := rand.Intn(len(groupIndices)) + 1
			shuffle(groupIndices)

			names := make([]string, 0, count)
			for i := 0; i < count; i++ {
				service := services[groupIndices[i]]
				name := service[rand.Intn(len(service))]
				names = append(names, name)
			}

			// Use a nemesis
			n := nc.ns[nextNemesis]

			log.Infof("execute nemeis %s for %v", n, names)
			if err := n.Execute(c, names...); err != nil {
				log.Errorf("execute nemesis %s failed %v", n, err)
			}
			nextNemesis = (nextNemesis + 1) % len(nc.ns)
		case <-nc.quit:
			return
		}
	}
}

func checkAllUp(c *cluster.Cluster) {
	for i := 0; i < len(services); i++ {
		for j := 0; j < len(services[i]); j++ {
			name := services[i][j]
			state, err := c.State(name)
			if err != nil {
				log.Errorf("get %s state err %v", name, err)
			}

			if state == "up" {
				continue
			}

			log.Errorf("%s is not up, but %s, try to start", name, state)
			c.Start(name)
			time.Sleep(time.Duration(*dozeTime) * time.Second)
		}
	}
}

func openDB(port uint16) (db *sql.DB, err error) {
	for retry := 0; retry < 10; retry++ {
		db, err = sql.Open("mysql", fmt.Sprintf("root:%s@(%s:%d)/test", *password, *host, port))
		if err == nil {
			var i int
			err = db.QueryRow("select 1").Scan(&i)
			if err == nil {
				if i == 1 {
					// correct
					return
				}
				err = errors.Errorf("execute query `select 1`, expect: 1, but: %d", i)
			}
			db.Close()
		}
		log.Warnf("connect to db failed %v, after %d times retry", err, retry)
		time.Sleep(3 * time.Second)
	}

	return
}
