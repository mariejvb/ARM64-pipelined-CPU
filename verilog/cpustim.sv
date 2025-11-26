// Testbench for CPU
`timescale 1ns/10ps
module cpustim();
	
	parameter ClockDelay = 100000;
	
	logic clk, reset;
	
	// Instantiate CPU
	cpu dut (.clk, .reset);
	
	// Setup clock
	initial begin
		clk = 0;
		forever #(ClockDelay / 2) clk = ~clk;
	end
	
	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);
	
	// Test sequence
	initial begin
		// Reset system
		reset = 1;
		@(posedge clk);
		reset = 0;
		
		// Run enough cycles for the program to finish
		repeat (1000) @(posedge clk);
		
		// Display all register and data memory contents
		$display("\n---- Register File Contents ----");
		for (int i = 0; i < 32; i++) begin
			$display("Reg[%0d] = %h", i, dut.decode.rf.reg_array[i]);
		end
		
		$display("\n---- Data Memory Contents ----");
		for (int j = 0; j < 128; j = j + 8) begin
			$display("Mem[%0d] = %h%h%h%h%h%h%h%h", j,
			dut.memory.data_mem.mem[j+7],
			dut.memory.data_mem.mem[j+6],
			dut.memory.data_mem.mem[j+5],
			dut.memory.data_mem.mem[j+4],
			dut.memory.data_mem.mem[j+3],
			dut.memory.data_mem.mem[j+2],
			dut.memory.data_mem.mem[j+1],
			dut.memory.data_mem.mem[j]);
		end
		
		// Display flags
		$display("\n---- Final ALU Flags ----");
		$display("Negative:   %b", dut.flags[3]);
		$display("Zero:       %b", dut.flags[2]);
		$display("Overflow:   %b", dut.flags[1]);
		$display("Carry-out:  %b", dut.flags[0]);
		
		$stop;
	end
	
endmodule 