package FIFO_monitor_pkg ;
     import uvm_pkg::* ;

`include "uvm_macros.svh"
import FIFO_seq_item_pkg::*;

class FIFO_monitor extends uvm_monitor ; 
   `uvm_component_utils(FIFO_monitor)
	virtual FIFO_if intf ;
	FIFO_seq_item rsp_seq_item ; 

	uvm_analysis_port #(FIFO_seq_item) mon_ap ;

	function new (string name = "FIFO_monitor" , uvm_component parent = null ) ;
		super.new(name,parent) ;
    endfunction

    function void build_phase(uvm_phase phase );
	super.build_phase (phase);
    mon_ap = new ("mon_ap"  , this) ;
    endfunction

    task run_phase (uvm_phase phase) ; 
    super.run_phase (phase) ;    
    forever begin

         	rsp_seq_item = FIFO_seq_item::type_id::create("rsp_seq_item");

         // rsp_seq_item.data_in =  intf.data_in  ; 	
         // rsp_seq_item.rst_n  = intf.rst_n ; 
         // rsp_seq_item.wr_en  = intf.wr_en ; 
         // rsp_seq_item.rd_en = intf.rd_en ;
         //  @(negedge intf.clk);
         // rsp_seq_item.data_out = intf.data_out ;
         // rsp_seq_item.wr_ack =  intf.wr_ack  ;      
         // rsp_seq_item.overflow  = intf.overflow ; 
         // rsp_seq_item.full  = intf.full ; 
         // rsp_seq_item.empty = intf.empty ;
         // rsp_seq_item.almostfull = intf.almostfull ; 
         // rsp_seq_item.almostempty = intf.almostempty ;
         // rsp_seq_item.underflow = intf.underflow ;
         // @(posedge intf.clk);

          @(negedge intf.clk);
          // outputs
          rsp_seq_item.data_out =intf.data_out ;
          rsp_seq_item.wr_ack=intf.wr_ack;
          rsp_seq_item.overflow=intf.overflow;
          rsp_seq_item.full=intf.full;
          rsp_seq_item.empty=intf.empty;
          rsp_seq_item.almostfull=intf.almostfull;
          rsp_seq_item.almostempty=intf.almostempty;
          rsp_seq_item.underflow=intf.underflow;
          // inputs
          rsp_seq_item.data_in=intf.data_in;
          rsp_seq_item.wr_en=intf.wr_en;
          rsp_seq_item.rd_en=intf.rd_en;
          rsp_seq_item.rst_n=intf.rst_n;

          mon_ap.write(rsp_seq_item);        
          `uvm_info ("run_phase" ,rsp_seq_item.convert2string(),UVM_HIGH)
        
    end
endtask 
endclass
endpackage

