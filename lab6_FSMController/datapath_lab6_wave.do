onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /datapath_tb/sim_clk
add wave -noupdate /datapath_tb/err
add wave -noupdate /datapath_tb/sim_datapath_out
add wave -noupdate /datapath_tb/sim_statusOut
add wave -noupdate -divider Outputs/Errors
add wave -noupdate /datapath_tb/sim_vsel
add wave -noupdate /datapath_tb/sim_loada
add wave -noupdate /datapath_tb/sim_loadb
add wave -noupdate /datapath_tb/sim_asel
add wave -noupdate /datapath_tb/sim_bsel
add wave -noupdate /datapath_tb/sim_loadc
add wave -noupdate /datapath_tb/sim_loads
add wave -noupdate /datapath_tb/sim_write
add wave -noupdate /datapath_tb/sim_readnum
add wave -noupdate /datapath_tb/sim_writenum
add wave -noupdate /datapath_tb/sim_shift
add wave -noupdate /datapath_tb/sim_ALUop
add wave -noupdate -divider {Input Signals}
add wave -noupdate /datapath_tb/sim_sximm8
add wave -noupdate -divider {internal outputs}
add wave -noupdate /datapath_tb/DUT/compute/out
add wave -noupdate /datapath_tb/DUT/data_out_reg
add wave -noupdate /datapath_tb/DUT/data_to_regfile
add wave -noupdate /datapath_tb/DUT/data_to_shifter
add wave -noupdate /datapath_tb/DUT/data_to_operandsA
add wave -noupdate /datapath_tb/DUT/data_to_operandsB
add wave -noupdate /datapath_tb/DUT/data_to_ALUA
add wave -noupdate /datapath_tb/DUT/data_to_ALUB
add wave -noupdate /datapath_tb/DUT/data_to_c
add wave -noupdate /datapath_tb/DUT/data_back
add wave -noupdate -divider addsub
add wave -noupdate /datapath_tb/DUT/compute/checkOverflow/ovf
add wave -noupdate /datapath_tb/DUT/compute/checkOverflow/c1
add wave -noupdate /datapath_tb/DUT/compute/checkOverflow/c2
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {120 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {101 ps} {185 ps}
