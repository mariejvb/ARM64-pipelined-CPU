// Branch Logic Module
//		Inputs: id_branch_taken, [63:0] id_branch_target, bl_branch_taken,
//					[63:0] bl_branch_target, id_ex_BR, ex_conditional_branch,
//					[63:0] ex_PC_target, [63:0] PC_plus4
//		Outputs: branch_taken, [63:0] next_PC
`timescale 1ns/10ps
module branch_logic (
	input logic id_branch_taken,
	input logic [63:0] id_branch_target,
	input logic bl_branch_taken,
	input logic [63:0] bl_branch_target,
	input logic id_ex_BR, ex_conditional_branch,
	input logic [63:0] ex_PC_target,
	input logic [63:0] PC_plus4,
	output logic branch_taken,
	output logic [63:0] next_PC
);

	// Branch decision logic
	logic br_or_cond, bl_or_br_cond, any_branch;

	or #50 br_cond_or (br_or_cond, id_ex_BR, ex_conditional_branch);
	or #50 bl_br_cond_or (bl_or_br_cond, bl_branch_taken, br_or_cond);
	or #50 all_branch_or (any_branch, id_branch_taken, bl_or_br_cond);

	assign branch_taken = any_branch;

	// Branch target selection
	logic [63:0] other_branch_target;
	mux2 #(.WIDTH(64)) other_branch_mux (.i0(bl_branch_target), .i1(ex_PC_target), 
														.sel(br_or_cond), .out(other_branch_target));

	logic [63:0] branch_target;
	mux2 #(.WIDTH(64)) branch_target_mux (.i0(other_branch_target), .i1(id_branch_target), 
														.sel(id_branch_taken), .out(branch_target));

	// Final PC selection
	mux2 #(.WIDTH(64)) next_pc_final_mux (.i0(PC_plus4), .i1(branch_target), 
														.sel(branch_taken), .out(next_PC));
	
endmodule 