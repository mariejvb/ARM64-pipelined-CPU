// Memory Stage Module
//		Inputs: clk, [63:0] ex_alu_result, [63:0] ex_reg_data2, [63:0] ex_bl_write_data,
//					[4:0] ex_rd, [5:0] ex_control, [3:0] ex_flags
//		Outputs: [63:0] mem_mem_data, [63:0] mem_alu_result, [63:0] mem_bl_write_data,
//					[4:0] mem_rd, [3:0] mem_control_out, [3:0] mem_flags
`timescale 1ns/10ps
module memory_stage (
	input logic clk,
	input logic [63:0] ex_alu_result, ex_reg_data2, ex_bl_write_data,
	input logic [4:0] ex_rd,
	input logic [5:0] ex_control,
	input logic [3:0] ex_flags,
	output logic [63:0] mem_mem_data, mem_alu_result, mem_bl_write_data,
	output logic [4:0] mem_rd,
	output logic [3:0] mem_control_out,
	output logic [3:0] mem_flags
);

	// Unpack control signals
	logic RegWrite, MemWrite, MemRead, MemToReg, SetFlags, BL;
	assign {RegWrite, MemWrite, MemRead, MemToReg, SetFlags, BL} = ex_control;

	// Data memory
	logic [63:0] data_mem_read;
	datamem data_mem (.address(ex_alu_result), .write_enable(MemWrite), .read_enable(MemRead),
							.write_data(ex_reg_data2), .clk, .xfer_size(4'd8), .read_data(data_mem_read));

	// Pass signals to WB stage
	assign mem_mem_data = data_mem_read;
	assign mem_alu_result = ex_alu_result;
	assign mem_bl_write_data = ex_bl_write_data;
	assign mem_rd = ex_rd;
	assign mem_control_out = {RegWrite, MemToReg, SetFlags, BL};
	assign mem_flags = ex_flags;
	
endmodule 