module TOP;
    bit clk;
    initial begin
        clk = 0;
        forever begin
            #50 clk =~ clk;
        end
    end
        FIFO_if interface_object(clk);
        FIFO fifo_dut (interface_object);
        FIFO_tb fifo_testbech (interface_object);
        FIFO_monitor fifo_monitor (interface_object);
endmodule