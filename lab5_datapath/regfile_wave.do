onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /regfile_tb/err
add wave -noupdate /regfile_tb/sim_clk
add wave -noupdate /regfile_tb/sim_write
add wave -noupdate /regfile_tb/sim_data_in
add wave -noupdate /regfile_tb/sim_readnum
add wave -noupdate /regfile_tb/sim_writenum
add wave -noupdate /regfile_tb/sim_data_out
add wave -noupdate -divider TB
add wave -noupdate /regfile_tb/DUT/data_in
add wave -noupdate /regfile_tb/DUT/writenum
add wave -noupdate /regfile_tb/DUT/readnum
add wave -noupdate /regfile_tb/DUT/write
add wave -noupdate /regfile_tb/DUT/clk
add wave -noupdate /regfile_tb/DUT/data_out
add wave -noupdate /regfile_tb/DUT/hot_write_position
add wave -noupdate /regfile_tb/DUT/hot_read_position
add wave -noupdate -divider value_stored
add wave -noupdate /regfile_tb/DUT/value_stored0
add wave -noupdate /regfile_tb/DUT/value_stored1
add wave -noupdate /regfile_tb/DUT/value_stored2
add wave -noupdate /regfile_tb/DUT/value_stored3
add wave -noupdate /regfile_tb/DUT/value_stored4
add wave -noupdate /regfile_tb/DUT/value_stored5
add wave -noupdate /regfile_tb/DUT/value_stored6
add wave -noupdate /regfile_tb/DUT/value_stored7
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {35 ps} 0}
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
WaveRestoreZoom {16 ps} {36 ps}
