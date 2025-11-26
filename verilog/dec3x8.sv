// 3:8 decoder
//		Inputs [2:0] in, en
//		Output: [7:0] out
`timescale 1ps/1ps
module dec3x8 (in, en, out);
	input logic [2:0] in;
	input logic en;
	output logic [7:0] out;
	
	// Internal signal
	logic [2:0] in_inv;

	genvar i, j;
	
	// Invert each input bit
	generate
		for (i = 0; i < 3; i++) begin : invert_input
			not #50 (in_inv[i], in[i]);
		end
	endgenerate

	// Implement 3:8 decoder using AND gates
	generate
		for (j = 0; j < 8; j++) begin : decoder_logic
			// Create local parameter to index j's bits
			localparam [2:0] j_idx = j;
			
			logic b0, b1, b2; // OR results
			logic and1;

			// Check if the 3-bit input matches the decimal index of the output.
			// If so, set the bit at that index to 1; the rest remain 0.

			// Bit 0: check in[0] = j[0]
			logic a0_1, a0_2; // store AND results
			and #50 (a0_1, in[0],  j_idx[0]);
			and #50 (a0_2, ~in[0], ~j_idx[0]);
			or #50 (b0, a0_1, a0_2);

			// Bit 1: check in[1] = j[1] 
			logic a1_1, a1_2;
			and #50 (a1_1, in[1],  j_idx[1]);
			and #50 (a1_2, ~in[1], ~j_idx[1]);
			or #50 (b1, a1_1, a1_2);

			// Bit 2: check in[2] = j[2]
			logic a2_1, a2_2;
			and #50 (a2_1, in[2],  j_idx[2]);
			and #50 (a2_2, ~in[2], ~j_idx[2]);
			or #50 (b2, a2_1, a2_2);

			// Combine with 2-level AND tree (max 4-input gates)
			and #50 (and1, b0, b1, b2);
			and #50 (out[j], and1, en); // out[j] = 1 if input matches j
		end
	endgenerate
	
endmodule 