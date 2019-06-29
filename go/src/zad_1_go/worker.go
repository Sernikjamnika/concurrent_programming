package main

import (
	"time"
	"fmt"
	"zad_1_go/config"
)

type Worker struct {
	index int
	dispatcher chan<- Request
	warehouse chan<- Product
}


func (w *Worker)work(){
	for {
		// request for job 
		request := Request{givenOrder: make(chan Order)}
		w.dispatcher <- request
		// get order
		order := <- request.givenOrder
		if order != (Order{}) {
			// execute order
			result := order.execute()
			if config.VerboseMode {
				fmt.Printf("Worker %d executed order with result %d\n", w.index, result)
			}
			// put result in warehouse
			w.warehouse <- Product{value: result}
		}
		time.Sleep(config.DelayWorker)
	}
}