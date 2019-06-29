package main


import (
	"fmt"
	"zad_2_go/config"
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
		case product := <-maybeStore(w.products, w.store):
			w.products = append(w.products, product)
		case purchaseOffer := <-maybePurchase(w.products, w.purchase):
			purchaseOffer.response <- w.products[0]
			w.products = w.products[1:]
		case <- w.showProducts:
			fmt.Printf("[WAREHOUSE] Products in warehouse: ")
			for _, product := range w.products{
				fmt.Printf("%d ", product.value)
			}
			fmt.Printf("\n")
		}	
	}
}

func maybeStore(products []Product, store <-chan Product) <-chan Product {
	if len(products) < config.WarehouseCapacity {
		if config.VerboseMode {
			fmt.Printf("[WAREHOUSE] Number of stored products: %d\n", len(products))
		}
		return store
	} else {
		if config.VerboseMode{
			fmt.Printf("[WAREHOUSE] Warehouse is full %d\n", len(products))
		}
		return nil
	}
}

func maybePurchase(products []Product, purchase <-chan Purchase) <-chan Purchase{
	if len(products) > 0 {
		return purchase;
	} else {
		if config.VerboseMode {
			fmt.Printf("[WAREHOUSE] Warehouse is empty %d\n", len(products))
		}
		return nil
	}

}