// D flip-flop module (provided in lab specification, do not alter)
//		Inputs: d, reset, clk, en
//		Output: q
module D_FF (q, d, reset, clk, en);
	output reg q; 
	input d, reset, clk, en;
	
	always_ff @(posedge clk) 
		if (reset) 
			q <= 0; // On reset, set to 0 
		else if (en)
			q <= d; // Otherwise in enabled, out = d 
endmodule 