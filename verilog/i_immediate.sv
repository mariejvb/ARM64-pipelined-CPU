// I-type immediate extender
//		Input: [31:0] instr
//		Output: [63:0] imm_ext
module i_immediate (instr, imm_ext);
	input logic [31:0] instr;
	output logic [63:0] imm_ext;

	logic [11:0] imm12;

	// Extract instr[21:10] --> imm12
	genvar i;
	generate
		for (i = 0; i < 12; i++) begin : i_extract
			assign imm12[i] = instr[i + 10];
		end
	endgenerate

	zero_extender #(.IN_WIDTH(12)) ext (.in(imm12), .out(imm_ext));

endmodule 