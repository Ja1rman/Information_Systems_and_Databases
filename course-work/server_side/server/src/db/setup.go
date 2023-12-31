package db

import (
	"database/sql"
	"fmt"

	_"github.com/lib/pq"
)


const (
	host = "api-postgres"
	port = 5432
	user = "course_work"
	password = "course_work"
	dbname = "course_work"
)


func Conn() (*sql.DB, error) {
    psqlInfo := fmt.Sprintf("host=%s port=%d user=%s "+
    "password=%s dbname=%s sslmode=disable",
    host, port, user, password, dbname)
    db, err := sql.Open("postgres", psqlInfo)
    if err != nil {
        return nil, err
    }
    
    err = db.Ping()
    if err != nil {
        return nil, err
    }
    return db, nil
}

