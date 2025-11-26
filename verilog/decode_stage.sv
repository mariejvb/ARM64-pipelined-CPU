// Decode Stage
//		Inputs: clk, reset, branch_taken, [63:0] if_PC, [31:0] if_instruction,
//					RegWrite_final, [4:0] write_reg_final, [63:0] write_data_final
//		Outputs: [63:0] PC_offset, [63:0] reg_data1, [63:0] reg_data2, [63:0] imm_ext,
//					[4:0] rs1, [4:0] rs2, [4:0] rd, [4:0] reg2, [13:0] control_signals,
//					id_branch_taken, [63:0] id_branch_target
`timescale 1ns/10ps
module decode_stage (
	input logic clk, reset,
	input logic branch_taken,
	input logic [63:0] if_PC, 
	input logic [31:0] if_instruction,
	input logic RegWrite_final,
	input logic [4:0] write_reg_final,
	input logic [63:0] write_data_final,
	output logic [63:0] PC_offset,
	output logic [63:0] reg_data1, reg_data2, imm_ext,
	output logic [4:0] rs1, rs2, rd, reg2,
	output logic [13:0] control_signals,
	output logic id_branch_taken,
	output logic [63:0] id_branch_target
);
	
	// Source and destination registers
	assign rs1 = if_instruction[9:5];
	assign rs2 = if_instruction[20:16];
	assign rd = if_instruction[4:0];

	// Control signals
	logic Reg2Loc, RegWrite, ALUSrc, MemWrite, MemRead, MemToReg, SetFlags, CBZ, BL, BLT, BR, B;
	logic [1:0] ImmSel;
	logic [2:0] ALUOp;

	// Select read register 2 from rs2 and rd
	mux2 #(.WIDTH(5)) reg2_mux (.i0(rs2), .i1(rd), .sel(Reg2Loc), .out(reg2));

	// Register file
	regfile rf (.clk, .reset, .RegWrite(RegWrite_final), .ReadRegister1(rs1), .ReadRegister2(reg2),
					.WriteRegister(write_reg_final), .WriteData(write_data_final), 
					.ReadData1(reg_data1), .ReadData2(reg_data2));

	// Immediate generation and selection
	logic [63:0] i_imm, b_imm, cb_imm, d_imm;
	i_immediate iimm (.instr(if_instruction), .imm_ext(i_imm));
	b_immediate bimm (.instr(if_instruction), .imm_ext(b_imm));
	cb_immediate cbimm (.instr(if_instruction), .imm_ext(cb_imm));
	d_immediate dimm (.instr(if_instruction), .imm_ext(d_imm));

	mux4 #(.WIDTH(64)) imm_mux (.i0(i_imm), .i1(b_imm), .i2(cb_imm), .i3(d_imm), 
											.sel(ImmSel), .out(imm_ext));

	// Branch offset adder
	alu branch_offset_adder (.A(if_PC), .B(imm_ext), .cntrl(3'b010), .result(PC_offset),
										.negative(), .zero(), .overflow(), .carry_out());

	// Control unit
	control_unit ctrl (.opcode(if_instruction[31:21]), .Reg2Loc, .RegWrite, .ALUSrc, .ALUOp, .MemWrite, 
								.MemRead, .MemToReg, .SetFlags, .CBZ, .BL, .BLT, .BR, .B, .ImmSel);

	// Pack control signals
	assign control_signals = {RegWrite, MemWrite, MemRead, MemToReg, ALUSrc, ALUOp, SetFlags, CBZ, BL, BLT, BR, B};

	// Early branch resolution for unconditional branches
	assign id_branch_taken = B;
	mux2 #(.WIDTH(64)) id_branch_target_mux (.i0(64'b0), .i1(PC_offset), .sel(B), .out(id_branch_target));
	
endmodule 