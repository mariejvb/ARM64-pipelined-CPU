// 8:1 multiplexor
//		Inputs: in[7:0], sel[2:0]
//		Output: out
`timescale 1ps/1ps
module mux8 (in, sel, out);
	input logic [7:0] in;
	input logic [2:0] sel;
	output logic out;
	
	logic [7:0] onehot; // 8-bit onehot output from 3:8 decoder with selector input
	logic [7:0] and_terms;
	logic [1:0] or1;
	logic or2;
	
	// Decode the selector to produce onehot for selecting mux input
	dec3x8 decode_sel (.in(sel), .en(1'b1), .out(onehot));
	
	genvar i;
	generate
		// AND together the ith bit of the input with the ith bit of the onehot selector
		for (i = 0; i < 8; i++) begin : mux_bit
			and #50 (and_terms[i], in[i], onehot[i]);
		end
		
		// OR together all 8 AND terms (max 4-input gates)
		// Level 1
		or #50 (or1[0], and_terms[0],  and_terms[1],  and_terms[2],  and_terms[3]);
		or #50 (or1[1], and_terms[4],  and_terms[5],  and_terms[6],  and_terms[7]);
		// Level 2
		or #50 (or2, or1[0], or1[1]);
		
		// Assign output
		assign out = or2;
		
	endgenerate
	
endmodule 