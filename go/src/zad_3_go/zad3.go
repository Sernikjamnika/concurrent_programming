package main

import (
	"zad_3_go/config"
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
	reportCrashChannel := make(chan Report)
	getReportChannel := make(chan ReadReport)
	reportFixedChannel := make(chan Report)

	// create machines
	for i := 0; i < config.NoAddingMachines; i++ {
		machine := &Machine{receiveTask: make(chan MachineRequest),
							repairMachine: make(chan bool),
							rejection: make(chan bool),
							index: i,
							isBroken: false}

		AddingMachines = append(AddingMachines, machine)
		go machine.work()
	}
	
	for i := 0; i < config.NoMulitplyingMachines; i++ {
		machine := &Machine{receiveTask: make(chan MachineRequest),
							rejection: make(chan bool),
							repairMachine: make(chan bool),
							isBroken: false,
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
						  impatient: impatient,
						  crashReport: reportCrashChannel}
		Workers = append(Workers, worker)
		go worker.work()
	}

	// "find" customers
	for i := 0; i < config.NoCustomers; i++ {
		customer := &Customer{index: i, warehouse: customersChannel}
		go customer.buy()
	}

	// "hire" service workers
	for i := 0; i < config.NoServiceWorker; i++ {
		serviceWorker := &ServiceWorker{index: i,
										getReport: getReportChannel,
										sendFixReport: reportFixedChannel}
		go serviceWorker.work()
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
	
	service := &Service{getCrashReport: reportCrashChannel,
						getFixReport: reportFixedChannel,
						getReadReport: getReportChannel,
						newTasks: []Report{},
					    takenTasks: []Report{}}
	
	go warehouse.manage()
	go director(dispatcherChannel)
	go service.manage()
	if config.VerboseMode {
		dispatcher.dispatch()
	} else {
		go dispatcher.dispatch()
		cli(dispatcher, warehouse)

	}
}

