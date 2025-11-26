// IF/ID pipeline register
//		Inputs: clk, reset, en, PC_in, instr_in
//		Outputs: PC_out, instr_out
module if_id_reg (clk, reset, en, PC_in, instr_in, PC_out, instr_out);
	input logic clk, reset, en;
	input logic [63:0] PC_in;
	input logic [31:0] instr_in;
	output logic [63:0] PC_out;
	output logic [31:0] instr_out;
	
	genvar i;
	generate
		reg64 PC_reg (.clk, .reset, .en, .d(PC_in), .q(PC_out));
		for (i = 0; i < 32; i++) begin : instr_io
			D_FF instr_ff (.q(instr_out[i]), .d(instr_in[i]), .reset(reset), .clk(clk), .en(en));
		end
	endgenerate
	
endmodule
