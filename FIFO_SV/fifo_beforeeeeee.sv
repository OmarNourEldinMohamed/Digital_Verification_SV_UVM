////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: FIFO Design =============================================== with bugs ================
// 
////////////////////////////////////////////////////////////////////////////////
module FIFO(FIFO_if.fifo_dut interface_object);
// parameter interface_object.FIFO_WIDTH = 16;
// parameter interface_object.FIFO_DEPTH = 8;
// input [interface_object.FIFO_WIDTH-1:0] interface_object.data_in;
// input interface_object.clk, interface_object.rst_n, interface_object.wr_en, interface_object.rd_en;
// output reg [interface_object.FIFO_WIDTH-1:0] interface_object.data_out;
// output reg interface_object.wr_ack, interface_object.overflow;
// output interface_object.full, interface_object.empty, almostinterface_object.full, almostempty, underflow;
 
localparam max_fifo_addr = $clog2(interface_object.FIFO_DEPTH);

reg [interface_object.FIFO_WIDTH-1:0] mem [interface_object.FIFO_DEPTH-1:0];

reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
reg [max_fifo_addr:0] count;

always @(posedge interface_object.clk or negedge interface_object.rst_n) begin
	if (!interface_object.rst_n) begin
		wr_ptr <= 0;
	end
	else if (interface_object.wr_en && count < interface_object.FIFO_DEPTH) begin
		mem[wr_ptr] <= interface_object.data_in;
		interface_object.wr_ack <= 1;
		wr_ptr <= wr_ptr + 1;
	end
	else begin 
		interface_object.wr_ack <= 0; 
		if (interface_object.full & interface_object.wr_en)
			interface_object.overflow <= 1;
		else
			interface_object.overflow <= 0;
	end
end

always @(posedge interface_object.clk or negedge interface_object.rst_n) begin
	if (!interface_object.rst_n) begin
		rd_ptr <= 0;
	end
	else if (interface_object.rd_en && count != 0) begin
		interface_object.data_out <= mem[rd_ptr];
		rd_ptr <= rd_ptr + 1;
	end
end

always @(posedge interface_object.clk or negedge interface_object.rst_n) begin
	if (!interface_object.rst_n) begin
		count <= 0;
	end
	else begin
		if	( ({interface_object.wr_en, interface_object.rd_en} == 2'b10) && !interface_object.full) 
			count <= count + 1;
		else if ( ({interface_object.wr_en, interface_object.rd_en} == 2'b01) && !interface_object.empty)
			count <= count - 1;
	end
end

assign interface_object.full = (count == interface_object.FIFO_DEPTH)? 1 : 0;
assign interface_object.empty = (count == 0)? 1 : 0;
assign underflow = (interface_object.empty && interface_object.rd_en)? 1 : 0; 
assign interface_object.almostfull = (count == interface_object.FIFO_DEPTH-2)? 1 : 0; 
assign interface_object.almostempty = (count == 1)? 1 : 0;

property p1;
    @(posedge interface_object.clk) disable iff(!interface_object.rst_n) (interface_object.wr_en && !interface_object.full) |=> interface_object.wr_ack ;
    endproperty
    write_acknowledge : assert property(p1);
    write_acknowledge_cover : cover property(p1);
    
    property p2;
    @(posedge interface_object.clk) disable iff(!interface_object.rst_n) (interface_object.empty && interface_object.rd_en) |=> interface_object.underflow ;
    endproperty
    underflow_assertion : assert property(p2);
    underflow_cover : cover property(p2);
    
    property p3;
    @(posedge interface_object.clk) disable iff(!interface_object.rst_n) (interface_object.full & interface_object.wr_en) |=> interface_object.overflow ;
    endproperty
    overflow_assertion : assert property(p3);
    overflow_cover : cover property(p3);
    
    property p4;
    @(posedge interface_object.clk) disable iff(!interface_object.rst_n) (!interface_object.full & interface_object.wr_en & !interface_object.rd_en) |=> (count == $past(count) + 4'b0001 ) ;
    endproperty
    increment_assertion : assert property(p4);
    increment_cover : cover property(p4);
    
    property p5;
    @(posedge interface_object.clk) disable iff(!interface_object.rst_n) (!interface_object.empty && interface_object.rd_en && !interface_object.wr_en) |=> (count == $past(count) - 4'b0001 ) ;
    endproperty
    decrement_assertion : assert property(p5);
    decrement_cover : cover property(p5);
    
    property p6;
    @(posedge interface_object.clk) disable iff(!interface_object.rst_n) (count == interface_object.FIFO_DEPTH) |-> interface_object.full ;
    endproperty
    full_assertion : assert property(p6);
    full_cover : cover property(p6);
    
    property p7;
    @(posedge interface_object.clk) disable iff(!interface_object.rst_n) (count == 0) |-> interface_object.empty ;
    endproperty
    empty_assertion : assert property(p7);
    empty_cover : cover property(p7);
    
    property p8;
    @(posedge interface_object.clk) disable iff(!interface_object.rst_n) (count == interface_object.FIFO_DEPTH-1) |-> interface_object.almostfull ;
    endproperty
    almostfull_assertion : assert property(p8);
    almostfull_cover : cover property(p8);
    
    property p9;
    @(posedge interface_object.clk) disable iff(!interface_object.rst_n) (count == 1) |-> interface_object.almostempty ;
    endproperty
    almostempty_assertion : assert property(p9);
    almostempty_cover : cover property(p9);
    
    //`endif
    
    endmodule