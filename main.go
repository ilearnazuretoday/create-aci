package main

import (
	"fmt"
	"io"
	"net/http"
)

func main() {
	http.HandleFunc("/version", VersionHandler)
	fmt.Println("listening on port 8080...")
	fmt.Println("go to: http://localhost:8080/version")
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		panic(err)
	}
}

func VersionHandler(res http.ResponseWriter, req *http.Request) {
	res.WriteHeader(http.StatusOK)
	res.Header().Set("Content-Type", "application/json")
	io.WriteString(res, `{"version": v1.0}`)
}
