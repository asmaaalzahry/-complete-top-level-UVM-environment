vlib work
vlog -f list.list -mfcu +cover -covercells
vsim -voptargs=+acc work.tb_top -cover -classdebug -uvmcontrol=all
add wave /tb_top/DUT/*
coverage save top.ucdb -onexit -du work.tb_top
run -all
coverage report -detail -cvg -directive -comments -output fcover_report.txt /FIFO_coverage_pkg/FIFO_coverage/cvr_grp
quit -sim
vcover report top.ucdb -details -annotate -all -output fiforpt.txt
