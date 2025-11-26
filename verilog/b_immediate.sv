// B-type immediate extender/shifter
//		Input: [31:0] instr
//		Output: [63:0] imm_ext
module b_immediate (instr, imm_ext);
	input logic [31:0] instr;
	output logic [63:0] imm_ext;

	logic [25:0] imm26;
	logic [63:0] sign_extended;

	// Extract instr[25:0] → imm26
	genvar i;
	generate
		for (i = 0; i < 26; i++) begin : b_extract
			assign imm26[i] = instr[i];
		end
	endgenerate

	// Sign-extend 26-bit immediate
	sign_extender #(.IN_WIDTH(26)) ext (.in(imm26), .out(sign_extended));

	// Shift left 2: imm_ext = sign_extended << 2
	genvar j;
	generate
		assign imm_ext[0] = 1'b0;
		assign imm_ext[1] = 1'b0;
		for (j = 2; j < 64; j++) begin : shift_2
			assign imm_ext[j] = sign_extended[j - 2];
		end
	endgenerate

endmodule
