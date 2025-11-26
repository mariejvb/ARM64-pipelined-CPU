// 64-bit register module
//		Inputs: clk, reset, en, [63:0] d
//		Output: [63:0] q
`timescale 1ps/1ps
module reg64 (clk, reset, en, d, q);
	input logic clk, reset, en;
	input logic [63:0] d;
	output logic [63:0] q;
	
	genvar i;
	generate
		for (i = 0; i < 64; i++) begin : dffx64
			// Internal wires for this bit's logic
			logic d_gated, q_gated, d_final;
			logic not_en;
			logic q_internal;

			// Inverter for enable
			not #50 inv_en (not_en, en);

			// Gate the input data with enable
			and #50 and_d (d_gated, d[i], en);

			// Gate the stored value with NOT enable
			and #50 and_q (q_gated, q_internal, not_en);

			// OR gate to select between old and new value
			or #50 or_sel (d_final, d_gated, q_gated);

			// Flip-flop instantiation
			D_FF dff_inst (.q(q_internal), .d(d_final), .reset(reset), .clk(clk), .en);

			// Connect final output
			assign q[i] = q_internal;
		end
	endgenerate
endmodule 

// Testbench for 64-bit register module
module reg64_tb ();
	logic clk, reset, en;
	logic [63:0] d, q;
	
	reg64 dut (.*);
	
	// Generate clock with 100 ps period
	parameter clk_period = 100;
	initial begin
		clk <= 0;
		forever #(clk_period/2) clk <= ~clk;
	end
	
	initial begin
		reset <= 1; en <= 0; @(posedge clk);
		reset <= 0; @(posedge clk);
		
		d <= 64'd500; @(posedge clk);
		en <= 1; @(posedge clk);
		
		en <= 0; @(posedge clk);
		
		d <= 64'd1234; @(posedge clk);
		en <= 1; @(posedge clk);
		
		en <= 0; @(posedge clk);
		
	$stop;
	end
endmodule 