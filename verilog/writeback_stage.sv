// Writeback Stage Module
//		Inputs: [63:0] mem_mem_data, [63:0] mem_alu_result, [63:0] mem_bl_write_data,
//					[4:0] mem_rd, [3:0] mem_control
//		Outputs: RegWrite_out, [4:0] write_reg_out, [63:0] write_data_out
`timescale 1ns/10ps
module writeback_stage (
	input logic [63:0] mem_mem_data, mem_alu_result, mem_bl_write_data,
	input logic [4:0] mem_rd,
	input logic [3:0] mem_control,
	output logic RegWrite_out,
	output logic [4:0] write_reg_out,
	output logic [63:0] write_data_out
);

	// Unpack control signals
	logic RegWrite, MemToReg, SetFlags, BL;
	assign {RegWrite, MemToReg, SetFlags, BL} = mem_control;

	// Select write data (ALU result or memory data)
	logic [63:0] write_data;
	mux2 #(.WIDTH(64)) wb_mux (.i0(mem_alu_result), .i1(mem_mem_data), .sel(MemToReg), .out(write_data));

	// For BL, write PC+4 to X30
	mux2 #(.WIDTH(5)) final_writereg_mux (.i0(mem_rd), .i1(5'd30), .sel(BL), .out(write_reg_out));
	mux2 #(.WIDTH(64)) final_writedata_mux (.i0(write_data), .i1(mem_bl_write_data), .sel(BL), .out(write_data_out));

	// Output RegWrite signal
	assign RegWrite_out = RegWrite;
	
endmodule 