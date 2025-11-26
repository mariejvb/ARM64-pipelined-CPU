// 64-bit ALU
//		Inputs: A[63:0], B[63:0], cntrl[2:0]
//		Outputs: result[63:0], negative, zero, overflow, carry_out
//
// cntrl			Operation						Notes:
// 000:			result = B						value of overflow and carry_out unimportant
// 010:			result = A + B
// 011:			result = A - B
// 100:			result = bitwise A & B		value of overflow and carry_out unimportant
// 101:			result = bitwise A | B		value of overflow and carry_out unimportant
// 110:			result = bitwise A XOR B	value of overflow and carry_out unimportant
`timescale 1ps/1ps
module alu (A, B, cntrl, result, negative, zero, overflow, carry_out);
	input logic [63:0] A, B;
	input logic [2:0] cntrl;
	output logic [63:0] result;
	output logic negative, zero, overflow, carry_out;
	
	logic sub;
	logic [63:0] carries;
	
	// Assign sub signal to LSB of cntrl
	// 	cntrl: 010 --- add
	//		cntrl: 011 --- sub
	assign sub = cntrl[0];
	
	// 1-bit ALU instantiation for bit 0 (Cin = sub)
	alu1 lsb (.A(A[0]), .B(B[0]), .Cin(sub), .cntrl, .sub, 
				.result(result[0]), .Cout(carries[0]));
	
	genvar i;
	generate
		for (i = 1; i < 64; i++) begin : alu_bits
			// Instantiate 1-bit ALU for each of the 64 bits
			alu1 alu_inst (.A(A[i]), .B(B[i]), .Cin(carries[i-1]), .cntrl, 
								.sub, .result(result[i]), .Cout(carries[i]));
		end
	endgenerate
	
	// Carry-out is the Cout of the MSB
	assign carry_out = carries[63];

	// Overflow: carry into MSB ^ carry out of MSB
	xor #50 (overflow, carries[62], carries[63]);

	// Negative flag: MSB of result
	assign negative = result[63];
	
	// Zero flag (abstracted): NOR of all result bits
	zero_flagger zf (.result, .zero);
	
endmodule 