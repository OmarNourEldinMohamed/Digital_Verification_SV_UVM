import FIFO_transaction_pkg ::*;
import FIFO_scoreboard_pkg ::*;
import FIFO_coverage_pkg ::*;
import shared_pkg ::*;

module FIFO_monitor(FIFO_if.fifoMonitor interface_object);
    //object from each class
    FIFO_transaction trans_object;
    FIFO_scoreboard score_object;
    FIFO_coverage cove_object;
    initial begin
        trans_object = new();
        score_object = new();
        cove_object = new();
        forever begin
            @(negedge interface_object.clk); //interface clk
            //sample the data of the interface and assign it to the data of the object of class FIFO_transaction
            //data_in, wr_en, rd_en, rst_n, full, empty, almostfull, almostempty, wr_ack, overflow, underflow, data_out
            trans_object.data_in = interface_object.data_in;
            trans_object.wr_en = interface_object.wr_en;
            trans_object.rd_en = interface_object.rd_en;
            trans_object.rst_n = interface_object.rst_n;
            trans_object.full = interface_object.full;
            trans_object.empty = interface_object.empty;
            trans_object.almostfull = interface_object.almostfull;
            trans_object.almostempty = interface_object.almostempty;
            trans_object.wr_ack = interface_object.wr_ack;
            trans_object.overflow = interface_object.overflow;
            trans_object.underflow = interface_object.underflow;
            trans_object.data_out = interface_object.data_out;

            fork
                begin //first one is calling a method named sample_data of the object of class FIFO_coverage
                    cove_object.sample_data(trans_object);
                end
                begin //second process is calling a method named check_data of the object of class FIFO_scoreboard
                    @(posedge interface_object.clk) //checking should happen at the posedge
                    //delay of 20 ms to gaurantee that the o/p is changed at the posedge before checking
                    #20;
                    score_object.check_data(trans_object);
                end
            join
                if(test_finished) begin
                    $display("final values are ==> %p", score_object.fifo);
                    $display("error counter ==> %d, correct counter ==> %d", error_count, correct_count);
                    $stop;
                end
        end
    end
endmodule