package FIFO_scoreboard_pkg;
    //import the prev pkg(FIFO_transaction_pkg)
    import FIFO_transaction_pkg ::*;
    //import the shared pkg
    import shared_pkg ::*;

    class FIFO_scoreboard;
        //parameters:
        parameter FIFO_WIDTH = 16;
        parameter FIFO_DEPTH = 8;
        //outputs
        bit [FIFO_WIDTH-1:0]data_out_ref;
        bit wr_ack_ref, overflow_ref, full_ref, empty_ref, almostfull_ref, almostempty_ref, underflow_ref;

        //counter that will be used in determining full, empty, almostfull, almostempty in the queue
        int counter;
        bit [FIFO_WIDTH-1:0] fifo[$]; //$ ==> means that this is a dynamic array which can be modified during runtime
        //object from the FIFO_transaction class
        FIFO_transaction dut_object = new();
        //function to assign the combinational outputs of type void
        //full, empty, almostfull, almostempty ==> the refrence model
        function void combinational_outputs();
            full_ref = (counter == FIFO_DEPTH)? 1:0;
            empty_ref = (counter == 0)? 1:0;
            almostfull_ref = (counter == FIFO_DEPTH-1)? 1:0;
            almostempty_ref = (counter == 1)? 1:0;
        endfunction

        
        //check data function to compare the dut and ref models
        function void check_data(input FIFO_transaction dut_object);
            
            //for simplicity in comparing dut and ref , the flags are concatenated
            logic[6:0] dut_flags;
            logic[6:0] ref_flags;

            refrence_model(dut_object);
            //wr_ack_ref, overflow_ref, full_ref, empty_ref, almostfull_ref, almostempty_ref, underflow_ref
            dut_flags = {dut_object.wr_ack, dut_object.overflow, dut_object.full, dut_object.empty, dut_object.almostfull, dut_object.almostempty, dut_object.underflow};
            ref_flags = {wr_ack_ref, overflow_ref, full_ref, empty_ref, almostfull_ref, almostempty_ref, underflow_ref};
            if ((dut_object.data_out != data_out_ref) || (dut_flags != ref_flags)) begin
                $display("DUT is NOT EQUAL REF AT TIME = %t", $time);
                error_count++;
            end
            else begin
                correct_count++;
                $display( "WELL DONE, The FIFO = %p",fifo);
            end
        endfunction
        //refrence model function with type void
        function refrence_model(input FIFO_transaction ref_object);
            //fork join will be used to make read and write occur in parallel and then in Join counter will be updated 
            fork 
                begin 
                    //write operation
                    if (!ref_object.rst_n)begin
                        wr_ack_ref = 0;
                        //data_out_ref = 0;
                        overflow_ref = 0;
                        full_ref = 0;
                        //empty_ref = 1;//rst will not clear the fifo contents 
                        almostfull_ref = 0;
                        //almostempty_ref = 0;
                        //underflow_ref = 0;
                        fifo.delete();
                    end
                    else if (ref_object.wr_en && counter < ref_object.FIFO_DEPTH)begin
                        wr_ack_ref = 1;
                        fifo.push_back(ref_object.data_in);
                    end
                    else begin
                        wr_ack_ref = 0;
                        if (ref_object.wr_en && full_ref) overflow_ref = 1;
                        else overflow_ref = 0;
                    end
                end //end write
                begin
                    //read operation
                    if (!ref_object.rst_n)begin
                        //wr_ack_ref = 0;
                        data_out_ref = 0;
                        //overflow_ref = 0;
                        //full_ref = 0;
                        empty_ref = 1;//rest will not clear the fifo contents 
                        //almostfull_ref = 0;
                        almostempty_ref = 0;
                        underflow_ref = 0;
                        //fifo.delete();
                    end
                    else if (ref_object.rd_en && counter != 0) 
                        data_out_ref = fifo.pop_front();
                    else begin
                        if (ref_object.rd_en && empty_ref) underflow_ref = 1;
                        else underflow_ref = 0;
                    end
                end
            join
                if(!ref_object.rst_n) counter = 0;

            //counter will be updated, after the read and write operations took place 
            //it will be updated depending on the states of the fifo 
                
                    else if (ref_object.wr_en && !ref_object.rd_en && !full_ref) counter++; //write 
                    else if (!ref_object.wr_en && ref_object.rd_en && !empty_ref) counter--; //read
                    else if (ref_object.wr_en && ref_object.rd_en && full_ref) counter--; //read as the fifo is full
                    else if (ref_object.wr_en && ref_object.rd_en && empty_ref) counter++; //write as the fifo is empty
                
                //to updeate the combinational 
                combinational_outputs();
        endfunction
    endclass
endpackage