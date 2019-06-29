package main 


type Report struct {
	machineType  rune
	machineIndex int
}

type ReadReport struct { 
	report chan Report
}