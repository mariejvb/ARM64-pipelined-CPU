// Zero extender for unsigned immediates
//		Input: in
//		Output: out
`timescale 1ns/10ps
module zero_extender #(parameter IN_WIDTH = 12) (in, out);
	input  logic [IN_WIDTH-1:0] in;
	output logic [63:0] out;
	
	genvar i;
	
	// Pass through input bits
	generate
		for (i = 0; i < IN_WIDTH; i = i +1) begin : passthrough
			and #50 (out[i], in[i], 1'b1);  // out[i] = in[i]
		end
	endgenerate
	
	// Extend upper bits with zero
	generate
		for (i = IN_WIDTH; i < 64; i = i +1) begin : extend_zero
			and #50 (out[i], 1'b0, 1'b0);  // out[i] = 0
		end
	endgenerate
	
endmodule 