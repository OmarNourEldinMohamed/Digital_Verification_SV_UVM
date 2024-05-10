module FIFO(FIFO_if.fifo_dut interface_object);

    // declaration of max. FIFO address
    localparam max_fifo_addr = $clog2(interface_object.FIFO_DEPTH);   // max_fifo_addr = 3
    
    // declaration of Memory (FIFO)
    reg [interface_object.FIFO_WIDTH-1:0] mem [interface_object.FIFO_DEPTH-1:0];
    
    // Declaration of read & write pointers
    reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;          
    reg [max_fifo_addr:0] count;              // extra bit to distinguish between full & empty flags & it represents the fill level of the FIFO
    
    // always block specialized for writing operation
    always @(posedge interface_object.clk or negedge interface_object.rst_n) begin
        if (!interface_object.rst_n) begin
            wr_ptr <= 0;
            interface_object.overflow <= 0;
            interface_object.wr_ack <= 0;             // reset the sequential outputs as wr_ack , overflow
        end
        else if (interface_object.wr_en && count < interface_object.FIFO_DEPTH) begin
            mem[wr_ptr] <= interface_object.data_in;
            interface_object.wr_ack <= 1;
            wr_ptr <= wr_ptr + 1;
        end
        else begin 
            interface_object.wr_ack <= 0; 
            if (interface_object.full && interface_object.wr_en)
                interface_object.overflow <= 1;
            else
                interface_object.overflow <= 0;
        end
    end
    
    // always block specialized for reading operation
    always @(posedge interface_object.clk or negedge interface_object.rst_n) begin
        if (!interface_object.rst_n) begin
            rd_ptr <= 0;
            interface_object.underflow <= 0;
            interface_object.data_out <= 0;       // reset the sequential outputs as data_out , underflow
        end
        else if (interface_object.rd_en && count != 0) begin
            interface_object.data_out <= mem[rd_ptr];
            rd_ptr <= rd_ptr + 1;
            end
        else
        begin
            if(interface_object.empty && interface_object.rd_en)
                interface_object.underflow  <= 1;
            else
                interface_object.underflow  <= 0;
        end
    end
    
    // always block specialized for counter signal
    always @(posedge interface_object.clk or negedge interface_object.rst_n) begin
        if (!interface_object.rst_n) begin
            count <= 0;
        end
        else begin
            if	( ({interface_object.wr_en, interface_object.rd_en} == 2'b10) && !interface_object.full) 
                count <= count + 1;
            else if ( ({interface_object.wr_en, interface_object.rd_en} == 2'b01) && !interface_object.empty)
                count <= count - 1;
            else if (({interface_object.wr_en, interface_object.rd_en} == 2'b11) && interface_object.full)      // priority for write operation
                count <= count - 1;
            else if (({interface_object.wr_en, interface_object.rd_en} == 2'b11) && interface_object.empty)      // priority for read operation
                count <= count + 1;
        end
    end
    
    // continous assignment for the combinational outputs
    assign interface_object.full = (count == interface_object.FIFO_DEPTH)? 1 : 0;            
    assign interface_object.empty = (count == 0)? 1 : 0;                  
    assign interface_object.almostfull = (count == interface_object.FIFO_DEPTH-1)? 1 : 0;           
    assign interface_object.almostempty = (count == 1)? 1 : 0;
    
    // Assertions to the DUT
    //`ifdef SIM
    
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