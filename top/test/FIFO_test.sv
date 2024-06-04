package FIFO_test_pkg ; 
import FIFO_env_pkg::* ; 
import uvm_pkg::* ;
import FIFO_config_pkg::* ;
import FIFO_driver_pkg::* ;
import FIFO_main_sequence_pkg::* ;
import FIFO_reset_sequence_pkg::* ;
import FIFO_seq_item_pkg::* ;

`include "uvm_macros.svh"
class FIFO_test extends uvm_test ; 
	`uvm_component_utils(FIFO_test)

FIFO_env env ; 
FIFO_config FIFO_config_cfg ;
virtual FIFO_if intf ;  
FIFO_main_sequence main_seq ; 
FIFO_reset_sequence reset_seq ; 

function new (string name = "FIFO_test" , uvm_component parent = null ) ;
	super.new(name,parent) ;
endfunction 

function void build_phase(uvm_phase phase) ; 
	super.build_phase(phase) ;

	 env= FIFO_env :: type_id ::create("env" , this) ; 
	 FIFO_config_cfg = FIFO_config::type_id::create("FIFO_config_cfg ", this);
	 main_seq = FIFO_main_sequence::type_id::create("main_seq",this) ;
	 reset_seq = FIFO_reset_sequence::type_id::create("reset_seq",this) ;

	 if (!uvm_config_db #(virtual FIFO_if)::get (this , "" , "intf" , FIFO_config_cfg.intf))
 	`uvm_fatal("build_phase" , " test - Unable to get the virtual interface of the FIFO form the uvm_config_db ") ;

     uvm_config_db # (FIFO_config)::set (this , "*" , "CFG" ,FIFO_config_cfg );

endfunction 

 task run_phase (uvm_phase phase) ;  
	super.run_phase(phase) ;
	phase.raise_objection(this) ;
	
	// reset sequence 
	`uvm_info("run_phase", "Reset Asserted " , UVM_LOW)
	reset_seq.start (env.agt.sqr) ;
	`uvm_info("run_phase", "Reset Deasserted " , UVM_LOW)
     
     // main sequence 
	`uvm_info("run_phase", "stimulus Generation started " , UVM_LOW)
	main_seq.start (env.agt.sqr) ;
	`uvm_info("run_phase", "stimulus Generation Ended " , UVM_LOW)     
	phase.drop_objection(this) ;

endtask 
endclass 
endpackage 

