package FIFO_coverage_pkg;
    //import the prev pkg(FIFO_transaction_pkg)
    import FIFO_transaction_pkg ::*;

    class FIFO_coverage;
        //object from the FIFO_transaction class
        FIFO_transaction F_cvg_txn = new();
        //function with no return value
        function void sample_data (input FIFO_transaction F_txn);
            F_cvg_txn = F_txn;
            cover_group.sample();
        endfunction

        covergroup cover_group;
            //coverpoints to be used in the cross coverage
            //the coverage needed is cross coverage between 3 signals which are write enable, read enable and each output control signals
            //except outputs except data_out
            //wr_ack, overflow, full, empty, almostfull, almostempty, underflow
            wr_en_cover_point:coverpoint F_cvg_txn.wr_en;
            rd_en_cover_point:coverpoint F_cvg_txn.rd_en;
            wr_ack_cover_point:coverpoint F_cvg_txn.wr_ack;
            overflow_cover_point:coverpoint F_cvg_txn.overflow;
            full_cover_point:coverpoint F_cvg_txn.full;
            empty_cover_point:coverpoint F_cvg_txn.empty;
            almostfull_cover_point:coverpoint F_cvg_txn.almostfull;
            almostempty_cover_point:coverpoint F_cvg_txn.almostempty;
            underflow_cover_point:coverpoint F_cvg_txn.underflow;
            //cross coverage to make sure that all combinations of (write and read enable) took place 
            //in all state of the FIFO ==> with all o/p except d_out.
            //then we make 7 cross coverages(7 outputs, each o/p indivdually with both the wr_en and rd_en)
            //since, all coverpoints are 1 bit the bins will have only two states 0 or 1
            //bin{1} will be the high state
            wr_en_rd_en_wr_ack:cross wr_en_cover_point, rd_en_cover_point, wr_ack_cover_point {
                ignore_bins wr_en_low_wr_ack_high = !binsof(wr_en_cover_point) intersect{1} && binsof(wr_ack_cover_point) intersect{1};
                ignore_bins read_write_active_with_wr_ack = ! binsof(wr_en_cover_point) intersect {1} && binsof(rd_en_cover_point) intersect {1} && binsof(wr_ack_cover_point) intersect {1};
            }
            wr_en_rd_en_overflow:cross wr_en_cover_point, rd_en_cover_point, overflow_cover_point {
                ignore_bins wr_en_low_overflow_high = !binsof(wr_en_cover_point) intersect{1} && binsof(overflow_cover_point) intersect{1};
            }
            wr_en_rd_en_full:cross wr_en_cover_point, rd_en_cover_point, full_cover_point {
                ignore_bins wr_en_low_full_high = !binsof(wr_en_cover_point) intersect{1} && binsof(full_cover_point) intersect{1};
                ignore_bins rd_en_high_full_high = binsof(rd_en_cover_point) intersect{1} && binsof(full_cover_point) intersect{1};
            }
            wr_en_rd_en_empty:cross wr_en_cover_point, rd_en_cover_point, empty_cover_point{
                ignore_bins rd_en_low_empty_high = !binsof(rd_en_cover_point) intersect{1} && binsof(empty_cover_point) intersect{1};
                ignore_bins wr_en_low_empty_high = !binsof(wr_en_cover_point) intersect{1} && binsof(empty_cover_point) intersect{1};
            }
            wr_en_rd_en_almostfull:cross wr_en_cover_point, rd_en_cover_point, almostfull_cover_point{
                ignore_bins wr_en_low_almostfull_high = !binsof(wr_en_cover_point) intersect{1} && binsof(almostfull_cover_point) intersect{1};
            }
            wr_en_rd_en_almostempty:cross wr_en_cover_point, rd_en_cover_point, almostempty_cover_point{
                ignore_bins rd_en_low_almostempty_high = !binsof(rd_en_cover_point) intersect{1} && binsof(almostempty_cover_point) intersect{1};
                ignore_bins we_en_low_rd_en_high_almostempty_high = !binsof(wr_en_cover_point) intersect{1} && binsof(rd_en_cover_point) intersect{1} && binsof(almostempty_cover_point) intersect{1};

            }
            wr_en_rd_en_underflow:cross wr_en_cover_point, rd_en_cover_point, underflow_cover_point {
                ignore_bins rd_en_low_underflow_high = !binsof(rd_en_cover_point) intersect{1} && binsof(underflow_cover_point) intersect{1};
                ignore_bins wr_en_high_underflow_high = !binsof(wr_en_cover_point) intersect{1} && binsof(underflow_cover_point) intersect{1};
            }
        endgroup

        function new();
            cover_group = new();
            //F_cvg_txn = new();
        endfunction
    endclass
endpackage




            




            


            


