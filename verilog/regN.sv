// N-bit register
//		Inputs: clk, reset, en, [N-1:0] d
//		Output: [N-1:0] q
`timescale 1ns/10ps
module regN #(parameter N = 4) (clk, reset, en, d, q);
	input  logic clk, reset, en;
	input  logic [N-1:0] d;
	output logic [N-1:0] q;
	
	logic [N-1:0] gated_d;
	
	genvar i;
	generate
		for (i = 0; i < N; i++) begin : reg_loop
			and #50 (gated_d[i], d[i], en);
			D_FF dff_inst (.q(q[i]), .d(gated_d[i]), .reset, .clk, .en);
		end
	endgenerate
	
endmodule
