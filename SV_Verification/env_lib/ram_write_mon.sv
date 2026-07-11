
//In class ram_write_mon

class ram_write_mon;

   //Instantiate virtual interface instance wr_mon_if of type ram_if with WR_MON_MP modport
   virtual ram_if.WR_MON_MP wr_mon_if;

   //Declare two handles 'wrdata' and 'data2rm' of class type ram_trans
   ram_trans wrdata;
   ram_trans data2rm;

   //Declare a mailbox 'mon2rm' parameterized by type ram_trans
   mailbox #(ram_trans) mon2rm;
   
   //In constructor
   //Pass the following as the input arguments  
   //virtual interface 
   //mailbox handle 'mon2rm' parameterized by ram_trans  
   //make the connections and allocate memory for 'wrdata' 

   function new(virtual ram_if.WR_MON_MP wr_mon_if,
                mailbox #(ram_trans) mon2rm);
      this.wr_mon_if = wr_mon_if;
      this.mon2rm    = mon2rm;
      this.wrdata    = new;
   endfunction: new


   virtual task monitor();
      @(wr_mon_if.wr_mon_cb)
      wait(wr_mon_if.wr_mon_cb.write==1) 
      @(wr_mon_if.wr_mon_cb);
      begin
         wrdata.write= wr_mon_if.wr_mon_cb.write;
         wrdata.wr_address =  wr_mon_if.wr_mon_cb.wr_address;
         wrdata.data= wr_mon_if.wr_mon_cb.data_in;
         //call the display of ram_trans to display the monitor data
         wrdata.display("DATA FROM WRITE MONITOR");
      
      end
   endtask: monitor
   
   
   //In virtual task start          
   virtual task start();
      //within fork-join_none
      //In forever loop
      fork
         forever
            begin
               //Call the monitor task
               //Understand the provided monitor task
               //Monitor task samples the interface signals 
               //according to the protocol and convert to transaction items 
               monitor(); 
               //shallow copy wrdata to data2rm          
               //Put the transaction item into the mailbox mon2rm
               data2rm = new wrdata;
               mon2rm.put(data2rm);
            end
      join_none
   endtask: start

endclass:ram_write_mon
