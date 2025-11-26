// Execute Stage
//		Inputs: clk, reset, [63:0] id_PC, [63:0] id_PC_offset, [63:0] id_reg_data1,
//					[63:0] id_reg_data2, [63:0] id_imm, [4:0] id_rs1, [4:0] id_rs2,
//					[4:0] id_rd, [13:0] id_control, [1:0] forwardA, [1:0] forwardB,
//					[63:0] ex_mem_forward_data, [63:0] mem_wb_forward_data, [3:0] current_flags
//		Outputs: [63:0] ex_alu_result, [63:0] ex_reg_data2, [63:0] ex_PC_plus4,
//					[63:0] ex_bl_write_data, [4:0] ex_rd, [5:0] ex_control_out,
//					[3:0] ex_flags, ex_conditional_branch, ex_cbz_zero,
//					[63:0] ex_PC_target, bl_branch_taken, [63:0] bl_branch_target
`timescale 1ns/10ps
module execute_stage (
	input logic clk, reset,
	input logic [63:0] id_PC, id_PC_offset, id_reg_data1, id_reg_data2, id_imm,
	input logic [4:0] id_rs1, id_rs2, id_rd,
	input logic [13:0] id_control,
	input logic [1:0] forwardA, forwardB,
	input logic [63:0] ex_mem_forward_data, mem_wb_forward_data,
	input logic [3:0] current_flags,
	output logic [63:0] ex_alu_result, ex_reg_data2, ex_PC_plus4, ex_bl_write_data,
	output logic [4:0] ex_rd,
	output logic [5:0] ex_control_out,
	output logic [3:0] ex_flags,
	output logic ex_conditional_branch, ex_cbz_zero,
	output logic [63:0] ex_PC_target,
	output logic bl_branch_taken,
	output logic [63:0] bl_branch_target
);

	// Unpack control signals
	logic RegWrite, MemWrite, MemRead, MemToReg, ALUSrc, SetFlags, CBZ, BL, BLT, BR, B;
	logic [2:0] ALUOp;
	assign {RegWrite, MemWrite, MemRead, MemToReg, ALUSrc, ALUOp, SetFlags, CBZ, BL, BLT, BR, B} = id_control;

	// Forward muxes
	logic [63:0] forwardA_out, forwardB_out;
	mux3 #(.WIDTH(64)) fwdA_mux (.i0(id_reg_data1), .i1(mem_wb_forward_data), .i2(ex_mem_forward_data), 
											.sel(forwardA), .out(forwardA_out));
	mux3 #(.WIDTH(64)) fwdB_mux (.i0(id_reg_data2), .i1(mem_wb_forward_data), .i2(ex_mem_forward_data), 
											.sel(forwardB), .out(forwardB_out));

	// ALU input B selection
	logic [63:0] alu_input_B;
	mux2 #(.WIDTH(64)) alu_b_mux (.i0(forwardB_out), .i1(id_imm), .sel(ALUSrc), .out(alu_input_B));

	// Main ALU
	logic negative, zero, overflow, carry_out;
	alu main_alu (.A(forwardA_out), .B(alu_input_B), .cntrl(ALUOp), .result(ex_alu_result),
						.negative, .zero, .overflow, .carry_out);

	// Zero detection for CBZ
	zero_flagger ex_check_cbz (.result(forwardB_out), .zero(ex_cbz_zero));

	// BL branch handling
	assign bl_branch_taken = BL;
	mux2 #(.WIDTH(64)) bl_branch_target_mux (.i0(64'b0), .i1(id_PC_offset), .sel(BL), .out(bl_branch_target));

	// Conditional branch decision
	logic cbz_condition, blt_condition, neg_xor_ovf;
	and #50 cbz_and (cbz_condition, CBZ, ex_cbz_zero);
	xor #50 xor_flags (neg_xor_ovf, current_flags[3], current_flags[1]);
	and #50 blt_and (blt_condition, BLT, neg_xor_ovf);
	or #50 cond_branch_or (ex_conditional_branch, cbz_condition, blt_condition);

	// Select PC target for branching
	mux2 #(.WIDTH(64)) pc_target_mux (.i0(id_PC_offset), .i1(forwardB_out), .sel(BR), .out(ex_PC_target));

	// Calculate PC+4 for BL
	alu ex_pc_plus4_calc (.A(id_PC), .B(64'd4), .cntrl(3'b010), .result(ex_PC_plus4),
									.negative(), .zero(), .overflow(), .carry_out());

	// Prepare BL link register data
	assign ex_bl_write_data = ex_PC_plus4;

	// Pass control signals to MEM stage
	assign ex_control_out = {RegWrite, MemWrite, MemRead, MemToReg, SetFlags, BL};

	// Pass register data to MEM stage
	assign ex_reg_data2 = forwardB_out;
	assign ex_rd = id_rd;

	// Pass flags to MEM stage
	assign ex_flags = {negative, zero, overflow, carry_out};
	
endmodule 