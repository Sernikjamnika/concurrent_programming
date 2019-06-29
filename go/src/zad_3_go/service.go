package main 


import (
	"fmt"
)


type Service struct {
	getCrashReport <-chan Report
	getFixReport <-chan Report
	getReadReport <-chan ReadReport
	newTasks []Report
	takenTasks []Report
}

func checkTasks(condition bool, getNextReportChannel <-chan ReadReport) <-chan ReadReport {
	if condition {
		return getNextReportChannel
	}

	return nil
}

func (s *Service) manage() {
	for {
		select {
		case fixReport := <-s.getFixReport:
			for index, value := range s.takenTasks {
				if value.machineIndex == fixReport.machineIndex && value.machineType == fixReport.machineType {
					s.takenTasks = append(s.takenTasks[:index], s.takenTasks[index+1:]...)
					break
				}
			}

		case newReadReport := <-checkTasks(len(s.newTasks) > 0, s.getReadReport):
			newReadReport.report <- s.newTasks[0]
			s.takenTasks = append(s.takenTasks, s.newTasks[0])
			s.newTasks = s.newTasks[1:]

		case newCrashReport := <-s.getCrashReport:
			shouldBeReportAdded := true
			for _, value := range append(s.newTasks, s.takenTasks...) {
				if value.machineIndex == newCrashReport.machineIndex && value.machineType == newCrashReport.machineType{
					shouldBeReportAdded = false
					break
				}
			}

			if shouldBeReportAdded {
				fmt.Printf("[SERVICE] Got crash report of machine %d\n", getMachine(newCrashReport.machineIndex, newCrashReport.machineType).index)
				s.newTasks = append(s.newTasks, newCrashReport)
			}
		}
	}
}

