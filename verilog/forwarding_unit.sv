// Forwarding Unit
//		Inputs: ex_mem_RegWrite, ex_mem_rd, mem_wb_RegWrite, mem_wb_rd, id_ex_rs1, id_ex_rs2
//		Outputs: forwardA, forwardB
module forwarding_unit (ex_mem_RegWrite, ex_mem_rd, mem_wb_RegWrite, mem_wb_rd, id_ex_rs1, 
								id_ex_rs2, ex_mem_BL, mem_wb_BL, forwardA, forwardB);
	input logic ex_mem_RegWrite, mem_wb_RegWrite, ex_mem_BL, mem_wb_BL;
	input logic [4:0] ex_mem_rd, mem_wb_rd, id_ex_rs1, id_ex_rs2;
	output logic [1:0] forwardA;
	output logic [1:0] forwardB;
	
	// Forward to rs1
	always_comb begin
		if (ex_mem_BL && id_ex_rs1 == 5'd30)
			forwardA = 2'b10;
		else if (ex_mem_RegWrite && ex_mem_rd != 5'd31 && ex_mem_rd == id_ex_rs1) // EX/MEM forwarding
			forwardA = 2'b10;
		else if (mem_wb_BL && id_ex_rs1 == 5'd30)
			forwardA = 2'b01;
		else if (mem_wb_RegWrite && mem_wb_rd != 5'd31 && mem_wb_rd == id_ex_rs1) // MEM/WB forwarding
			forwardA = 2'b01;
		else
			forwardA = 2'b00;
	end

	// Forward to rs2
	always_comb begin
		if (ex_mem_BL && id_ex_rs2 == 5'd30)
			forwardB = 2'b10;
		else if (ex_mem_RegWrite && ex_mem_rd != 5'd31 && ex_mem_rd == id_ex_rs2) // EX/MEM forwarding
			forwardB = 2'b10;
		else if (mem_wb_BL && id_ex_rs2 == 5'd30)
			forwardB = 2'b01;
		else if (mem_wb_RegWrite && mem_wb_rd != 5'd31 && mem_wb_rd == id_ex_rs2) // MEM/WB forwarding
			forwardB = 2'b01;
		else
			forwardB = 2'b00;
	end
	
endmodule 