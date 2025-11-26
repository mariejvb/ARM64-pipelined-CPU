// Top-level pipelined CPU module
`timescale 1ns/10ps
module cpu (clk, reset);
	input logic clk;
	input logic reset;

	// Signal declarations
	logic branch_taken;
	logic [63:0] next_PC, PC, PC_plus4;
	logic [31:0] instruction;

	// Pipeline register signals
	logic [63:0] if_id_PC;
	logic [31:0] if_id_instr;

	logic [63:0] id_ex_PC, id_ex_PC_offset, id_ex_reg_data1, id_ex_reg_data2, id_ex_imm;
	logic [4:0] id_ex_rs1, id_ex_rs2, id_ex_rd;
	logic [13:0] id_ex_ctrl;

	logic [63:0] ex_mem_alu_result, ex_mem_reg_data2, ex_mem_bl_write_data;
	logic [4:0] ex_mem_rd;
	logic [5:0] ex_mem_ctrl;
	logic [3:0] ex_mem_flags;

	logic [63:0] mem_wb_mem_data, mem_wb_alu_result, mem_wb_bl_write_data;
	logic [4:0] mem_wb_rd;
	logic [3:0] mem_wb_ctrl;
	logic [3:0] mem_wb_flags;

	// Stage-specific signals
	logic [63:0] id_PC_offset, id_reg_data1, id_reg_data2, id_imm_ext;
	logic [4:0] id_rs1, id_rs2, id_rd, id_reg2;
	logic [13:0] id_control_signals;
	logic id_branch_taken;
	logic [63:0] id_branch_target;

	logic [63:0] ex_alu_result, ex_reg_data2, ex_PC_plus4, ex_bl_write_data;
	logic [4:0] ex_rd;
	logic [5:0] ex_control_out;
	logic [3:0] ex_flags;
	logic ex_conditional_branch, ex_cbz_zero;
	logic [63:0] ex_PC_target;
	logic bl_branch_taken;
	logic [63:0] bl_branch_target;

	logic [63:0] mem_mem_data, mem_alu_result, mem_bl_write_data;
	logic [4:0] mem_rd;
	logic [3:0] mem_control_out;
	logic [3:0] mem_flags_out;

	logic RegWrite_final;
	logic [4:0] write_reg_final;
	logic [63:0] write_data_final;

	// Forwarding signals
	logic [1:0] forwardA, forwardB;
	logic [63:0] ex_mem_forward_data, mem_wb_forward_data;

	// Flag signals
	logic [3:0] flags;
	logic [3:0] current_flags;

	// Control signal extraction
	logic id_ex_BR, ex_mem_SetFlags, mem_wb_SetFlags, ex_mem_BL, mem_wb_BL;
	logic ex_mem_RegWrite, mem_wb_RegWrite, mem_wb_MemToReg;
	
	// Extract control bits
	assign id_ex_BR = id_ex_ctrl[1];
	assign ex_mem_SetFlags = ex_mem_ctrl[1];
	assign ex_mem_BL = ex_mem_ctrl[0];
	assign ex_mem_RegWrite = ex_mem_ctrl[5];
	assign {mem_wb_RegWrite, mem_wb_MemToReg, mem_wb_SetFlags, mem_wb_BL} = mem_wb_ctrl;
	
	// Hazard detection signals
	logic stall;
	logic [4:0] if_id_rs1, if_id_rs2;
	
	// Enable signals for pipeline registers
	logic PC_enable, if_id_enable, id_ex_enable;
	not #50 not_stall (PC_enable, stall);
	assign if_id_enable = PC_enable;
	assign id_ex_enable = 1'b1;
	
	// NOP logic
	logic [13:0] id_ex_ctrl_muxed;
	logic [4:0] id_ex_rd_muxed;
	
	// Extract rs1 and rs2 from IF/ID instruction
	assign if_id_rs1 = if_id_instr[9:5];    // rs1
	assign if_id_rs2 = if_id_instr[20:16];  // rs2
	
	// Extract MemRead signal from ID/EX control
	logic id_ex_MemRead;
	assign id_ex_MemRead = id_ex_ctrl[11];
	
	/***** Instruction Fetch (IF) *****/
	fetch_stage fetch (
		.clk,
		.reset,
		.branch_taken,
		.next_PC,
		.PC_enable,
		.PC,
		.PC_plus4,
		.instruction
	);
	
	// IF/ID Pipeline Register
	if_id_reg if_id (
		.clk,
		.reset(reset || branch_taken),
		.en(if_id_enable),
		.PC_in(PC),
		.instr_in(instruction),
		.PC_out(if_id_PC),
		.instr_out(if_id_instr)
	);
	
	/***** Instruction Decode (ID) *****/
	decode_stage decode (
		.clk,
		.reset,
		.branch_taken,
		.if_PC(if_id_PC),
		.if_instruction(if_id_instr),
		.RegWrite_final,
		.write_reg_final,
		.write_data_final,
		.PC_offset(id_PC_offset),
		.reg_data1(id_reg_data1),
		.reg_data2(id_reg_data2),
		.imm_ext(id_imm_ext),
		.rs1(id_rs1),
		.rs2(id_rs2),
		.rd(id_rd),
		.reg2(id_reg2),
		.control_signals(id_control_signals),
		.id_branch_taken,
		.id_branch_target
	);
	
	// If stall = 1, zero out control signals (insert NOP)
	mux2 #(.WIDTH(14)) ctrl_stall_mux (
		.i0(id_control_signals),
		.i1(14'b0),  // NOP
		.sel(stall),
		.out(id_ex_ctrl_muxed)
	);

	// If stall = 1, set rd to 31 (no write)
	mux2 #(.WIDTH(5)) rd_stall_mux (
		.i0(id_rd),
		.i1(5'b11111),  // X31
		.sel(stall),
		.out(id_ex_rd_muxed)
	);
	
	// ID/EX Pipeline Register
	id_ex_reg id_ex (
		.clk,
		.reset(reset || branch_taken),
		.en(1'b1),
		.PC_in(if_id_PC),
		.PC_offset_in(id_PC_offset),
		.reg_data1_in(id_reg_data1),
		.reg_data2_in(id_reg_data2),
		.imm_in(id_imm_ext),
		.rs1_in(id_rs1),
		.rs2_in(id_reg2),
		.rd_in(id_ex_rd_muxed),
		.control_in(id_ex_ctrl_muxed),
		.PC_out(id_ex_PC),
		.PC_offset_out(id_ex_PC_offset),
		.reg_data1_out(id_ex_reg_data1),
		.reg_data2_out(id_ex_reg_data2),
		.imm_out(id_ex_imm),
		.rs1_out(id_ex_rs1),
		.rs2_out(id_ex_rs2),
		.rd_out(id_ex_rd),
		.control_out(id_ex_ctrl)
	);
	
	/***** Execute (EX) *****/
	execute_stage execute (
		.clk,
		.reset,
		.id_PC(id_ex_PC),
		.id_PC_offset(id_ex_PC_offset),
		.id_reg_data1(id_ex_reg_data1),
		.id_reg_data2(id_ex_reg_data2),
		.id_imm(id_ex_imm),
		.id_rs1(id_ex_rs1),
		.id_rs2(id_ex_rs2),
		.id_rd(id_ex_rd),
		.id_control(id_ex_ctrl),
		.forwardA,
		.forwardB,
		.ex_mem_forward_data,
		.mem_wb_forward_data,
		.current_flags,
		.ex_alu_result,
		.ex_reg_data2,
		.ex_PC_plus4,
		.ex_bl_write_data,
		.ex_rd,
		.ex_control_out,
		.ex_flags,
		.ex_conditional_branch,
		.ex_cbz_zero,
		.ex_PC_target,
		.bl_branch_taken,
		.bl_branch_target
	);
	
	// EX/MEM Pipeline Register
	ex_mem_reg ex_mem (
		.clk,
		.reset,
		.en(1'b1),
		.alu_result_in(ex_alu_result),
		.reg_data2_in(ex_reg_data2),
		.rd_in(ex_rd),
		.control_in(ex_control_out),
		.flags_in(ex_flags),
		.bl_write_data_in(ex_bl_write_data),
		.alu_result_out(ex_mem_alu_result),
		.reg_data2_out(ex_mem_reg_data2),
		.rd_out(ex_mem_rd),
		.control_out(ex_mem_ctrl),
		.flags_out(ex_mem_flags),
		.bl_write_data_out(ex_mem_bl_write_data)
	);
	
	/***** Memory (MEM) *****/
	memory_stage memory (
		.clk,
		.ex_alu_result(ex_mem_alu_result),
		.ex_reg_data2(ex_mem_reg_data2),
		.ex_bl_write_data(ex_mem_bl_write_data),
		.ex_rd(ex_mem_rd),
		.ex_control(ex_mem_ctrl),
		.ex_flags(ex_mem_flags),
		.mem_mem_data,
		.mem_alu_result,
		.mem_bl_write_data,
		.mem_rd,
		.mem_control_out,
		.mem_flags(mem_flags_out)
	);
	
	// MEM/WB Pipeline Register
	mem_wb_reg mem_wb (
		.clk,
		.reset,
		.en(1'b1),
		.mem_data_in(mem_mem_data),
		.alu_result_in(mem_alu_result),
		.rd_in(mem_rd),
		.control_in(mem_control_out),
		.flags_in(mem_flags_out),
		.bl_write_data_in(mem_bl_write_data),
		.mem_data_out(mem_wb_mem_data),
		.alu_result_out(mem_wb_alu_result),
		.rd_out(mem_wb_rd),
		.control_out(mem_wb_ctrl),
		.flags_out(mem_wb_flags),
		.bl_write_data_out(mem_wb_bl_write_data)
	);
	
	/***** Write-Back (WB) *****/
	writeback_stage writeback (
		.mem_mem_data(mem_wb_mem_data),
		.mem_alu_result(mem_wb_alu_result),
		.mem_bl_write_data(mem_wb_bl_write_data),
		.mem_rd(mem_wb_rd),
		.mem_control(mem_wb_ctrl),
		.RegWrite_out(RegWrite_final),
		.write_reg_out(write_reg_final),
		.write_data_out(write_data_final)
	);
	
	/***** Branch Logic *****/
	branch_logic branch_ctrl (
		.id_branch_taken,
		.id_branch_target,
		.bl_branch_taken,
		.bl_branch_target,
		.id_ex_BR,
		.ex_conditional_branch,
		.ex_PC_target,
		.PC_plus4,
		.branch_taken,
		.next_PC
	);
	
	/***** Forwarding *****/
	// Forwarding data selection
	mux2 #(.WIDTH(64)) ex_mem_fwd_mux (
		.i0(ex_mem_alu_result),
		.i1(ex_mem_bl_write_data),
		.sel(ex_mem_BL),
		.out(ex_mem_forward_data)
	);
	
	logic [63:0] wb_data;
	mux2 #(.WIDTH(64)) wb_data_mux (
		.i0(mem_wb_alu_result),
		.i1(mem_wb_mem_data),
		.sel(mem_wb_ctrl[2]),
		.out(wb_data)
	);
	
	mux2 #(.WIDTH(64)) mem_wb_fwd_mux (
		.i0(wb_data),
		.i1(mem_wb_bl_write_data),
		.sel(mem_wb_BL),
		.out(mem_wb_forward_data)
	);
	
	// Forwarding unit
	forwarding_unit fwd_unit (
		.ex_mem_RegWrite,
		.ex_mem_rd,
		.mem_wb_RegWrite,
		.mem_wb_rd,
		.id_ex_rs1,
		.id_ex_rs2,
		.ex_mem_BL,
		.mem_wb_BL,
		.forwardA,
		.forwardB
	);
	
	/***** Hazard Detection Unit *****/
	hazard_unit hdu (
		.id_ex_MemRead,
		.id_ex_rd,
		.if_id_rs1,
		.if_id_rs2,
		.stall
	);
	
	/***** Flag Management *****/
	// Flag register
	regN #(.N(4)) flag_reg (
		.clk,
		.reset,
		.en(mem_wb_SetFlags),
		.d(mem_wb_flags),
		.q(flags)
	);
	
	// Flag forwarding
	flag_forwarding flag_fwd (
		.ex_mem_SetFlags,
		.mem_wb_SetFlags,
		.flags,
		.ex_mem_flags,
		.mem_wb_flags,
		.current_flags
	);
	
endmodule 