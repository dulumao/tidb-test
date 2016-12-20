// Copyright 2015 PingCAP, Inc.
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
	"database/sql"
	"flag"
	"fmt"
	"log"

	_ "github.com/go-sql-driver/mysql"
)

var (
	totalTable = flag.Int("n", 30000, "Number of table")
	host       = flag.String("h", "127.0.0.1", "host")
	port       = flag.Int("P", 4001, "port")
	user       = flag.String("u", "root", "username")
	password   = flag.String("p", "", "password")
)

func openDB() (*sql.DB, error) {
	dbDSN := fmt.Sprintf("%s:%s@tcp(%s:%d)/test", *user, *password, *host, *port)
	db, err := sql.Open("mysql", dbDSN)
	if err != nil {
		return nil, err
	}
	return db, nil
}

func mustExec(db *sql.DB, query string, args ...interface{}) {
	_, err := db.Exec(query, args...)
	if err != nil {
		log.Fatal(err)
	}
}

func createTable(db *sql.DB) {
	for tid := 1; tid <= *totalTable; tid++ {
		tableName := fmt.Sprintf("t_%d", tid)

		query := fmt.Sprintf("CREATE TABLE IF NOT EXISTS %s (auto_id int(11) NOT NULL AUTO_INCREMENT,match_id  int(11) NOT NULL,role_id  bigint(20) NOT NULL DEFAULT '0', mobile  varchar(32) NOT NULL DEFAULT '',PRIMARY KEY(auto_id))", tableName)
		mustExec(db, query)

		query = fmt.Sprintf("INSERT INTO %s (match_id,role_id,mobile) VALUES(1,1,'18618328982')", tableName)
		mustExec(db, query)
	}
}

func main() {
	flag.Parse()

	db, err := openDB()
	if err != nil {
		log.Fatal(err)
	}

	createTable(db)

	db.Close()
}
