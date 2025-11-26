// 1-bit ALU
//		Inputs: A, B, Cin, cntrl, sub
//		Outputs: result, Cout
`timescale 1ps/1ps
module alu1 (A, B, Cin, cntrl, sub, result, Cout);
	input logic A, B, Cin, sub;
	input logic [2:0] cntrl;
	output logic result, Cout;
	
	logic B_sub;
	logic sum;
	logic and_out, or_out, xor_out;
	logic [7:0] ops;

	// Negate B if sub = 1
	xor #50 (B_sub, B, sub);

	// 1-bit adder instantiation
	adder1 adder_inst (.A, .B(B_sub), .Cin, .sum, .Cout);

	// Bitwise logic
	and #50 (and_out, A, B);
	or  #50 (or_out,  A, B);
	xor #50 (xor_out, A, B);

	// Build the operation vector in gate-level style (no vector assignment)
	assign ops[0] = B;         // 000: result = B
	assign ops[1] = 1'b0;      // 001: unused
	assign ops[2] = sum;       // 010: A + B
	assign ops[3] = sum;       // 011: A - B
	assign ops[4] = and_out;   // 100: A & B
	assign ops[5] = or_out;    // 101: A | B
	assign ops[6] = xor_out;   // 110: A ^ B
	assign ops[7] = 1'b0;      // 111: unused

	// Use your gate-level mux8
	mux8 result_mux (.in(ops), .sel(cntrl), .out(result));
	
endmodule 