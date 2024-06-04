module FIFO(FIFO_if.DUT intf);
// Design inputs
logic [intf.FIFO_WIDTH-1:0] data_in;
logic clk, rst_n, wr_en, rd_en;
// Design outputs
logic [intf.FIFO_WIDTH-1:0] data_out;
logic wr_ack, overflow;
logic full, empty, almostfull, almostempty, underflow;

assign clk=intf.clk;
assign intf.data_out = data_out;
assign intf.wr_ack = wr_ack;
assign intf.overflow = overflow;
assign intf.full = full;
assign intf.empty = empty;
assign intf.almostfull = almostfull;
assign intf.almostempty = almostempty;
assign intf.underflow = underflow;
assign data_in = intf.data_in;
assign rst_n = intf.rst_n;
assign wr_en = intf.wr_en;
assign rd_en = intf.rd_en;


localparam max_fifo_addr = $clog2(intf.FIFO_DEPTH);

reg [intf.FIFO_WIDTH-1:0] mem [intf.FIFO_DEPTH-1:0];
reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
reg [max_fifo_addr:0] count;

// write
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		wr_ptr <= 0;
		overflow<=0;  wr_ack<=0; // ***** here *****
	end
	else if (wr_en && count < intf.FIFO_DEPTH) begin
		mem[wr_ptr] <= data_in;
		wr_ack <= 1;
		wr_ptr <= wr_ptr + 1;
		overflow <= 0; // ***** here *****
	end 
	else begin 
		wr_ack <= 0; 
		if (wr_en && full)
			overflow <= 1;
		else
			overflow <= 0;
	end
end

// read
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		rd_ptr <= 0;
		underflow <=0; // ***** here *****
	end
	else if (rd_en && count != 0) begin
		data_out <= mem[rd_ptr];
		rd_ptr <= rd_ptr + 1;
		underflow <= 0; // ***** here *****
	end 
	else begin // ***** here *****
		if (rd_en && empty) 
			underflow <= 1;
		else
			underflow <= 0;
	end
end

// counter to determine full or empty
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		count <= 0;
	end
	else begin
		if	( ({wr_en, rd_en} == 2'b10) && !full) 
			count <= count + 1;
		else if ( ({wr_en, rd_en} == 2'b01) && !empty)
			count <= count - 1;
		else if ( {wr_en, rd_en} == 2'b11) begin // ***** here *****
			if (full) begin
				count <= count - 1;
			end else if (empty) begin
				count <= count + 1;
			end
		end
	end
end

// combinational outputs
assign full = (count == intf.FIFO_DEPTH)? 1 : 0;
assign empty = (count == 0)? 1 : 0;
// assign underflow = (empty && rd_en)? 1 : 0; // ***** here *****
assign almostfull = (count == intf.FIFO_DEPTH-1)? 1 : 0;  // ***** here *****
assign almostempty = (count == 1)? 1 : 0; 


// if count equals to FIFO depth then full is asserted 
full_assert: assert property (@(posedge clk) (count==intf.FIFO_DEPTH) |-> full);

// if count equals to 0 depth then empty is asserted 
empty_assert: assert property (@(posedge clk) (count==0) |-> empty);

// if count equals to FIFO depth - 1 then almostfull is asserted 
almostfull_assert: assert property (@(posedge clk) (count==intf.FIFO_DEPTH-1) |-> almostfull);

// if count equals to 1 then almostempty is asserted 
almostempty_assert: assert property (@(posedge clk) (count==1) |-> almostempty);

// if the FIFO isn't full and write enable is HIGH then wr_ack is asserted 
wr_ack_assert: assert property (@(posedge clk) disable iff(!rst_n) (wr_en&&count < intf.FIFO_DEPTH) |=> wr_ack);

// if the FIFO is full and write enable is HIGH then overflow is asserted 
overflow_assert: assert property (@(posedge clk) disable iff(!rst_n) (wr_en&&full) |=> overflow);

// if the FIFO is empty and read enable is HIGH then underflow is asserted 
underflow_assert: assert property (@(posedge clk) disable iff(!rst_n) (rd_en&&empty) |=> underflow);

// if the FIFO isn't full and write enable is HIGH then count will be incremented
count_up_assert: assert property (@(posedge clk) disable iff(!rst_n) ({wr_en,rd_en}==2'b10 && !full) |=> count==$past(count)+1);

// if the FIFO isn't empty and read enable is HIGH then count will be decremented
count_down_assert: assert property (@(posedge clk) disable iff(!rst_n) (({wr_en,rd_en}==2'b01) && !empty) |=> count==$past(count)-1);

// empty shouldn't be HIGH if write enable is 1 
wr_empty_assert: assert property (@(posedge clk) disable iff(!rst_n) (wr_en) |=> !empty);

// full shouldn't be HIGH if read enable is 1 
rd_full_assert: assert property (@(posedge clk) (rd_en) |=> !full);

// overflow shouldn't be HIGH if write enable is 0
wr_overflow_assert: assert property (@(posedge clk) (!wr_en) |=> !overflow);

// underflow shouldn't be HIGH if read enable is 0
rd_underflow_assert: assert property (@(posedge clk) (!rd_en) |=> !underflow);

// write ack shouldn't be HIGH if write enable is 0
wr_wr_ack_assert: assert property (@(posedge clk) (!wr_en) |=> !wr_ack);

// if almostfull is HIGH and wr_en only is HIGH then the next cycle full will be HIGH
almostfull_full_assert: assert property (@(posedge clk) disable iff(!rst_n) (almostfull && wr_en && !rd_en) |=> full);

// if almostempty is HIGH and rd_en only is HIGH then the next cycle empty will be HIGH
almostempty_empty_assert: assert property (@(posedge clk) disable iff(!rst_n) (almostempty && rd_en && !wr_en) |=> empty);

// Cover Directives
full_cover: cover property (@(posedge clk) (count==intf.FIFO_DEPTH) |-> full);
empty_cover: cover property (@(posedge clk) (count==0) |-> empty);
almostfull_cover: cover property (@(posedge clk) (count==intf.FIFO_DEPTH-1) |-> almostfull);
almostempty_cover: cover property (@(posedge clk) (count==1) |-> almostempty);
wr_ack_cover: cover property (@(posedge clk) disable iff(!rst_n) (wr_en&&count < intf.FIFO_DEPTH) |=> wr_ack);
overflow_cover: cover property (@(posedge clk) disable iff(!rst_n) (wr_en&&full) |=> overflow);
underflow_cover: cover property (@(posedge clk) disable iff(!rst_n) (rd_en&&empty) |=> underflow);
count_up_cover: cover property (@(posedge clk) disable iff(!rst_n) ({wr_en,rd_en}==2'b10 && !full) |=> count==$past(count)+1);
count_down_cover: cover property (@(posedge clk) disable iff(!rst_n) (({wr_en,rd_en}==2'b01) && !empty) |=> count==$past(count)-1);
wr_empty_cover: cover property (@(posedge clk) disable iff(!rst_n) (wr_en) |=> !empty);
rd_full_cover: cover property (@(posedge clk) (rd_en) |=> !full);
wr_overflow_cover: cover property (@(posedge clk) (!wr_en) |=> !overflow);
rd_underflow_cover: cover property (@(posedge clk) (!rd_en) |=> !underflow);
wr_wr_ack_cover: cover property (@(posedge clk) (!wr_en) |=> !wr_ack);
almostfull_full_cover: cover property (@(posedge clk) disable iff(!rst_n) (almostfull && wr_en && !rd_en) |=> full);
almostempty_empty_cover: cover property (@(posedge clk) disable iff(!rst_n) (almostempty && rd_en && !wr_en) |=> empty);


endmodule