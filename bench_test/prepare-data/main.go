/*
 * create table order (
 * 	id int(20) not null auto_increment,
 *	user_id int(20)
 *	time datetime,
 *	type int(10),
 *	info varchar(255),
 *	primary key (`id`),
 *	key `time_idx` (`time`),
 * );
 * insert into order(...) values(...)
 */

package main

import (
	"bytes"
	"database/sql"
	"flag"
	"fmt"
	"log"
	"math/rand"
	"time"

	_ "github.com/go-sql-driver/mysql"
)

var (
	host         = flag.String("h", "127.0.0.1", "host address")
	port         = flag.Int("P", 50004, "host port")
	user         = flag.String("u", "root", "set user of the database")
	password     = flag.String("p", "", "set password of the database ")
	dbname       = flag.String("D", "test", "set the default database name")
	rownum       = flag.Int64("R", 10000000, "the row num of table")
	tablename    = flag.String("T", "t_order", "the default table name")
	routineCount = flag.Int64("r", 20, "the routine that insert data concurrently")
)

func createDB() (*sql.DB, error) {
	dbaddr := fmt.Sprintf("%s:%s@tcp(%s:%d)/%s?charset=utf8", *user, *password, *host, *port, *dbname)
	db, err := sql.Open("mysql", dbaddr)
	if err != nil {
		return nil, err
	}
	return db, nil
}

func createTable(db *sql.DB) error {
	sql := fmt.Sprintf(`CREATE TABLE IF NOT EXISTS %s (id INT(20) NOT NULL, user_id INT(20), time DATETIME,
			type INT(10), info VARCHAR(255), PRIMARY KEY (id), KEY time_idx (time))`, *tablename)
	if _, err := db.Exec(sql); err != nil {
		log.Fatal(err)
		return err
	}
	return nil
}

type insertJob struct {
	db        *sql.DB
	idStart   int64
	idEnd     int64
	userIdMax int64
	timeStart int32
	timeEnd   int32
	tableName string
}

func (job *insertJob) run(c chan struct{}) {
	rand.Seed(time.Now().Unix())

	var id = job.idStart
	var count = 0
	var sqlStream bytes.Buffer

	insertSQL := fmt.Sprintf("INSERT INTO %s(id, user_id, time, type, info) values", job.tableName)
	sqlStream.WriteString(insertSQL)
	for id < job.idEnd {
		if sqlStream.Len() == 0 {
			sqlStream.WriteString(insertSQL)
		}

		userId := rand.Int63n(job.userIdMax)
		t := job.timeStart + rand.Int31n(job.timeEnd-job.timeStart)

		format := "2006-01-02 06:04:05"
		sql := fmt.Sprintf("(%d, %d, '%s', %d, '%s')", id, userId, time.Unix(int64(t), 0).Format(format), rand.Int31(),
			"abcdea;sldjf;asjdf;ljhoip80-70598htihgahjgiyqwhgnvhreasdfjnmkrjsgdfhsfdgb")
		sqlStream.WriteString(sql)

		id++
		count++

		// batch
		if count >= 100 {
			count = 0
			if _, err := job.db.Exec(string(sqlStream.Bytes())); err != nil {
				log.Fatal(err)
			}
			sqlStream.Reset()
		} else if id < job.idEnd {
			sqlStream.WriteString(",")
		}
	}

	// last batch
	if count > 0 {
		if _, err := job.db.Exec(string(sqlStream.Bytes())); err != nil {
			log.Fatal(err)
		}
	}

	c <- struct{}{}
}

func main() {
	flag.Parse()
	// connect to db
	db, err := createDB()
	if err != nil {
		log.Fatal(err)
	}

	// create table
	createTable(db)

	// insert date
	c := make(chan struct{})
	var i int64
	for i = 0; i < *routineCount; i++ {
		batchSize := *rownum / *routineCount

		job := insertJob{
			db:        db,
			idStart:   i * batchSize,
			idEnd:     (i + 1) * batchSize,
			userIdMax: 999999,
			timeStart: 1475309185, /* 2016-10-01 16:06:25 */
			timeEnd:   1476173185, /* 2016-10-11 16:06:25 */
			tableName: *tablename,
		}
		go job.run(c)
	}

	// waiting for all insert job finished
	var finishedJob int64 = 0
	for finishedJob < *routineCount {
		<-c
		finishedJob++
	}

	log.Println("finished all insert jobs")
}
