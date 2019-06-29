package config

import "time"


var ArithmeticExpressions = map[rune] func(int, int) int{
	'+': func (a, b int) int {return a + b},
	'*': func (a, b int) int {return a * b},
}

// delays
var DelayWorker time.Duration = 3000 * time.Millisecond
var DelayDirector time.Duration = 500 * time.Millisecond
var DelayCustomer time.Duration = 4000 * time.Millisecond
var DelayMachine time.Duration = 10000 * time.Millisecond
var DelayWaitingWroker time.Duration = 2000 * time.Millisecond

// orders settings
var MaxOrders = 10

// warehouse settings
var WarehouseCapacity = 5

// workers settings
var NoWorkers = 15

// customer settings
var NoCustomers = 1

// verbose mode
var VerboseMode = false

// machine settings
var NoAddingMachines = 2
var NoMulitplyingMachines = 3