// D-type immediate extender
//		Input: [31:0] instr
//		Output: [63:0] imm_ext
module d_immediate (instr, imm_ext);
	input logic [31:0] instr;
	output logic [63:0] imm_ext;

	logic [8:0] imm9;

	// Extract instr[20:12] --> imm9
	genvar i;
	generate
		for (i = 0; i < 9; i++) begin : d_extract
			assign imm9[i] = instr[i + 12];
		end
	endgenerate

	sign_extender #(.IN_WIDTH(9)) ext (.in(imm9), .out(imm_ext));

endmodule
