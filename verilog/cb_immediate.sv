// CB-type immediate extender/shifter
module cb_immediate (instr, imm_ext);
	input logic [31:0] instr;
	output logic [63:0] imm_ext;

	logic [18:0] imm19;
	logic [63:0] sign_extended;

	// Extract instr[23:5] → imm19
	genvar i;
	generate
		for (i = 0; i < 19; i++) begin : cb_extract
			assign imm19[i] = instr[i + 5];
		end
	endgenerate

	// Sign-extend 19-bit immediate
	sign_extender #(.IN_WIDTH(19)) ext (.in(imm19), .out(sign_extended));

	// Shift left 2: imm_shifted = sign_extended << 2
	genvar j;
	generate
		assign imm_ext[0] = 1'b0;
		assign imm_ext[1] = 1'b0;
		for (j = 2; j < 64; j++) begin : shift_2
			assign imm_ext[j] = sign_extended[j - 2];
		end
	endgenerate

endmodule
