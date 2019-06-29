package main

import (
	"fmt"
	"zad_2_go/config"
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
		case newOrder := <- maybeNewOrder(t.orders, t.getOrder):
			t.orders = append(t.orders, newOrder)
		case request := <- maybeGiveOrder(t.orders, t.giveOrder):
			request.givenOrder <- t.orders[0]
			t.orders = t.orders[1:]
		case <- t.showOrders:
			fmt.Printf("[TASK DISPATCHER] Orders given: ")
			for _, order := range t.orders{
				fmt.Printf("(%d %c %d) ", order.first, order.operator, order.second)
			}
			fmt.Printf("\n")
		}
		
	}
}

func maybeNewOrder(orders []Order, getOrder <-chan Order) <-chan Order{
	if len(orders) < config.MaxOrders{
		if config.VerboseMode {
			fmt.Printf("[TASK DISPATCHER] New order has come. Number of orders: %d\n", len(orders))
		}
		return getOrder
	} 
	if config.VerboseMode {
		fmt.Println("[TASK DISPATCHER] To many orders!")
	}
	return nil
}

func maybeGiveOrder(orders []Order, giveOrder <-chan Request) <-chan Request{
	if len(orders) > 0{
		return giveOrder
	} 
	return nil
}
