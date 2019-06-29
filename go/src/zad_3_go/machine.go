package main

import (
	"zad_3_go/config"
	"fmt"
	"time"
	"math/rand"
)

type MachineRequest struct {
	task *Order
	returnProduct chan *Order
	received chan bool
}

type Machine struct {
	receiveTask chan MachineRequest
	repairMachine chan bool
	rejection chan bool
	index int
	isBroken bool
}

func (m *Machine) work(){
	var request MachineRequest
	for {
		
		// check if machine did not break
		if !m.isBroken {
			m.crash()
			if m.isBroken && config.VerboseMode {
				fmt.Printf("[MACHINE %d] Has crashed\n", m.index)
			}
		}

		select {

		// machine repairement has been done
		case <- m.repairMachine:
			m.isBroken = false
			if config.VerboseMode {
				fmt.Printf("[MACHINE %d] Repaired\n", m.index)
			}

		// get request
		case request = <- m.receiveTask:
			if m.isBroken {
				time.Sleep(config.DelayMachine)
				request.returnProduct <- nil
			} else {
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
	}
}

func (m *Machine) crash() {
	if rand.Intn(10) < config.CrashProba {
		m.isBroken = true
	} else {
		m.isBroken = false
	}
}

