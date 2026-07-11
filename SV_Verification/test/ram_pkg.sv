
package ram_pkg;

   int number_of_transactions = 1;
  
   //include the files 
   //"ram_trans.sv", "ram_gen.sv", "ram_write_drv.sv"
   //"ram_read_drv.sv", "ram_write_mon.sv", "ram_read_mon.sv"
   //"ram_model.sv", "ram_sb.sv", "ram_env.sv", "test.sv" 
   `include "ram_trans.sv"
   `include "ram_gen.sv"
   `include "ram_write_drv.sv"
   `include "ram_read_drv.sv"
   `include "ram_write_mon.sv"
   `include "ram_read_mon.sv"
   `include "ram_model.sv"
   `include "ram_sb.sv"
   `include "ram_env.sv"
   `include "test.sv"

endpackage
