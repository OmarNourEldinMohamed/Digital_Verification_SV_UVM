package FIFO_transaction_pkg; //pkg_1
    class FIFO_transaction;
    //parameters:
    parameter FIFO_WIDTH = 16;
    parameter FIFO_DEPTH = 8;
    //inputs
    rand bit [FIFO_WIDTH-1:0]data_in;
    rand bit rst_n, wr_en, rd_en;
    //outputs
    logic [FIFO_WIDTH-1:0]data_out;
    logic wr_ack, overflow, full, empty, almostfull, almostempty, underflow;
    //the 2 integers WR_EN_ON_DIST and RD_EN_ON_DIST
    int WR_EN_ON_DIST = 70;
    int RD_EN_ON_DIST = 30;

    //constraint rst
    constraint constrained_rst{ rst_n dist{0:/1, 1:/99}; }

    //constraint write and read as required
    constraint constrained_write{ wr_en dist{0:/(100-WR_EN_ON_DIST), 1:/WR_EN_ON_DIST}; }
    constraint constrained_read{ rd_en dist{0:/(100-RD_EN_ON_DIST), 1:/RD_EN_ON_DIST}; }

    //additional constraints =====> write_only and read_only 
    constraint write_only{ rst_n == 1; rd_en == 1; wr_en == 1;}
    constraint read_only{ rst_n == 1; rd_en == 1; wr_en == 0;}

    endclass
endpackage