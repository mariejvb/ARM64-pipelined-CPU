// 2:1 multiplexor
//		Inputs: i0, i1, sel
//		Outputs: out
`timescale 1ns/10ps
module mux2 #(parameter WIDTH = 64) (i0, i1, sel, out);
	input  logic [WIDTH-1:0] i0;
	input  logic [WIDTH-1:0] i1;
	input  logic sel;
	output logic [WIDTH-1:0] out;
	
	logic sel_n;
	not #50 (sel_n, sel);
	
	genvar i;
	generate
		for (i = 0; i < WIDTH; i++) begin : mux_bit
			logic a, b;
			and #50 (a, i0[i], sel_n);
			and #50 (b, i1[i], sel);
			or #50  (out[i], a, b);
		end
	endgenerate
	
endmodule 