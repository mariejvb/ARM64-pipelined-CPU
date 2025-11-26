// 1-bit adder
//		Inputs: A, B, Cin
//		Outputs: sum, Cout
`timescale 1ps/1ps
module adder1 (A, B, Cin, sum, Cout);
	input logic A, B, Cin;
	output logic sum, Cout;
	
	logic [2:0] and_terms;
	
	// Sum = A XOR B XOR C
	xor #50 (sum, A, B, Cin);
	
	// Co = (A * B) * (A * Ci) * (B * Ci)
	and #50 (and_terms[0], A, B);
	and #50 (and_terms[1], A, Cin);
	and #50 (and_terms[2], B, Cin);
	or #50 (Cout, and_terms[0], and_terms[1], and_terms[2]);
	
endmodule 