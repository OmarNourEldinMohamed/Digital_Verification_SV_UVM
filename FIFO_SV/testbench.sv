import FIFO_transaction_pkg ::*;
// import FIFO_scoreboard_pkg ::*;
// import FIFO_coverage_pkg ::*;
import shared_pkg ::*;
module FIFO_tb (FIFO_if.fifo_testbech interface_object);
    //create an object from the fifo_transaction class to randomize
    FIFO_transaction tb_object;
    initial begin
        tb_object = new();
        
        interface_object.rst_n = 0;
        @(negedge interface_object.clk);
        @(negedge interface_object.clk);
        //check write only, disable all constarints except that of write_only
        interface_object.rst_n = 1;
        tb_object.constraint_mode(0);
        tb_object.write_only.constraint_mode(1);
        //randomize inputs ==> data_in, wr_en, rd_en, rst_n
        repeat(50)begin
            assert(tb_object.randomize());
            interface_object.data_in = tb_object.data_in;
            interface_object.wr_en = tb_object.wr_en;
            interface_object.rd_en = tb_object.rd_en;
            interface_object.rst_n = tb_object.rst_n;
            @(negedge interface_object.clk);
        end

        //check read only, disable all constarints except that of read_only
        tb_object.constraint_mode(0);
        tb_object.read_only.constraint_mode(1);
        repeat(50)begin
            assert(tb_object.randomize());
            interface_object.data_in = tb_object.data_in;
            interface_object.wr_en = tb_object.wr_en;
            interface_object.rd_en = tb_object.rd_en;
            interface_object.rst_n = tb_object.rst_n;
        end

        //check for write and read , disable constarints  of read_only and write_only and enable others
        tb_object.constraint_mode(1);
        tb_object.write_only.constraint_mode(0);
        tb_object.read_only.constraint_mode(0);
        repeat(100)begin
            assert(tb_object.randomize());
            interface_object.data_in = tb_object.data_in;
            interface_object.wr_en = tb_object.wr_en;
            interface_object.rd_en = tb_object.rd_en;
            interface_object.rst_n = tb_object.rst_n;
            @(negedge interface_object.clk);
        end
        //At the end of the test, the tb will assert a signal named test_finished
        test_finished = 1;
    end
endmodule





