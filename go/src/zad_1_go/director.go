package main

import (
	"time"
	"math/rand"
	"zad_1_go/config"
)

// behaves like director
func director(orders chan<- Order){
	operators := []rune {'+', '-', '*'}
	for {
		// add new order to do 
		orders <- Order{first: rand.Intn(10),
						second: rand.Intn(10),
						operator: operators[rand.Intn(len(operators))]}
		time.Sleep(config.DelayDirector)
	}	
}