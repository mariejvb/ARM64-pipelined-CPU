onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cpustim/dut/clk
add wave -noupdate /cpustim/dut/reset
add wave -noupdate -expand -group {PC Register} /cpustim/dut/fetch/PC_reg/en
add wave -noupdate -expand -group {PC Register} -radix decimal /cpustim/dut/fetch/PC_reg/d
add wave -noupdate -expand -group {PC Register} -radix decimal /cpustim/dut/fetch/PC_reg/q
add wave -noupdate -expand -group {Instruction Memory} -radix decimal /cpustim/dut/fetch/instr_mem/address
add wave -noupdate -expand -group {Instruction Memory} /cpustim/dut/fetch/instr_mem/instruction
add wave -noupdate -expand -group {Register File} /cpustim/dut/decode/rf/RegWrite
add wave -noupdate -expand -group {Register File} -radix unsigned /cpustim/dut/decode/rf/ReadRegister1
add wave -noupdate -expand -group {Register File} -radix unsigned /cpustim/dut/decode/rf/ReadRegister2
add wave -noupdate -expand -group {Register File} -radix unsigned /cpustim/dut/decode/rf/WriteRegister
add wave -noupdate -expand -group {Register File} -radix decimal /cpustim/dut/decode/rf/WriteData
add wave -noupdate -expand -group {Register File} -radix decimal /cpustim/dut/decode/rf/ReadData1
add wave -noupdate -expand -group {Register File} -radix decimal /cpustim/dut/decode/rf/ReadData2
add wave -noupdate -expand -group {Main ALU} -radix decimal /cpustim/dut/execute/main_alu/A
add wave -noupdate -expand -group {Main ALU} -radix decimal /cpustim/dut/execute/main_alu/B
add wave -noupdate -expand -group {Main ALU} /cpustim/dut/execute/main_alu/cntrl
add wave -noupdate -expand -group {Main ALU} -radix decimal /cpustim/dut/execute/main_alu/result
add wave -noupdate -expand -group {Main ALU} /cpustim/dut/execute/main_alu/negative
add wave -noupdate -expand -group {Main ALU} /cpustim/dut/execute/main_alu/zero
add wave -noupdate -expand -group {Main ALU} /cpustim/dut/execute/main_alu/overflow
add wave -noupdate -expand -group {Main ALU} /cpustim/dut/execute/main_alu/carry_out
add wave -noupdate -expand -group {Data Memory} -radix decimal /cpustim/dut/memory/data_mem/address
add wave -noupdate -expand -group {Data Memory} /cpustim/dut/memory/data_mem/write_enable
add wave -noupdate -expand -group {Data Memory} /cpustim/dut/memory/data_mem/read_enable
add wave -noupdate -expand -group {Data Memory} -radix decimal /cpustim/dut/memory/data_mem/write_data
add wave -noupdate -expand -group {Data Memory} -radix decimal /cpustim/dut/memory/data_mem/read_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {278151768 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 166
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
WaveRestoreZoom {0 ps} {1168759776 ps}
