// MEM/WB pipeline register
//		Inputs: clk, reset, en, mem_data_in, alu_result_in, rd_in, control_in
//		Outputs: mem_data_out, alu_result_out, rd_out, control_out
module mem_wb_reg (clk, reset, en, mem_data_in, alu_result_in, rd_in, control_in, flags_in, bl_write_data_in,
							mem_data_out, alu_result_out, rd_out, control_out, flags_out, bl_write_data_out);

	input logic clk, reset, en;
	input logic [63:0] mem_data_in, alu_result_in, bl_write_data_in;
	input logic [4:0] rd_in;
	input logic [3:0] control_in;
	input logic [3:0] flags_in;

	output logic [63:0] mem_data_out, alu_result_out, bl_write_data_out;
	output logic [4:0] rd_out;
	output logic [3:0] control_out;
	output logic [3:0] flags_out;

	genvar i;
	generate
		reg64 mem_reg (.clk, .reset, .en, .d(mem_data_in),   .q(mem_data_out));
		reg64 alu_reg (.clk, .reset, .en, .d(alu_result_in), .q(alu_result_out));
		reg64 bl_data_reg (.clk, .reset, .en, .d(bl_write_data_in), .q(bl_write_data_out));

		for (i = 0; i < 5; i++) begin : rd_io
			D_FF rd_ff (.q(rd_out[i]), .d(rd_in[i]), .reset, .clk, .en);
		end

		for (i = 0; i < 4; i++) begin : ctrl_io
			D_FF ctrl_ff (.q(control_out[i]), .d(control_in[i]), .reset, .clk, .en);
		end
		for (i = 0; i < 4; i++) begin : flags_io
			D_FF flags_ff (.q(flags_out[i]), .d(flags_in[i]), .reset, .clk, .en);
		end
	endgenerate
	
endmodule
