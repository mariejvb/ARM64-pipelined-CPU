// 3:1 multiplexor
//		Inputs: i0, i1, i2, [1:0] sel
//		Outputs: out
`timescale 1ns/10ps
module mux3 #(parameter WIDTH = 64) (i0, i1, i2, sel, out);
	input logic [WIDTH-1:0] i0, i1, i2;
	input logic [1:0] sel;
	output logic [WIDTH-1:0] out;
	
	genvar i;
	generate
		for (i = 0; i < WIDTH; i++) begin : mux3_loop
			// Gate logic:
			// sel = 00 --> out = i0
			// sel = 01 --> out = i1
			// sel = 10 --> out = i2

			// Internal select wires
			logic sel_0n, sel_1n, sel_0_and_1n, sel_0n_and_1;

			not #50 not_sel0 (sel_0n, sel[0]);
			not #50 not_sel1 (sel_1n, sel[1]);

			// AND gates for each case
			logic i0_path, i1_path, i2_path;

			// i0 selected if sel == 00
			and #50 and_i0 (i0_path, sel_1n, sel_0n, i0[i]);

			// i1 selected if sel == 01
			and #50 and_i1 (i1_path, sel_1n, sel[0], i1[i]);

			// i2 selected if sel == 10
			and #50 and_i2 (i2_path, sel[1], sel_0n, i2[i]);

			// Combine all paths
			or #50 or_final (out[i], i0_path, i1_path, i2_path);
		end
	endgenerate
	
endmodule 