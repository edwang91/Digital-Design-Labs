onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cpu_tb/clk_sim
add wave -noupdate /cpu_tb/reset_sim
add wave -noupdate /cpu_tb/err
add wave -noupdate /cpu_tb/in_sim
add wave -noupdate /cpu_tb/out_sim
add wave -noupdate /cpu_tb/mem_addr_sim
add wave -noupdate /cpu_tb/N_sim
add wave -noupdate /cpu_tb/V_sim
add wave -noupdate /cpu_tb/Z_sim
add wave -noupdate -divider {Regfile regs}
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/R0
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/R1
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/R2
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/R3
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/R4
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/R5
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/R6
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/R7
add wave -noupdate -divider FSM
add wave -noupdate /cpu_tb/DUT/statemachine/opcode
add wave -noupdate /cpu_tb/DUT/statemachine/op
add wave -noupdate /cpu_tb/DUT/statemachine/asel
add wave -noupdate /cpu_tb/DUT/statemachine/bsel
add wave -noupdate /cpu_tb/DUT/statemachine/loada
add wave -noupdate /cpu_tb/DUT/statemachine/loadb
add wave -noupdate /cpu_tb/DUT/statemachine/loadc
add wave -noupdate /cpu_tb/DUT/statemachine/loads
add wave -noupdate /cpu_tb/DUT/statemachine/write
add wave -noupdate /cpu_tb/DUT/statemachine/load_ir
add wave -noupdate /cpu_tb/DUT/statemachine/load_PC
add wave -noupdate /cpu_tb/DUT/statemachine/addr_sel
add wave -noupdate /cpu_tb/DUT/statemachine/load_addr
add wave -noupdate /cpu_tb/DUT/statemachine/reset_PC
add wave -noupdate /cpu_tb/DUT/statemachine/mem_cmd
add wave -noupdate /cpu_tb/DUT/statemachine/vsel
add wave -noupdate /cpu_tb/DUT/statemachine/nsel
add wave -noupdate /cpu_tb/DUT/statemachine/mdata
add wave -noupdate /cpu_tb/DUT/statemachine/current_state
add wave -noupdate -divider datapath
add wave -noupdate /cpu_tb/DUT/DP/statusOut
add wave -noupdate /cpu_tb/DUT/DP/datapath_out
add wave -noupdate /cpu_tb/DUT/DP/data_out_reg
add wave -noupdate /cpu_tb/DUT/DP/data_to_regfile
add wave -noupdate /cpu_tb/DUT/DP/data_to_shifter
add wave -noupdate /cpu_tb/DUT/DP/data_to_operandsA
add wave -noupdate /cpu_tb/DUT/DP/data_to_operandsB
add wave -noupdate /cpu_tb/DUT/DP/data_to_ALUA
add wave -noupdate /cpu_tb/DUT/DP/data_to_ALUB
add wave -noupdate /cpu_tb/DUT/DP/data_to_c
add wave -noupdate /cpu_tb/DUT/DP/data_back
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1629 ps} 0}
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
WaveRestoreZoom {1480 ps} {1638 ps}
