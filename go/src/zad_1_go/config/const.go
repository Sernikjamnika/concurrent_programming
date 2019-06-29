package config

import "time"


var ArithmeticExpressions = map[rune] func(int, int) int{
	'+': func (a, b int) int {return a + b},
	'-': func (a, b int) int {return a - b},
	'*': func (a, b int) int {return a * b},
}

// delays
var DelayWorker time.Duration = 4000 * time.Millisecond
var DelayDirector time.Duration = 2000 * time.Millisecond
var DelayCustomer time.Duration = 4000 * time.Millisecond

// orders settings
var MaxOrders = 10

// warehouse settings
var WarehouseCapacity = 5

//workers settings
var NoWorkers = 10

//customer settings
var NoCustomers = 1

//verbose mode
var VerboseMode = true
