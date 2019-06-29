package main

import (
	"zad_1_go/config"
)


type Order struct{
	first int
	second int
	operator rune
}

func (o Order) execute() int{
	return config.ArithmeticExpressions[o.operator](o.first, o.second)
}
