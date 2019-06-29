package main


import (
	"fmt"
	"zad_1_go/config"
)


type Warehouse struct{
	products []Product 
	store <-chan Product
	purchase <-chan Purchase
	showProducts chan int
}

func (w *Warehouse)manage(){
	for {
		select {
		case product := <-w.store:
			if len(w.products) < config.WarehouseCapacity {
				w.products = append(w.products, product)
				if config.VerboseMode {
					fmt.Printf("Stored in warehouse %d\n", len(w.products))
				}
			} else if config.VerboseMode{
				fmt.Printf("Warehouse is full %d\n", len(w.products))
			}

		case purchaseOffer := <-w.purchase:
			if len(w.products) > 0{
				purchaseOffer.response <- w.products[0]
				w.products = w.products[1:]
			} else {
				purchaseOffer.response <- Product{}
				if config.VerboseMode {
					fmt.Printf("Warehouse is empty %d\n", len(w.products))

				}
			}
		case <- w.showProducts:
			fmt.Printf("Products in warehouse: ")
			for _, product := range w.products{
				fmt.Printf("%d ", product.value)
			}
			fmt.Printf("\n")
		}
		
	}
}