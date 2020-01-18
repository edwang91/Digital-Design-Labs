onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cpu_tb/reset_sim
add wave -noupdate /cpu_tb/s_sim
add wave -noupdate /cpu_tb/load_sim
add wave -noupdate /cpu_tb/err
add wave -noupdate /cpu_tb/in_sim
add wave -noupdate /cpu_tb/out_sim
add wave -noupdate /cpu_tb/DUT/DP/compute/otherout
add wave -noupdate /cpu_tb/N_sim
add wave -noupdate /cpu_tb/V_sim
add wave -noupdate /cpu_tb/Z_sim
add wave -noupdate /cpu_tb/w_sim
add wave -noupdate -divider {internal dut}
add wave -noupdate /cpu_tb/DUT/vsel
add wave -noupdate /cpu_tb/DUT/opcode
add wave -noupdate /cpu_tb/DUT/readnum
add wave -noupdate /cpu_tb/DUT/writenum
add wave -noupdate /cpu_tb/DUT/statusOut
add wave -noupdate /cpu_tb/DUT/nsel
add wave -noupdate /cpu_tb/DUT/ALUop
add wave -noupdate /cpu_tb/DUT/shift
add wave -noupdate /cpu_tb/DUT/asel
add wave -noupdate /cpu_tb/DUT/bsel
add wave -noupdate /cpu_tb/DUT/statemachine/current_state
add wave -noupdate -divider datapath
add wave -noupdate /cpu_tb/clk_sim
add wave -noupdate /cpu_tb/DUT/DP/data_to_regfile
add wave -noupdate /cpu_tb/DUT/DP/loada
add wave -noupdate /cpu_tb/DUT/DP/loadb
add wave -noupdate /cpu_tb/DUT/DP/asel
add wave -noupdate /cpu_tb/DUT/DP/bsel
add wave -noupdate /cpu_tb/DUT/DP/loadc
add wave -noupdate /cpu_tb/DUT/DP/loads
add wave -noupdate /cpu_tb/DUT/DP/write
add wave -noupdate /cpu_tb/DUT/DP/sximm8
add wave -noupdate /cpu_tb/DUT/DP/sximm5
add wave -noupdate /cpu_tb/DUT/DP/statusOut
add wave -noupdate /cpu_tb/DUT/DP/datapath_out
add wave -noupdate /cpu_tb/DUT/DP/data_out_reg
add wave -noupdate /cpu_tb/DUT/DP/data_to_shifter
add wave -noupdate /cpu_tb/DUT/DP/data_to_operandsA
add wave -noupdate /cpu_tb/DUT/DP/data_to_operandsB
add wave -noupdate /cpu_tb/DUT/DP/data_to_ALUA
add wave -noupdate /cpu_tb/DUT/DP/data_to_ALUB
add wave -noupdate /cpu_tb/DUT/DP/data_to_c
add wave -noupdate /cpu_tb/DUT/DP/data_back
add wave -noupdate -divider {instruction reg}
add wave -noupdate /cpu_tb/DUT/pass/in
add wave -noupdate /cpu_tb/DUT/pass/to_dec
add wave -noupdate /cpu_tb/DUT/pass/next_to_dec
add wave -noupdate -divider regfile
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/R0
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/R1
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/R2
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/R3
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/R4
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/R5
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/R6
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/R7
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {625 ps} 0}
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
WaveRestoreZoom {519 ps} {687 ps}
