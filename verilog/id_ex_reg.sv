// ID/EX pipeline register
//		Inputs: clk, reset, en, PC_in, reg_data1_in, reg_data2_in, imm_in, rs1_in, rs2_in, rd_in, control_in
//		Outputs: PC_out, reg_data1_out, reg_data2_out, imm_out, rs1_out, rs2_out, rd_out, control_out
module id_ex_reg (clk, reset, en, PC_in, PC_offset_in, reg_data1_in, reg_data2_in, imm_in, rs1_in,
						rs2_in, rd_in, control_in, PC_out, PC_offset_out, reg_data1_out, reg_data2_out,
						imm_out, rs1_out, rs2_out, rd_out, control_out);
				  
	input logic clk, reset, en;
	input logic [63:0] PC_in, PC_offset_in, reg_data1_in, reg_data2_in, imm_in;
	input logic [4:0] rs1_in, rs2_in, rd_in;
	input logic [13:0] control_in;
	
	output logic [63:0] PC_out, PC_offset_out, reg_data1_out, reg_data2_out, imm_out;
	output logic [4:0] rs1_out, rs2_out, rd_out;
	output logic [13:0] control_out;

	genvar i;
	generate
		reg64 PC_reg (.clk, .reset, .en, .d(PC_in), .q(PC_out));
		reg64 PC_offset_reg (.clk, .reset, .en, .d(PC_offset_in), .q(PC_offset_out));
		reg64 r1_reg (.clk, .reset, .en, .d(reg_data1_in), .q(reg_data1_out));
		reg64 r2_reg (.clk, .reset, .en, .d(reg_data2_in), .q(reg_data2_out));
		reg64 imm_reg (.clk, .reset, .en, .d(imm_in), .q(imm_out));
		
		for (i = 0; i < 5; i++) begin : reg_io
			D_FF rs1_ff (.q(rs1_out[i]), .d(rs1_in[i]), .reset, .clk, .en);
			D_FF rs2_ff (.q(rs2_out[i]), .d(rs2_in[i]), .reset, .clk, .en);
			D_FF rd_ff (.q(rd_out[i]),  .d(rd_in[i]),  .reset, .clk, .en);
		end

		for (i = 0; i < 14; i++) begin : ctrl_io
			D_FF ctrl_ff (.q(control_out[i]), .d(control_in[i]), .reset, .clk, .en);
		end
	endgenerate
	
endmodule 