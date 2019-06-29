package main

import (
	"zad_2_go/config"
	"fmt"
	"time"
)

type MachineRequest struct {
	task *Order
	returnProduct chan *Order
	received chan bool
}

type Machine struct {
	receiveTask chan MachineRequest
	rejection chan bool
	index int
}

func (m * Machine) work(){
	var request MachineRequest
	for {
		// get request
		request = <- m.receiveTask
		if config.VerboseMode {
			fmt.Printf("[MACHINE %d] Received task (%d %c %d)\n",
						m.index,
						request.task.first,
						request.task.operator,
						request.task.second)
		}
					
		// execute request for amount of time
		request.task.execute()
		time.Sleep(config.DelayMachine)
		if config.VerboseMode {
			fmt.Printf("[MACHINE %d] Sending product with result: %d\n", m.index, request.task.result)
		}
		// return product
		request.returnProduct <- request.task
	}
}

