package main

import (
	"zad_2_go/config"
	"math/rand"
)

var AddingMachines []*Machine
var MultiplyingMachines []*Machine
var Workers []*Worker

func getMachine(index int, operator rune) *Machine {
	if operator == '+' {
		return AddingMachines[index]
	} else {
		return MultiplyingMachines[index]
	}
}

func nextMachine(index int, operator rune) int {
	if operator == '+' {
		return (index + 1) % config.NoAddingMachines
	} else {
		return (index + 1) % config.NoMulitplyingMachines
	}
}



func main(){
	dispatcherChannel := make(chan Order)
	workersChannel := make(chan Request)
	storeProductChannel := make(chan Product)
	customersChannel := make(chan Purchase)

	// create machines
	for i := 0; i < config.NoAddingMachines; i++ {
		machine := &Machine{receiveTask: make(chan MachineRequest),
							rejection:make(chan bool),
							index: i}
		AddingMachines = append(AddingMachines, machine)
		go machine.work()
	}

	for i := 0; i < config.NoMulitplyingMachines; i++ {
		machine := &Machine{receiveTask: make(chan MachineRequest),
			rejection:make(chan bool),
			index: i + config.NoAddingMachines}
		MultiplyingMachines = append(MultiplyingMachines, machine)
		go machine.work()
	}

	// "hire" workers
	for i := 0; i < config.NoWorkers; i++ {
		impatient :=  []bool {true, false}[rand.Intn(2)]
		worker := &Worker{index: i,
						  dispatcher: workersChannel,
						  warehouse: storeProductChannel,
						  impatient: impatient}
		Workers = append(Workers, worker)
		go worker.work()
	}

	// "find" customers
	for i:=0; i < config.NoCustomers; i++ {
		customer := &Customer{index: i, warehouse: customersChannel}
		go customer.buy()
	}

	// build warehouse
	warehouse := &Warehouse{products: []Product{},
							store: storeProductChannel,
							purchase: customersChannel,
							showProducts: make(chan int)}

	// create task dispatcher
	dispatcher := &TaskDispatcher{orders: []Order{}, 
								  getOrder: dispatcherChannel, 
								  giveOrder: workersChannel,
								  showOrders: make(chan int)}

	
	go warehouse.manage()
	go director(dispatcherChannel)
	if config.VerboseMode {
		dispatcher.dispatch()
	} else {
		go dispatcher.dispatch()
		cli(dispatcher, warehouse)

	}
}

