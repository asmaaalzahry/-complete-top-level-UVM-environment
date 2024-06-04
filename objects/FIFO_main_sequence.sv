package FIFO_main_sequence_pkg ; 
	import uvm_pkg::* ;
	import FIFO_seq_item_pkg::* ;
   `include "uvm_macros.svh"

class FIFO_main_sequence extends uvm_sequence #(FIFO_seq_item) ; 
	`uvm_object_utils (FIFO_main_sequence) ;
	 FIFO_seq_item seq_item ; 

 	function new (string name = "FIFO_main_sequence");
		super.new(name) ; 
	endfunction   

	task body ;

		repeat(10000) begin
		seq_item = FIFO_seq_item ::type_id::create("seq_item");
		start_item(seq_item) ; 
		assert(seq_item.randomize());  
		finish_item(seq_item) ; 
	    end
	    
	endtask  

endclass 
endpackage
