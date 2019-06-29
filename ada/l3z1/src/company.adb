with Ada.Numerics.Discrete_Random;
with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Containers;
use Ada.Containers;
with Ada.Containers.Vectors;
with Consts;

package body Company is

   procedure Simulate_Company is

      -- random generators
      Impatience : array (0 .. 1) of Boolean := (True, False);
      subtype Impatience_Range is Integer range 0 .. 1;
      package Impatience_Random is new Ada.Numerics.Discrete_Random (Impatience_Range);
      Impatience_Generator : Impatience_Random.Generator;


      subtype Crash_Range is Integer range 0 .. 10;
      package Crash_Random is new Ada.Numerics.Discrete_Random (Crash_Range);
      Crash_Generator : Crash_Random.Generator;

      -- Container
      package Reports_List is new Ada.Containers.Vectors
        (Index_Type  => Natural,
         Element_Type => Report);
      use Reports_List;


      -- Definitions

      task type Director;
      task type Customer (Id: Integer);
      task type Worker (Id: Integer := 0; Impatient: Boolean := False);
      task type Machine (Id: Integer) is
         entry Get_Task (O: in Order);
         entry Give_Product (O: out Order);
         entry Rejection;
         entry Fix;
      end Machine;
      task type Service_Worker(Id: Integer);


      type Worker_Pointer is access Worker;
      type Customer_Pointer is access Customer;
      type Machine_Pointer is access Machine;
      type Service_Worker_Pointer is access Service_Worker;
      type Worker_Data is array (Integer range<>) of Worker_Pointer;
      type Statistics is array (Integer range<>) of Integer;



      protected type Task_Scheduler is
         entry Add_Element (New_Task : in Order);
         entry Take_Element (Given_Task: out Order);
         procedure Print_Tasks;
      private
         Tasks: Orders(0 .. Consts.Task_List_Length);
         Index: Integer := 0;
      end Task_Scheduler;


      protected type Warehouse_Manager is
         entry Add_Element (Product: in Integer);
         entry Take_Element (Purchased_Product: out Integer);
         procedure Print_Warehouse_Products;
      private
         Products: Warehouse_Products(0 .. Consts.Warehouse_Capacity);
         Index: Integer := 0;
      end Warehouse_Manager;


      protected type Worker_Manager is
         procedure Add_Done_Task (Index: in Integer);
         procedure Print_Worker_Data;
         procedure Add_Worker(Index: in Integer; Worker: Worker_Pointer);
      private
         Workers: Worker_Data(1 .. Consts.Workers_No);
         Tasks_Done: Statistics(1 .. Consts.Workers_No) := (others => 0);

      end Worker_Manager;


      protected type Service_Manager is
         entry Get_Crash_Report(Crash_Report : in Report);
         entry Give_Fix_Order(Fix_Order : out Report);
         entry Get_Fix_Report(Fix_Report : in Report);
         function Report_Exists(V : Reports_List.Vector; R : Report) return Boolean;
         function Get_Index(V : Reports_List.Vector; R : Report) return Natural;
      private
         To_Fix : Reports_List.Vector;
         In_Fixing : Reports_List.Vector;
         Index : Natural;
      end Service_Manager;

      -- Bodies
      protected body Warehouse_Manager is

         entry Add_Element (Product: in Integer)
           when Index < Consts.Warehouse_Capacity is
         begin
            Products(Index) := Product;
            Index := Index + 1;
            if Consts.Verbose_Mode then
               Put_Line("[WAREHOUSE] Got product. #Products in warehouse: " & Index'Image);
            end if;
         end Add_Element;

         entry Take_Element (Purchased_Product : out Integer)
           when Index > 0 is
         begin
            Index := Index - 1;
            Purchased_Product := Products(Index);
            if Consts.Verbose_Mode then
               Put_Line("[WAREHOUSE] Customer bought product. #Products in warehouse: " & Index'Image);
            end if;
         end Take_Element;

         procedure Print_Warehouse_Products is
         begin
            for I in 0 .. Index - 1 loop
               Put(Products(I)'Image & " ");
            end loop;
            Put_Line("");
         end Print_Warehouse_Products;

      end Warehouse_Manager;


      protected body Task_Scheduler is
         entry Add_Element (New_Task : in Order)
           when Index < Consts.Task_List_Length is
         begin
            Tasks(Index) := New_Task;
            Index := Index + 1;
            if Consts.Verbose_Mode then
               Put("[DIRECTOR] NEW TASK ( " & New_Task.First'Image & " " & New_Task.Operator & " " & New_Task.Second'Image & " ) ");
               Put_Line("Lenght of tasks: " & Index'Image);
            end if;
         end Add_Element;

         entry Take_Element (Given_Task: out Order)
           when Index > 0 is
         begin
            Index := Index - 1;
            Given_Task := Tasks(Index);
            if Consts.Verbose_Mode then
               Put_Line("[DIRECTOR] Worker has taken a task. Lenght of tasks: " & Index'Image);
            end if;
         end Take_Element;

         procedure Print_Tasks is
         begin
            for I in 0 .. Index - 1 loop
               Put("( " & Tasks(I).First'Image & " " & Tasks(I).Operator & " " & Tasks(I).Second'Image & " )");
            end loop;
            Put_Line("");
         end Print_Tasks;

      end Task_Scheduler;


      protected body Worker_Manager is
         procedure Add_Done_Task (Index : in Integer) is
         begin
            Tasks_Done(Index) := Tasks_Done(Index) + 1;
         end Add_Done_Task;

         procedure Print_Worker_Data is
            Worker : Worker_Pointer;
         begin
            for I in 1 .. Consts.Workers_No loop
               Worker := Workers(I);
                 Put_Line("Worker " & Worker.Id'Image & " | Impatience " & Worker.Impatient'Image & " | Tasks Done " & Tasks_Done(I)'Image);
            end loop;

         end Print_Worker_Data;

         procedure Add_Worker(Index: in Integer; Worker: Worker_Pointer) is
         begin
            Workers(Index) := Worker;
         end Add_Worker;

      end Worker_Manager;


      protected body Service_Manager is
         entry Get_Crash_Report(Crash_Report : in Report)
           when True is
         begin
            if not Contains(To_Fix, Crash_Report) and not Contains(In_Fixing, Crash_Report) then
               if Consts.Verbose_Mode then
                  Put_Line("[SERVICE] Got Crash Report");
               end if;
               To_Fix.Append(Crash_Report);
            end if;

         end Get_Crash_Report;

         entry Give_Fix_Order(Fix_Order : out Report)
           when True is
            Crash_Report : Report;
         begin
            if To_Fix.Length /= 0 then

               Crash_Report  := To_Fix.First_Element;
               if Consts.Verbose_Mode then
                  Put_Line("[SERVICE] Give fix order for machine" & Crash_Report.ID'Image);
               end if;
               To_Fix.Delete_First;
               In_Fixing.Append(Crash_Report);
               Fix_Order := Crash_Report;
            else
               Fix_Order := (-1, 'a');
            end if;
         end Give_Fix_Order;

         entry Get_Fix_Report(Fix_Report : in Report)
           when True is
         begin
            Index := Get_Index(In_Fixing, Fix_Report);

            if Index /= 2137 then
               if Consts.Verbose_Mode then
                  Put_Line("[SERVICE] Get Fix Report");
               end if;
               In_Fixing.Delete (Index);
            end if;

         end Get_Fix_Report;

         function Report_Exists(V : Reports_List.Vector; R : Report) return Boolean
         is
         begin
            for Index in V.First_Index .. V.Last_Index loop
               if V(Index).ID = R.ID and V(Index).Machine_Type = R.Machine_Type then
                  return True;
               end if;
            end loop;
            return False;
         end Report_Exists;

         function Get_Index(V : Reports_List.Vector; R : Report) return Natural
         is
         begin
            for Index in V.First_Index .. V.Last_Index loop
               if V(Index).ID = R.ID and V(Index).Machine_Type = R.Machine_Type then
                  return Index;
               end if;
            end loop;
            return 2137;
         end Get_Index;

      end Service_Manager;

      -- managers
      Scheduler: Task_Scheduler;
      Manager: Warehouse_Manager;
      WorkerMan: Worker_Manager;
      ServiceMan: Service_Manager;


      task body Machine is
         Given_Task: Order;
         Is_Broken: Boolean := False;
      begin
         loop
            select
               accept Get_Task (O: in Order)
               do
                  Given_Task := O;
               end Get_Task;

               if Consts.Verbose_Mode then
                  Put_Line("[MACHINE " & Id'Image & "] Got task ( " & Given_Task.First'Image & " " & Given_Task.Operator & " " & Given_Task.Second'Image & " )");
               end if;

               if Is_Broken then
                  Given_Task.Result := -1;
               else
                  case Given_Task.Operator is
                  when '+' =>
                     Given_Task.Result := Given_Task.First + Given_Task.Second;
                  when '*' =>
                     Given_Task.Result := Given_Task.First * Given_Task.Second;
                  when others =>
                     Given_Task.Result := 0;
                  end case;
               end if;


               delay Consts.Machine_Delay;


               accept Give_Product (O: out Order) do
                  O := Given_Task;
               end Give_Product;

               if Crash_Random.Random(Crash_Generator) < Consts.Machine_Crash_Proba then
                  Is_Broken := True;
                  if Consts.Verbose_Mode then
                     Put_Line("[MACHINE " & Id'Image & "] Crashed");
                  end if;
               end if;


            or
               accept Rejection do
                  if Consts.Verbose_Mode then
                     Put_Line("[MACHINE " & Id'Image & "] Rejected");
                  end if;
               end Rejection;
            or
                accept Fix do
                  Is_Broken := False;
                  if Consts.Verbose_Mode then
                     Put_Line("[MACHINE " & Id'Image & "] Fixed");
                  end if;
               end Fix;
            end select;

         end loop;
      end Machine;


      task body Director is
         subtype Operator_Range is Integer range 0 .. 1;
         subtype Elements_Range is Integer range 0 .. 69;
         package R is new Ada.Numerics.Discrete_Random (Operator_Range);
         package P is new Ada.Numerics.Discrete_Random (Elements_Range);
         G: R.Generator;
         G1: P.Generator;
         X: Operator_Range;
         Operators: array (Operator_Range) of Character;
         Operator: Character;
         New_Task: Order;
      begin
         R.Reset (G);
         P.Reset (G1);
         Operators := ('+', '*');
         loop
            X := R.Random (G);
            Operator := Operators(X);
            New_Task := (P.Random (G1), P.Random (G1), Operator, 0);
            Scheduler.Add_Element (New_Task);
            delay Consts.Director_Delay;
         end loop;

      end Director;


      -- arrays of machines
      Adding_Machines: array (1 .. Consts.Adding_Machine_No) of Machine_Pointer;
      Multiplying_Machines: array (1 .. Consts.Multiplying_Machine_No) of Machine_Pointer;


      procedure Next_Machine(Operator: in Character; Index: in out Integer) is
         subtype Adding_Machine_Range is Integer range 1 .. Consts.Adding_Machine_No;
         subtype Mulitplying_Machine_Range is Integer range 1 .. Consts.Multiplying_Machine_No;
         package R is new Ada.Numerics.Discrete_Random (Adding_Machine_Range);
         package P is new Ada.Numerics.Discrete_Random (Mulitplying_Machine_Range);
         G: R.Generator;
         G1: P.Generator;
      begin
         case Operator is
               when '+' =>
                  Index := R.Random (G);
               when '*' =>
                  Index := P.Random(G1);
               when others =>
                  Index := 0;
            end case;
      end Next_Machine;


      task body Worker is
         Given_Task: Order;
         Machine_Index: Integer;
         Machine: Machine_Pointer;
         Crash_Report: Report;
      begin
         Machine_Index := 1;
         loop
            Scheduler.Take_Element (Given_Task);
            loop

               case Given_Task.Operator is
               when '+' =>
                  Machine := Adding_Machines(Machine_Index);
               when '*' =>
                  Machine := Multiplying_Machines(Machine_Index);
               when others =>
                  Given_Task.Result := 0;
               end case;


               if Impatient then
                  select
                     Machine.Get_Task (Given_Task);
                     if Consts.Verbose_Mode then
                        Put_Line("[WORKER " & Id'Image & "] uses machine " & Machine.Id'Image);
                     end if;

                     exit;
                  or
                     delay Consts.Impatient_Worker_Waiting_Time;
                     Machine.Rejection;
                     Next_Machine (Given_Task.Operator, Machine_Index);
                     if Consts.Verbose_Mode then
                        Put_Line("[WORKER " & Id'Image & "] rejected by machine " & Machine.Id'Image);
                     end if;
                  end select;
               else
                  exit;
               end if;
            end loop;

            Machine.Give_Product(Given_Task);

            if Given_Task.Result = -1 then
               Crash_Report := (Machine.Id, Given_Task.Operator);
               ServiceMan.Get_Crash_Report(Crash_Report);
               if Consts.Verbose_Mode then
                  Put_Line("[WORKER" & ID'Image & "] Found broken machine " & Machine.Id'Image);
               end if;
            else
               if Consts.Verbose_Mode then
                  Put_Line("[WORKER " & Id'Image & "] finished ( " & Given_Task.First'Image & " " & Given_Task.Operator & " " & Given_Task.Second'Image & " ) with result " & Given_Task.Result'Image);
               end if;
               Manager.Add_Element(Given_Task.Result);
               WorkerMan.Add_Done_Task(Id);
            end if;
            delay Consts.Worker_Delay;
         end loop;
      end Worker;


      task body Customer is
         Bought_Product: Integer;
      begin
         loop
            Manager.Take_Element(Bought_Product);
            if Consts.Verbose_Mode then
               Put_Line("[CUSTOMER " & Id'Image & "] Bought product.");
            end if;
            delay Consts.Customer_Delay;
         end loop;
      end Customer;


      task body Service_Worker is
         Fix_Order : Report;
         Machine_ID : Integer;
         Machine_Type : Character;
      begin
         loop
            ServiceMan.Give_Fix_Order(Fix_Order);
            Machine_ID := Fix_Order.ID;
            Machine_Type := Fix_Order.Machine_Type;

            if Machine_ID /= -1 then
               delay Consts.Service_Worker_Delay;
               if Machine_Type = '+' then
                  Adding_Machines(Machine_ID).Fix;
               else
                  Multiplying_Machines(Machine_ID).Fix;
               end if;
               ServiceMan.Get_Fix_Report((Machine_ID, Machine_Type));

               Put_Line ("[SERVICE WORKER" & ID'Image & "] Fix machine with ID " & Machine_ID'Image);
            end if;
         end loop;
      end Service_Worker;


      Warehouse_Director: Director;
      New_Worker: Worker_Pointer;
      New_Customer: Customer_Pointer;
      New_Service_Worker: Service_Worker_Pointer;



   begin

      for I in 1 .. Consts.Adding_Machine_No loop
         Adding_Machines(I) := new Machine(I);
      end loop;

      for I in 1 .. Consts.Multiplying_Machine_No loop
         Multiplying_Machines(I) := new Machine(I + Consts.Adding_Machine_No);
      end loop;

      Impatience_Random.Reset (Impatience_Generator);
      for I in 1 .. Consts.Workers_No loop
            New_Worker := new Worker (I, Impatience(Impatience_Random.Random(Impatience_Generator)));
            WorkerMan.Add_Worker(I, New_Worker);
      end loop;

      for I in 1 .. Consts.Customer_No loop
         New_Customer := new Customer(I);
      end loop;

      for I in 1 .. Consts.SeviceWorker_No loop
         New_Service_Worker := new Service_Worker(I);
      end loop;




      if not Consts.Verbose_Mode then
         loop
            Get(Letter);

            case Letter is
            when  'w' =>
               Manager.Print_Warehouse_Products;
            when 't' =>
               Scheduler.Print_Tasks;
            when 's' =>
               WorkerMan.Print_Worker_Data;


            when others =>
               Put_Line("I do not know such a command");
            end case;


         end loop;
      end if;



   end Simulate_Company;



end company;
