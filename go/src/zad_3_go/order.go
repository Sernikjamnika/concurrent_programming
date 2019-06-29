package main

import (
	"zad_3_go/config"
)


type Order struct{
	first int
	second int
	operator rune
	result int
}

func (o *Order) execute(){
	o.result = config.ArithmeticExpressions[o.operator](o.first, o.second)
}
