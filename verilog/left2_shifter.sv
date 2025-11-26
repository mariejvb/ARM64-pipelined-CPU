// Left 2 shifter (multiplication by 4)
//		Input: in
//		Output: out
`timescale 1ns/10ps
module left2_shifter (in, out);
	input  logic [63:0] in;
	output logic [63:0] out;
	
	genvar i;
	generate
		for (i = 2; i < 64; i = i +1) begin : shift
			and #50 (out[i], in[i-2], 1'b1);  // just copies in[i-2]
		end
	endgenerate
	
	// hardwire low bits to 0
	and #50 (out[0], 1'b0, 1'b0);
	and #50 (out[1], 1'b0, 1'b0);
	
endmodule 