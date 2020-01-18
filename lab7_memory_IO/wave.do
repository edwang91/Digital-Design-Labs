onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /lab7_check_tb/DUT/CPU/clk
add wave -noupdate /lab7_check_tb/KEY
add wave -noupdate /lab7_check_tb/DUT/CPU/reset
add wave -noupdate /lab7_check_tb/DUT/CPU/statemachine/current_state
add wave -noupdate /lab7_check_tb/DUT/CPU/statemachine/next_state_reset
add wave -noupdate /lab7_check_tb/DUT/CPU/statemachine/reset_PC
add wave -noupdate /lab7_check_tb/DUT/CPU/statemachine/load_PC
add wave -noupdate /lab7_check_tb/DUT/CPU/next_pc
add wave -noupdate /lab7_check_tb/DUT/CPU/PC
add wave -noupdate -divider {data address}
add wave -noupdate /lab7_check_tb/DUT/CPU/statemachine/load_addr
add wave -noupdate /lab7_check_tb/DUT/CPU/data_addr/in
add wave -noupdate /lab7_check_tb/DUT/CPU/data_addr/to_dec
add wave -noupdate /lab7_check_tb/DUT/CPU/data_addr/next_to_dec
add wave -noupdate -divider {New Divider}
add wave -noupdate /lab7_check_tb/DUT/CPU/statemachine/mem_cmd
add wave -noupdate /lab7_check_tb/DUT/CPU/statemachine/addr_sel
add wave -noupdate /lab7_check_tb/DUT/CPU/mem_addr
add wave -noupdate /lab7_check_tb/DUT/MEM/dout
add wave -noupdate /lab7_check_tb/DUT/msel
add wave -noupdate -divider trisel
add wave -noupdate /lab7_check_tb/DUT/check/load
add wave -noupdate -divider {New Divider}
add wave -noupdate /lab7_check_tb/DUT/read_data
add wave -noupdate /lab7_check_tb/DUT/CPU/statemachine/load_ir
add wave -noupdate /lab7_check_tb/DUT/ir
add wave -noupdate -divider regfile
add wave -noupdate /lab7_check_tb/DUT/CPU/DP/REGFILE/R0
add wave -noupdate /lab7_check_tb/DUT/CPU/DP/REGFILE/R1
add wave -noupdate /lab7_check_tb/DUT/CPU/DP/REGFILE/R2
add wave -noupdate /lab7_check_tb/DUT/CPU/DP/REGFILE/R3
add wave -noupdate /lab7_check_tb/DUT/CPU/DP/REGFILE/R4
add wave -noupdate /lab7_check_tb/DUT/CPU/DP/REGFILE/R5
add wave -noupdate /lab7_check_tb/DUT/CPU/DP/REGFILE/R6
add wave -noupdate /lab7_check_tb/DUT/CPU/DP/REGFILE/R7
add wave -noupdate -divider DP
add wave -noupdate /lab7_check_tb/DUT/CPU/DP/REGFILE/data_in
add wave -noupdate /lab7_check_tb/DUT/CPU/DP/datapath_out
add wave -noupdate /lab7_check_tb/DUT/CPU/DP/PC
add wave -noupdate /lab7_check_tb/DUT/CPU/DP/mdata
add wave -noupdate /lab7_check_tb/DUT/CPU/DP/sximm8
add wave -noupdate /lab7_check_tb/DUT/CPU/DP/sximm5
add wave -noupdate -divider {Instruction reg}
add wave -noupdate /lab7_check_tb/DUT/CPU/in
add wave -noupdate /lab7_check_tb/DUT/CPU/instruction_register/load
add wave -noupdate /lab7_check_tb/DUT/CPU/instruction_register/in
add wave -noupdate /lab7_check_tb/DUT/CPU/instruction_register/to_dec
add wave -noupdate /lab7_check_tb/DUT/CPU/instruction_register/next_to_dec
add wave -noupdate -divider ALU
add wave -noupdate /lab7_check_tb/DUT/CPU/DP/compute/Ain
add wave -noupdate /lab7_check_tb/DUT/CPU/DP/compute/Bin
add wave -noupdate /lab7_check_tb/DUT/CPU/DP/compute/ALUop
add wave -noupdate /lab7_check_tb/DUT/CPU/DP/compute/out
add wave -noupdate /lab7_check_tb/DUT/CPU/statemachine/loada
add wave -noupdate /lab7_check_tb/DUT/CPU/statemachine/loadb
add wave -noupdate /lab7_check_tb/DUT/CPU/statemachine/loadc
add wave -noupdate /lab7_check_tb/DUT/CPU/DP/data_to_ALUA
add wave -noupdate /lab7_check_tb/DUT/CPU/DP/data_to_ALUB
add wave -noupdate /lab7_check_tb/DUT/CPU/DP/data_to_c
add wave -noupdate /lab7_check_tb/DUT/CPU/DP/C/data_out
add wave -noupdate -divider {B A}
add wave -noupdate /lab7_check_tb/DUT/CPU/DP/Bregs/data_in
add wave -noupdate /lab7_check_tb/DUT/CPU/DP/Aregs/data_in
add wave -noupdate /lab7_check_tb/DUT/CPU/statemachine/asel
add wave -noupdate /lab7_check_tb/DUT/CPU/statemachine/bsel
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {30 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 138
configure wave -valuecolwidth 108
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
WaveRestoreZoom {248 ps} {340 ps}
