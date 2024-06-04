package FIFO_scoreboard_pkg ;
import uvm_pkg::* ;
`include "uvm_macros.svh"
import FIFO_seq_item_pkg::*;

class FIFO_scoreboard extends uvm_scoreboard ; 
    `uvm_component_utils(FIFO_scoreboard)
    uvm_analysis_export #(FIFO_seq_item) sb_export ;
    uvm_tlm_analysis_fifo #(FIFO_seq_item) sb_fifo ;
    FIFO_seq_item seq_item_sb ;
    parameter FIFO_WIDTH = 16;
    parameter FIFO_DEPTH = 8;
    logic [FIFO_WIDTH-1:0] data_out_ref;
    logic wr_ack_ref, overflow_ref;
    logic full_ref, empty_ref, almostfull_ref, almostempty_ref, underflow_ref; 
    int error_count=0, correct_count=0; 
    logic [FIFO_WIDTH-1:0] Fifo_que[$] ; 


        function new(string name = "FIFO_scoreboard", uvm_component parent = null);
            super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sb_export=new("sb_export",this);
            sb_fifo=new("sb_fifo",this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            sb_export.connect(sb_fifo.analysis_export);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                sb_fifo.get(seq_item_sb);
                check_result(seq_item_sb);
            end
        endtask

        function void report_phase(uvm_phase phase);
            super.report_phase(phase);
            `uvm_info("report_phase", $sformatf("At time %0t: Simulation Ends and Error Count= %0d, Correct Count= %0d", $time, error_count, correct_count), UVM_MEDIUM);
        endfunction

        function void check_result(FIFO_seq_item seq_item_ch);
            reference_model(seq_item_ch);
            if (seq_item_ch.data_out != data_out_ref &&
             seq_item_ch.wr_ack != wr_ack_ref &&
             seq_item_ch.overflow != overflow_ref &&
             seq_item_ch.full != full_ref &&
             seq_item_ch.empty != empty_ref &&
             seq_item_ch.almostfull != almostfull_ref &&
             seq_item_ch.almostempty != almostempty_ref &&
             seq_item_ch.underflow != underflow_ref ) begin

                error_count++;
                `uvm_error("run_phase", "Comparison Error");
            end
            else begin 
                correct_count++;  end

        endfunction

        function void reference_model(FIFO_seq_item seq_item_chk);

            if (!seq_item_chk.rst_n) begin
                Fifo_que.delete();
                underflow_ref=0;  overflow_ref=0; 
                wr_ack_ref=0;
            end 
            else begin
                // read only & not empty
                if ( {seq_item_chk.wr_en,seq_item_chk.rd_en} == 2'b01 && Fifo_que.size() != 0 ) begin
                    data_out_ref=Fifo_que.pop_front();
                     wr_ack_ref=0;
                end 
                // write only & not full
                else if ( {seq_item_chk.wr_en,seq_item_chk.rd_en} == 2'b10 && Fifo_que.size() != FIFO_DEPTH ) begin
                    Fifo_que.push_back(seq_item_chk.data_in);
                     wr_ack_ref=1;
                end
                // both read and write & (full, empty, not full or empty)
                else if ( {seq_item_chk.wr_en,seq_item_chk.rd_en} == 2'b11 ) begin
                    if (Fifo_que.size() == FIFO_DEPTH) begin
                        data_out_ref=Fifo_que.pop_front(); 
                        wr_ack_ref=0;
                    end else if (Fifo_que.size() == 0) begin
                        Fifo_que.push_back(seq_item_chk.data_in); 
                        wr_ack_ref=1;
                    end else begin
                        Fifo_que.push_back(seq_item_chk.data_in); 
                        wr_ack_ref=1;
                        data_out_ref=Fifo_que.pop_front();
                    end
                end 
                else begin
                     wr_ack_ref=0;
                end
            end
            underflow_ref = (!seq_item_chk.rst_n)? 0:(empty_ref && seq_item_chk.rd_en)? 1 : 0;
            overflow_ref  = (!seq_item_chk.rst_n)? 0:(full_ref  && seq_item_chk.wr_en)? 1 : 0;
            full_ref = (Fifo_que.size() == FIFO_DEPTH)? 1 : 0;
            empty_ref = (Fifo_que.size() == 0)? 1 : 0;
            almostfull_ref = (Fifo_que.size() == FIFO_DEPTH-1)? 1 : 0; 
            almostempty_ref = (Fifo_que.size() == 1)? 1 : 0;
        endfunction

    endclass

endpackage