package main

import (
	"zad_1_go/config"
)

func main(){
	dispatcherChannel := make(chan Order)
	workersChannel := make(chan Request)
	storeProductChannel := make(chan Product)
	customersChannel := make(chan Purchase)
	
	for i := 0; i < config.NoWorkers; i++{
		worker := &Worker{index: i, dispatcher: workersChannel, warehouse: storeProductChannel}
		go worker.work()
	}
	for i:=0; i < config.NoCustomers; i++{
		customer := &Customer{index: i, warehouse: customersChannel}
		go customer.buy()
	}

	warehouse := &Warehouse{products: []Product{},
							store: storeProductChannel,
							purchase: customersChannel,
							showProducts: make(chan int)}
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

