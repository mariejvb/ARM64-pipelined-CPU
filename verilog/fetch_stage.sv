// Fetch Stage
//		Inputs: clk, reset, branch_taken, [63:0] next_PC
//		Outputs: [63:0] PC, [63:0] PC_plus4, [31:0] instruction
`timescale 1ns/10ps
module fetch_stage (
	input logic clk, reset,
	input logic branch_taken,
	input logic [63:0] next_PC,
	input logic PC_enable,
	output logic [63:0] PC, PC_plus4,
	output logic [31:0] instruction
);
	// PC register
	reg64 PC_reg (.clk, .reset, .en(PC_enable), .d(next_PC), .q(PC));
	
	// Instruction memory
	instructmem instr_mem (.address(PC), .instruction, .clk);
	
	// PC + 4 adder
	alu PC_plus4_adder (.A(PC), .B(64'd4), .cntrl(3'b010), .result(PC_plus4),
                         .negative(), .zero(), .overflow(), .carry_out());
	
endmodule 