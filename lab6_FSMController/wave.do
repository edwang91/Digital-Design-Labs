onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /lab6_check/clk
add wave -noupdate /lab6_check/reset
add wave -noupdate /lab6_check/s
add wave -noupdate /lab6_check/load
add wave -noupdate /lab6_check/in
add wave -noupdate /lab6_check/out
add wave -noupdate /lab6_check/N
add wave -noupdate /lab6_check/V
add wave -noupdate /lab6_check/Z
add wave -noupdate /lab6_check/w
add wave -noupdate /lab6_check/err
add wave -noupdate -divider datapath
add wave -noupdate /lab6_check/DUT/DP/loada
add wave -noupdate /lab6_check/DUT/DP/loadb
add wave -noupdate /lab6_check/DUT/DP/asel
add wave -noupdate /lab6_check/DUT/DP/bsel
add wave -noupdate /lab6_check/DUT/DP/loadc
add wave -noupdate /lab6_check/DUT/DP/loads
add wave -noupdate /lab6_check/DUT/DP/write
add wave -noupdate /lab6_check/DUT/DP/readnum
add wave -noupdate /lab6_check/DUT/DP/writenum
add wave -noupdate /lab6_check/DUT/DP/vsel
add wave -noupdate /lab6_check/DUT/DP/shift
add wave -noupdate /lab6_check/DUT/DP/ALUop
add wave -noupdate /lab6_check/DUT/DP/PC
add wave -noupdate /lab6_check/DUT/DP/mdata
add wave -noupdate /lab6_check/DUT/DP/sximm8
add wave -noupdate /lab6_check/DUT/DP/sximm5
add wave -noupdate /lab6_check/DUT/DP/statusOut
add wave -noupdate /lab6_check/DUT/DP/datapath_out
add wave -noupdate -divider states
add wave -noupdate /lab6_check/DUT/statemachine/current_state
add wave -noupdate /lab6_check/DUT/statemachine/next_state_reset
add wave -noupdate /lab6_check/DUT/statemachine/next_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {119 ps} 0}
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
WaveRestoreZoom {0 ps} {142 ps}
