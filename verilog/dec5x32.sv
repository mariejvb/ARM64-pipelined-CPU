// 5:32 decoder module
//		Inputs: [4:0] in, en
//		Output: [31:0] out
`timescale 1ps/1ps
module dec5x32 (in, en, out);
	input logic [4:0] in;
	input logic en;
	output logic [31:0] out;
	
	// Internal signal
	logic [4:0] in_inv;

	genvar i, j;
	// Invert each input bit
	generate
		for (i = 0; i < 5; i++) begin : invert_input
			not #50 inv (in_inv[i], in[i]); // 50 ps gate delay
		end
	endgenerate

	// Implement 5:32 decoder using AND gates
	generate
		for (j = 0; j < 32; j++) begin : decoder_logic
			// Create local parameter to index j's bits
			localparam [4:0] j_idx = j;
			
			logic b0, b1, b2, b3, b4;
			logic and1, and2;

			// Select either in[x] or ~in[x] based on bit pattern of i
			// Done using AND/OR/NOT (2 gates per bit)

			// Bit 0
			logic a0_1, a0_2;
			and #50 a1 (a0_1, in[0],  j_idx[0]);
			and #50 a2 (a0_2, in_inv[0], ~j_idx[0]);
			or #50 o1 (b0, a0_1, a0_2);

			// Bit 1
			logic a1_1, a1_2;
			and #50 a3 (a1_1, in[1],  j_idx[1]);
			and #50 a4 (a1_2, in_inv[1], ~j_idx[1]);
			or #50 o2 (b1, a1_1, a1_2);

			// Bit 2
			logic a2_1, a2_2;
			and #50 a5 (a2_1, in[2],  j_idx[2]);
			and #50 a6 (a2_2, in_inv[2], ~j_idx[2]);
			or #50 o3 (b2, a2_1, a2_2);

			// Bit 3
			logic a3_1, a3_2;
			and #50 a7 (a3_1, in[3],  j_idx[3]);
			and #50 a8 (a3_2, in_inv[3], ~j_idx[3]);
			or #50 o4 (b3, a3_1, a3_2);

			// Bit 4
			logic a4_1, a4_2;
			and #50 a9 (a4_1, in[4],  j_idx[4]);
			and #50 a10 (a4_2, in_inv[4], ~j_idx[4]);
			or #50 o5 (b4, a4_1, a4_2);

			// Combine with 2-level AND tree (≤4 inputs per gate)
			and #50 a11 (and1, b0, b1, b2);
			and #50 a12 (and2, and1, b3, b4);
			and #50 a13 (out[j], and2, en);
		end
	endgenerate
endmodule 

// Testbench for 5x32 decoder module
module dec5x32_tb ();
	logic [4:0] in;
	logic en;
	logic [31:0] out;
	
	dec5x32 dut (.*);
	
	initial begin
		en <= 0; #10;
		in <= 5'b00000; #10; // Input = 0
		en <= 1; #50;
		// Output = 00000000000000000000000000000001
		
		en <= 0; #10;
		in <= 5'b01010; #10; // Input = 10
		en <= 1; #50;
		// Output = 00000000000000000000010000000000
		
		en <= 0; #10;
		in <= 5'b11111; #10; // Input = 31
		en <= 1; #50;
		// Output = 10000000000000000000000000000000
		
		en <= 0; #10;
		in <= 5'b00101; #10; // Input = 5
		en <= 1; #50;
		// Output = 00000000000000000000010000100000
	$stop;
	end
endmodule 