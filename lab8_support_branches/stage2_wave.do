onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /lab8_stage2_tb/err
add wave -noupdate /lab8_stage2_tb/CLOCK_50
add wave -noupdate /lab8_stage2_tb/break
add wave -noupdate /lab8_stage2_tb/DUT/CPU/FSM/p
add wave -noupdate /lab8_stage2_tb/DUT/CPU/FSM/next_state_reset
add wave -noupdate -divider watch
add wave -noupdate /lab8_stage2_tb/DUT/dout
add wave -noupdate /lab8_stage2_tb/DUT/mem_addr_top
add wave -noupdate /lab8_stage2_tb/DUT/mem_cmd_top
add wave -noupdate -divider DP
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/datapath_out
add wave -noupdate /lab8_stage2_tb/DUT/CPU/FSM/nsel
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/readnum
add wave -noupdate /lab8_stage2_tb/DUT/CPU/write
add wave -noupdate /lab8_stage2_tb/DUT/CPU/opcode
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/data_out_reg
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/data_to_ALUB
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/data_to_c
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/data_back
add wave -noupdate -divider DP
add wave -noupdate /lab8_stage2_tb/DUT/CPU/next_pc
add wave -noupdate /lab8_stage2_tb/DUT/CPU/PC
add wave -noupdate /lab8_stage2_tb/DUT/CPU/PC_indata
add wave -noupdate /lab8_stage2_tb/DUT/CPU/load_PC
add wave -noupdate /lab8_stage2_tb/DUT/CPU/ALUop
add wave -noupdate /lab8_stage2_tb/DUT/CPU/loada
add wave -noupdate /lab8_stage2_tb/DUT/CPU/loadb
add wave -noupdate /lab8_stage2_tb/DUT/CPU/loadc
add wave -noupdate /lab8_stage2_tb/DUT/CPU/addr_sel
add wave -noupdate /lab8_stage2_tb/DUT/CPU/load_addr
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/writenum
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/sximm5
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/sximm8
add wave -noupdate /lab8_stage2_tb/DUT/CPU/decode/regout
add wave -noupdate /lab8_stage2_tb/DUT/CPU/load_sx
add wave -noupdate /lab8_stage2_tb/DUT/CPU/load_r7
add wave -noupdate -divider regfile
add wave -noupdate /lab8_stage2_tb/DUT/MEM/mem
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/REGFILE/R0
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/REGFILE/R1
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/REGFILE/R2
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/REGFILE/R3
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/REGFILE/R4
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/REGFILE/R5
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/REGFILE/R6
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/REGFILE/R7
add wave -noupdate /lab8_stage2_tb/break
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/vsel
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/PC
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/REGFILE/data_in
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/shift
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {611 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 131
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
WaveRestoreZoom {1463 ps} {1723 ps}
