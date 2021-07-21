package main

import (
	"context"
	"fmt"
	"os"

	"github.com/sjansen/panopticon/internal/build"
	"github.com/sjansen/panopticon/internal/server"
)

func main() {
	fmt.Println("GitSHA:", build.GitSHA)
	fmt.Println("Timestamp:", build.Timestamp)

	fmt.Println("Starting server...")
	ctx := context.Background()
	s, err := server.New(ctx)
	if err != nil {
		fmt.Fprintln(os.Stderr, err.Error())
		os.Exit(1)
	}

	if os.Getenv("AWS_LAMBDA_RUNTIME_API") == "" {
		err = s.ListenAndServe()
		if err != nil {
			fmt.Fprintln(os.Stderr, err.Error())
			os.Exit(1)
		}
	} else {
		s.StartLambdaHandler()
	}
}
