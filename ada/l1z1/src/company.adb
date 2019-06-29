with Ada.Numerics.Discrete_Random;
with Ada.Text_IO;
use Ada.Text_IO;
with Consts;

package body Company is

   procedure Simulate_Company is

      protected type Task_Scheduler is
         entry Add_Element (New_Task : in Order);
         entry Take_Element (Given_Task: out Order);
         procedure Print_Tasks;
      private
         Tasks: Orders(0 .. Consts.Task_List_Length);
         Index : Integer := 0;
      end Task_Scheduler;

      protected type Warehouse_Manager is
         entry Add_Element (Product: in Integer);
         entry Take_Element (Purchased_Product: out Integer);
         procedure Print_Warehouse_Products;
      private
         Products: Warehouse_Products(0 .. Consts.Warehouse_Capacity);
         Index: Integer := 0;

      end Warehouse_Manager;

      task type Director;
      task type Customer (Id: Integer);
      task type Worker (Id: Integer);


      type Worker_Pointer is access Worker;
      type Customer_Pointer is access Customer;


      protected body Warehouse_Manager is
         entry Add_Element (Product: in Integer)
           when Index < Consts.Warehouse_Capacity is
         begin
            Products(Index) := Product;
            Index := Index + 1;
            if Consts.Verbose_Mode then
               Put_Line("Worker has delivered product. #Products in warehouse: " & Index'Image);
            end if;
         end Add_Element;

         entry Take_Element (Purchased_Product : out Integer)
           when Index > 0 is
         begin
            Index := Index - 1;
            Purchased_Product := Products(Index);
            if Consts.Verbose_Mode then
               Put_Line("Customer bought product. #Products in warehouse: " & Index'Image);
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
               Put("( " & New_Task.First'Image & " " & New_Task.Operator & " " & New_Task.Second'Image & " ) ");
               Put_Line("Director has made new task. Lenght of tasks: " & Index'Image);
            end if;
         end Add_Element;

         entry Take_Element (Given_Task: out Order)
           when Index > 0 is
         begin
            Index := Index - 1;
            Given_Task := Tasks(Index);
            if Consts.Verbose_Mode then
               Put_Line("Worker has taken a task. Lenght of tasks: " & Index'Image);
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


      Scheduler: Task_Scheduler;
      Manager: Warehouse_Manager;


      task body Director is
         subtype Operator_Range is Integer range 0 .. 2;
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
         Operators := ('+', '-', '*');
         loop
            X := R.Random (G);
            Operator := Operators(X);
            New_Task := (P.Random (G1), P.Random (G1), Operator);
            Scheduler.Add_Element (New_Task);
            delay Consts.Director_Delay;
         end loop;

      end Director;


      task body Worker is
         Given_Task: Order;
         Result: Integer;
      begin
         loop
            Scheduler.Take_Element (Given_Task);
            case Given_Task.Operator is
               when '+' =>
                  Result := Given_Task.First + Given_Task.Second;
               when '-' =>
                  Result := Given_Task.First - Given_Task.Second;
               when '*' =>
                  Result := Given_Task.First * Given_Task.Second;
               when others =>
                  Result := 0;
            end case;
            if Consts.Verbose_Mode then
               Put("( " & Given_Task.First'Image & " " & Given_Task.Operator & " " & Given_Task.Second'Image & " )");
               Put_Line("Worker " & Id'Image & " has finished the task with result " & Result'Image);
            end if;
            Manager.Add_Element(Result);
            delay Consts.Worker_Delay;
         end loop;
      end Worker;


      task body Customer is
         Bought_Product: Integer;
      begin
         loop
            Manager.Take_Element(Bought_Product);
            if Consts.Verbose_Mode then
               Put_Line("Customer " & Id'Image & " bought product.");
            end if;
            delay Consts.Customer_Delay;
         end loop;
      end Customer;


      Warehouse_Director: Director;
      New_Worker: Worker_Pointer;
      New_Customer: Customer_Pointer;





   begin

      for I in 1 .. Consts.Workers_No loop
         New_Worker := new Worker(I);
      end loop;

      for I in 1 .. Consts.Customer_No loop
         New_Customer := new Customer(I);
      end loop;

      if not Consts.Verbose_Mode then
         loop
            Get(Letter);

            case Letter is
            when  'w' =>
               Manager.Print_Warehouse_Products;
            when 't' =>
               Scheduler.Print_Tasks;
            when others =>
               Put_Line("I do not know such a command");
            end case;


         end loop;
      end if;



   end Simulate_Company;



end company;
