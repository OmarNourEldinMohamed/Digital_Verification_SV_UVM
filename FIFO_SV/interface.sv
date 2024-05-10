interface FIFO_if(clk);
    input bit clk;
    //interface includes all ports

    //parameters:
    parameter FIFO_WIDTH = 16;
    parameter FIFO_DEPTH = 8;
    //inputs
    logic [FIFO_WIDTH-1:0]data_in;
    logic  rst_n, wr_en, rd_en;
    //outputs
    logic [FIFO_WIDTH-1:0]data_out;
    logic wr_ack, overflow, full, empty, almostfull, almostempty, underflow;
    //modport dut
    modport fifo_dut (
    input clk, data_in, rst_n, wr_en, rd_en,
    output data_out, wr_ack, overflow, full, empty, almostfull, almostempty, underflow
    );
    //modport tb=>
    modport fifo_testbech (
    input clk, data_out, wr_ack, overflow, full, empty, almostfull, almostempty, underflow, 
    output data_in, rst_n, wr_en, rd_en
    );
    //modport monitor=>
    modport fifoMonitor (input clk, data_in, rst_n, wr_en, rd_en, data_out, wr_ack, overflow, full, empty, almostfull, almostempty, underflow);



endinterface