// 64x32:1 multiplexor
//		Inputs: [63:0][31:0] in, [4:0] sel
//		Output: [63:0] out
`timescale 1ps/1ps
module mux32(in, sel, out);
	input logic [63:0] in[31:0];
	input logic [4:0] sel;
	output logic [63:0] out;
	
	logic [31:0] onehot; // 32-bit onehot output from 5:32 decoder with selector input
	logic or1 [7:0];
	logic or2 [1:0];
	logic or3;
	
	// Decode the selector to produce onehot for selecting mux input
	dec5x32 decode_sel (.in(sel), .en(1'b1), .out(onehot));

	genvar i, j;
	generate
		for (i = 0; i < 64; i++) begin : mux_bit
			logic [31:0] and_terms;
			for (j = 0; j < 32; j++) begin : build_ands
				// AND together the ith bit of the jth 64-bit input with the 
				// jth bit of the decoder output
				and #50 andbit(and_terms[j], in[j][i], onehot[j]);
			end

			// Combine using 4-input OR gates
			logic or1 [7:0];
			logic or2 [1:0];
			logic or3;

			// OR together all 32 AND terms
			or #50 (or1[0], and_terms[0],  and_terms[1],  and_terms[2],  and_terms[3]);
			or #50 (or1[1], and_terms[4],  and_terms[5],  and_terms[6],  and_terms[7]);
			or #50 (or1[2], and_terms[8],  and_terms[9],  and_terms[10], and_terms[11]);
			or #50 (or1[3], and_terms[12], and_terms[13], and_terms[14], and_terms[15]);
			or #50 (or1[4], and_terms[16], and_terms[17], and_terms[18], and_terms[19]);
			or #50 (or1[5], and_terms[20], and_terms[21], and_terms[22], and_terms[23]);
			or #50 (or1[6], and_terms[24], and_terms[25], and_terms[26], and_terms[27]);
			or #50 (or1[7], and_terms[28], and_terms[29], and_terms[30], and_terms[31]);

			or #50 (or2[0], or1[0], or1[1], or1[2], or1[3]);
			or #50 (or2[1], or1[4], or1[5], or1[6], or1[7]);

			or #50 (or3, or2[0], or2[1]);

			assign out[i] = or3;
		end
	endgenerate
endmodule 