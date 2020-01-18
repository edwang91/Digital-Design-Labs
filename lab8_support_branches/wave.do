onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /lab8_check_tb/DUT/CLOCK_50
add wave -noupdate {/lab8_check_tb/DUT/KEY[1]}
add wave -noupdate {/lab8_check_tb/LEDR[8]}
add wave -noupdate /lab8_check_tb/DUT/CPU/stats
add wave -noupdate /lab8_check_tb/DUT/CPU/DP/Z
add wave -noupdate /lab8_check_tb/DUT/CPU/DP/N
add wave -noupdate /lab8_check_tb/DUT/CPU/DP/V
add wave -noupdate /lab8_check_tb/DUT/CPU/DP/compute/Ain
add wave -noupdate /lab8_check_tb/DUT/CPU/DP/compute/Bin
add wave -noupdate /lab8_check_tb/DUT/CPU/DP/status/statusOut
add wave -noupdate /lab8_check_tb/DUT/out
add wave -noupdate /lab8_check_tb/DUT/dout
add wave -noupdate /lab8_check_tb/DUT/from_RAM
add wave -noupdate /lab8_check_tb/DUT/from_SW
add wave -noupdate /lab8_check_tb/DUT/read_data
add wave -noupdate /lab8_check_tb/DUT/mem_addr_top
add wave -noupdate /lab8_check_tb/DUT/mem_cmd_top
add wave -noupdate -divider FSM
add wave -noupdate /lab8_check_tb/DUT/CPU/FSM/p
add wave -noupdate /lab8_check_tb/DUT/CPU/FSM/next_state_reset
add wave -noupdate /lab8_check_tb/DUT/CPU/FSM/next_state
add wave -noupdate -divider RAM/PC
add wave -noupdate -radixenum numeric /lab8_check_tb/DUT/MEM/mem
add wave -noupdate /lab8_check_tb/DUT/CPU/next_pc
add wave -noupdate /lab8_check_tb/DUT/CPU/PC
add wave -noupdate /lab8_check_tb/DUT/CPU/load_PC
add wave -noupdate /lab8_check_tb/DUT/CPU/load_sx
add wave -noupdate /lab8_check_tb/DUT/CPU/opcode
add wave -noupdate /lab8_check_tb/DUT/CPU/cond
add wave -noupdate /lab8_check_tb/DUT/CPU/ALUop
add wave -noupdate /lab8_check_tb/DUT/MEM/din
add wave -noupdate /lab8_check_tb/DUT/MEM/dout
add wave -noupdate /lab8_check_tb/DUT/CPU/DP/REGFILE/R0
add wave -noupdate /lab8_check_tb/DUT/CPU/DP/REGFILE/R1
add wave -noupdate /lab8_check_tb/DUT/CPU/DP/REGFILE/R2
add wave -noupdate /lab8_check_tb/DUT/CPU/DP/REGFILE/R3
add wave -noupdate /lab8_check_tb/DUT/CPU/DP/REGFILE/R4
add wave -noupdate /lab8_check_tb/DUT/CPU/DP/REGFILE/R5
add wave -noupdate /lab8_check_tb/DUT/CPU/DP/REGFILE/R6
add wave -noupdate /lab8_check_tb/DUT/CPU/DP/REGFILE/R7
add wave -noupdate /lab8_check_tb/DUT/CPU/DP/datapath_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2168 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 168
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
WaveRestoreZoom {2234 ps} {2383 ps}
