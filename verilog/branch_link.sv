// Branch with link logic
//		Inputs: [63:0] PC_plus4
//		Outputs: [4:0] write_reg_BL, [63:0] write_data_BL
module branch_link (PC_plus4, write_reg_BL, write_data_BL);
	input logic [63:0] PC_plus4;
	output logic [4:0] write_reg_BL;
	output logic [63:0] write_data_BL;

	// write_reg_BL = 5'b11110 (X30)
	assign write_reg_BL[4] = 1'b1;
	assign write_reg_BL[3] = 1'b1;
	assign write_reg_BL[2] = 1'b1;
	assign write_reg_BL[1] = 1'b1;
	assign write_reg_BL[0] = 1'b0;

	// write_data_BL = PC + 4
	genvar i;
	generate
		for (i = 0; i < 64; i++) begin : passthru
			assign write_data_BL[i] = PC_plus4[i];
		end
	endgenerate
	
endmodule 