package main

import (
	"fmt"
	"zad_1_go/config"
)

type TaskDispatcher struct {
	orders []Order
	getOrder <-chan Order
	giveOrder <-chan Request
	showOrders chan int
}


func (t *TaskDispatcher)dispatch(){
	for {
		select {
		case newOrder := <- t.getOrder:
			if len(t.orders) < config.MaxOrders{
				t.orders = append(t.orders, newOrder)
				if config.VerboseMode {
					fmt.Printf("New order has come. Number of orders: %d\n", len(t.orders))
				}
			} else if config.VerboseMode {
				fmt.Println("To many orders!")
			}
		case request := <- t.giveOrder:
			if len(t.orders) > 0{
				request.givenOrder <- t.orders[0]
				t.orders = t.orders[1:]
			} else {
				request.givenOrder <- Order{}
			}
		case <- t.showOrders:
			fmt.Printf("Orders given: ")
			for _, order := range t.orders{
				fmt.Printf("(%d %c %d) ", order.first, order.operator, order.second)
			}
			fmt.Printf("\n")
		}
		
	}
}