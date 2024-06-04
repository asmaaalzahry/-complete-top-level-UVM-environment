module tb_top ; 
	import uvm_pkg ::*;
	import FIFO_env_pkg::*;
	import FIFO_test_pkg::*;

   bit clk ;

   // Clock generation 
   initial begin 
   clk = 0 ; 
   forever #1 clk = ~clk ; 
   end

   	FIFO_env  env_inst ; 
   	FIFO_test test ;
   	// instantiate the interface and pass it to design 
   	FIFO_if intf (clk) ;
   	FIFO DUT (intf) ; 
   	// bind FIFO FIFO_sva FIFO_sva_inst (intf) ;
  // 	FIFO_sva FIFO_sva_inst (DUT.data_in , DUT.clk, DUT.rst_n, DUT.wr_en, DUT.rd_en , DUT.data_out, DUT.wr_ack,DUT.overflow , DUT.full, DUT.empty, DUT.almostfull, DUT.almostempty, DUT.underflow) ;

   	// passes the interface using config.database
   	initial begin 
   	uvm_config_db #(virtual FIFO_if )::set (null , "*" , "intf" , intf ) ;
    //Run test 
   	run_test("FIFO_test") ; 
   end

endmodule 


