package consts is

   -- Sizes
   Task_List_Length: constant Integer := 10;
   Warehouse_Capacity: constant Integer := 10;
   
   -- Delays
   Worker_Delay: constant Duration := 3.5;
   Customer_Delay: constant Duration := 10.0;
   Director_Delay: constant Duration := 1.0;
   Machine_Delay: constant Duration := 3.0;
   Service_Worker_Delay: constant Duration := 1.0;
   
   -- Waiting time
   Impatient_Worker_Waiting_Time: constant Duration := 0.5;
   
   -- Numbers
   Workers_No: constant Integer := 10;
   Customer_No: constant Integer := 2;   
   Adding_Machine_No: constant Integer := 4;
   Multiplying_Machine_No: constant Integer := 3;
   SeviceWorker_No: constant Integer := 3;
   
   -- Verbosity
   Verbose_Mode: constant Boolean := True;
   
   -- Probability
   Machine_Crash_Proba: constant Integer := 12;
   
   
   


end consts;
