package main

import (
	"time"
	"fmt"
	"zad_3_go/config"
)

type Purchase struct{
	response chan Product
}

type Customer struct {
	index int
	warehouse chan<- Purchase
}

type Product struct{
	value int
}

func (c *Customer)buy(){
	for {
		purchase := Purchase{response: make(chan Product)}
		c.warehouse <- purchase
		item := <-purchase.response
		if item != (Product{}) && config.VerboseMode {
			fmt.Printf("[CUSTOMER %d] bought item %d\n", c.index, item.value)
		}
		time.Sleep(config.DelayCustomer)
	}
}
