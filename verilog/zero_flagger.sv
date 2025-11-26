// Set zero flag if result is zero
//		Input: result[63:0]
//		Output: zero
`timescale 1ps/1ps
module zero_flagger (result, zero);
	input logic [63:0] result;
	output logic zero;
	
	logic [15:0] or16;
	logic [3:0] or4;
	logic or_final;

	genvar i;
	generate
		for (i = 0; i < 16; i++) begin : or_lvl1
			or #50 (or16[i],
				result[i*4 + 0], result[i*4 + 1], result[i*4 + 2], result[i*4 + 3]);
		end
	endgenerate

	// Level 2: combine to 4 ORs
	or #50 (or4[0], or16[0], or16[1], or16[2], or16[3]);
	or #50 (or4[1], or16[4], or16[5], or16[6], or16[7]);
	or #50 (or4[2], or16[8], or16[9], or16[10], or16[11]);
	or #50 (or4[3], or16[12], or16[13], or16[14], or16[15]);

	// Level 3: final OR and NOT
	or  #50 (or_final, or4[0], or4[1], or4[2], or4[3]);
	not #50 (zero, or_final);
	
endmodule 
