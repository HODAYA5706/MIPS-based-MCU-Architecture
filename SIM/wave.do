onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mips_tb/clock
add wave -noupdate /mips_tb/PC
add wave -noupdate /mips_tb/Instruction_out
add wave -noupdate /mips_tb/LEDS
add wave -noupdate /mips_tb/HEX_0
add wave -noupdate /mips_tb/HEX_1
add wave -noupdate /mips_tb/HEX_2
add wave -noupdate /mips_tb/HEX_3
add wave -noupdate /mips_tb/HEX_4
add wave -noupdate /mips_tb/HEX_5
add wave -noupdate /mips_tb/SW_IN
add wave -noupdate /mips_tb/KEY_0
add wave -noupdate /mips_tb/KEY_1
add wave -noupdate /mips_tb/KEY_2
add wave -noupdate /mips_tb/KEY_3
add wave -noupdate /mips_tb/PWMout
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {51736672 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {0 ps} {32812500 ps}
