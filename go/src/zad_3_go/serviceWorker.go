package main

import (
	"fmt"
	"zad_3_go/config"
	"time"
)

type ServiceWorker struct {
	index int
	getReport chan ReadReport
	sendFixReport chan Report
}

func (w *ServiceWorker) work() {

	for {
		nextReportRequest := ReadReport{make(chan Report)}
		w.getReport <- nextReportRequest
		currentReport := <-nextReportRequest.report
		machine := getMachine(currentReport.machineIndex, currentReport.machineType)
		fmt.Printf("[SERVICE WORKER %d] Got the report of machine %d\n", w.index, machine.index)

		time.Sleep(config.DelayServiceWorker)
		if config.VerboseMode {
			fmt.Printf("[SERVICE WORKER %d] Repaired machine index %d\n", w.index, machine.index)
		}
		machine.repairMachine <- true
		w.sendFixReport <- currentReport
	}
}