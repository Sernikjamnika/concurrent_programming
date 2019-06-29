with Ada.Numerics.Discrete_Random;


package Company is
   
   procedure Simulate_Company;
   
   type Order is record
      First: Integer;
      Second: Integer;
      Operator: Character;
      Result: Integer := 0;
   end record;
   
   
   type Orders is array(Integer range<>) of Order;
   type Warehouse_Products is array(Integer range<>) of Integer;
   
   Letter: Character;

end company;
