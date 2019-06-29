package main


import (
	"bufio"
	"os"
	"fmt"
)

func cli(dispatcher *TaskDispatcher, warehouse *Warehouse){
	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan(){
		switch scanner.Text(){
		case "w":
			warehouse.showProducts <- 0
		case "t":
			dispatcher.showOrders <- 0
		case "exit":
			return
		default:
			fmt.Println("There is no such command")
		}
	}
}
