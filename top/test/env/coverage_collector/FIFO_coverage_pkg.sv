package FIFO_coverage_pkg ;
import uvm_pkg::* ;
 import FIFO_driver_pkg::*;
 import FIFO_main_sequence_pkg::* ;
 import FIFO_reset_sequence_pkg::* ;
 import FIFO_seq_item_pkg::* ;
 import FIFO_config_pkg::* ;
 import FIFO_sequencer_pkg::*;
 import FIFO_monitor_pkg::*;
 import FIFO_config_pkg::*;
`include "uvm_macros.svh"
class FIFO_coverage extends uvm_component ; 
	`uvm_component_utils(FIFO_coverage)
	uvm_analysis_export #(FIFO_seq_item) cov_export ;
	uvm_tlm_analysis_fifo #(FIFO_seq_item) cov_fifo ;
	FIFO_seq_item seq_item_cov ;

	covergroup cvr_grp ; 

		   empty_point:coverpoint seq_item_cov.empty;
            almostfull_point:coverpoint seq_item_cov.almostfull;
            almostempty_point:coverpoint seq_item_cov.almostempty;
            underflow_point:coverpoint seq_item_cov.underflow;
            wr_en_point:coverpoint seq_item_cov.wr_en;
            rd_en_point:coverpoint seq_item_cov.rd_en;
            wr_ack_point:coverpoint seq_item_cov.wr_ack;
            data_in_point:coverpoint seq_item_cov.data_in;
            overflow_point:coverpoint seq_item_cov.overflow;
            full_point:coverpoint seq_item_cov.full;

           /* wr_ack_point_cross:cross wr_en_point,rd_en_point,wr_ack_point{
                illegal_bins wr_and_wr_ack=binsof(wr_en_point)intersect{0}&&binsof(wr_ack_point)intersect{1};
            }
            overflow_point_cross:cross wr_en_point,rd_en_point,overflow_point{
                illegal_bins wr_and_over=binsof(wr_en_point)intersect{0}&&binsof(overflow_point)intersect{1};
            }
            full_point_cross:cross wr_en_point,rd_en_point,full_point{
                illegal_bins full_wr_rd=binsof(wr_en_point)intersect{0}&&binsof(rd_en_point)intersect{1}&&binsof(full_point)intersect{1};
            }
            empty_point_cross:cross wr_en_point,rd_en_point,empty_point
            {
                illegal_bins empty_and_wr=binsof(wr_en_point)intersect{1}&&binsof(rd_en_point)intersect{0}&&binsof(empty_point)intersect{1};
            }
            almostfull_point_cross:cross wr_en_point,rd_en_point,almostfull_point;
            almostempty_point_cross:cross wr_en_point,rd_en_point,almostempty_point;
            underflow_point_cross:cross wr_en_point,rd_en_point,underflow_point{
                illegal_bins underflow_and_rd=binsof(rd_en_point)intersect{0}&&binsof(underflow_point)intersect{1};
            }*/

        endgroup

    function new (string name = "FIFO_coverage" , uvm_component parent = null );
		super.new(name,parent) ; 
		cvr_grp   = new() ;

	endfunction 

	function void build_phase(uvm_phase phase );
	super.build_phase (phase);
    cov_export = new ("cov_export"  , this) ;
    cov_fifo = new ("cov_fifo"  , this) ;	  
       endfunction

    function void connect_phase (uvm_phase phase ) ;
    	super.connect_phase (phase) ;
	cov_export.connect (cov_fifo.analysis_export) ;
    endfunction

    task run_phase (uvm_phase phase );
    	super.run_phase (phase);
    	
    	forever begin
    	cov_fifo.get(seq_item_cov) ;
    	cvr_grp.sample() ;
    	  end	
    endtask
endclass
endpackage