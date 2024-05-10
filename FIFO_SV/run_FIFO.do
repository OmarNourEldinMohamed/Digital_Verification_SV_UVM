vlog -f src_files.list -mfcu +define+SIM +cover
vsim -voptargs=+acc work.TOP -cover 
add wave *
coverage save fifocoveragereport.ucdb -onexit -du work.TOP
run -all
coverage report -detail -cvg -directive -comments -output fcover_report.txt /FIFO_coverage_pkg/FIFO_coverage/cover_group
#quit -sim
vcover report fifocoveragereport.ucdb -details -annotate -all -output fifocoveragereport.txt
