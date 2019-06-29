package main

import (
	"time"
	"fmt"
	"zad_2_go/config"
	"math/rand"
)

type Worker struct {
	index int
	impatient bool
	tasksDone int
	dispatcher chan<- Request
	machine chan<- Order
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
			machineRequest := MachineRequest{&order, make(chan *Order), make(chan bool)}
			index := getRandomMachine(order.operator)
			machine := getMachine(index, order.operator)
			if w.impatient {
				Loop: 
				for {
					select {
					case machine.receiveTask <- machineRequest:
						if config.VerboseMode {
							fmt.Printf("[WORKER %d] Put task to machine\n", w.index)
						}
						break Loop
					case <-time.After(config.DelayWaitingWroker):
						if config.VerboseMode {
							fmt.Printf("[WORKER %d] REJECTED\n", w.index)
						}
						index = nextMachine(index, order.operator)
						if config.VerboseMode {
							fmt.Printf("[WORKER %d] changed machine to %d\n", w.index, index)
						}
					}
				}
			} else {
				machine.receiveTask <- machineRequest
			}
			product := <- machineRequest.returnProduct
			w.tasksDone += 1
			if config.VerboseMode {
				fmt.Printf("[WORKER %d] executed order (%d %c %d) with result %d\n", w.index, order.first, order.operator, order.second, order.result)
			}
			// put result in warehouse
			w.warehouse <- Product{value: product.result}
		}
		time.Sleep(config.DelayWorker)
	}
}

func getRandomMachine(operator rune) int {
	if operator == '+' {
		return rand.Intn(config.NoAddingMachines)
	} else {
		return rand.Intn(config.NoMulitplyingMachines)
	}
}
