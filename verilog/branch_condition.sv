// Branch condition checker
//		Inputs: zero, negative, overflow, CBZ, BLT
//		Output: BranchCond
`timescale 1ns/10ps
module branch_condition (zero, negative, overflow, CBZ, BLT, BranchCond);
	input logic zero, negative, overflow, CBZ, BLT;
	output logic BranchCond;
	
	logic cbz_taken, blt_taken, n_xor_o;

	// For CBZ: cbz_taken = CBZ & zero
	and #50 (cbz_taken, CBZ, zero);

	// For B.LT: blt_taken = BLT & (negative ^ overflow)
	xor #50 (n_xor_o, negative, overflow);
	and #50 (blt_taken, BLT, n_xor_o);

	// Final branch condition
	or #50 (BranchCond, cbz_taken, blt_taken);
	
endmodule 