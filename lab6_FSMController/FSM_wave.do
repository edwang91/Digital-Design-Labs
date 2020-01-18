onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /FSM_tb/clk_sim
add wave -noupdate /FSM_tb/reset_sim
add wave -noupdate /FSM_tb/err
add wave -noupdate /FSM_tb/s_sim
add wave -noupdate -divider STATES
add wave -noupdate /FSM_tb/DUT/current_state
add wave -noupdate /FSM_tb/DUT/next_state_reset
add wave -noupdate /FSM_tb/DUT/next_state
add wave -noupdate -divider Inputs/error
add wave -noupdate /FSM_tb/opcode_sim
add wave -noupdate /FSM_tb/op_sim
add wave -noupdate /FSM_tb/w_sim
add wave -noupdate /FSM_tb/asel_sim
add wave -noupdate /FSM_tb/bsel_sim
add wave -noupdate /FSM_tb/loada_sim
add wave -noupdate /FSM_tb/loadb_sim
add wave -noupdate /FSM_tb/loadc_sim
add wave -noupdate /FSM_tb/loads_sim
add wave -noupdate /FSM_tb/write_sim
add wave -noupdate /FSM_tb/vsel_sim
add wave -noupdate /FSM_tb/nsel_sim
add wave -noupdate -divider SET
add wave -noupdate /FSM_tb/PC_sim
add wave -noupdate /FSM_tb/mdata_sim
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {153 ps} 0}
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
WaveRestoreZoom {0 ps} {42 ps}
