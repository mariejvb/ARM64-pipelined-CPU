// Control unit
//		Input: [10:0] opcode
//		Outputs: Reg2Loc, RegWrite, ALUSrc, [2:0] ALUOp, MemWrite, MemRead, MemToReg, SetFlags, CBZ, BL, BLT, BR, B, [1:0] ImmSel
module control_unit (opcode, Reg2Loc, RegWrite, ALUSrc, ALUOp, MemWrite, MemRead, MemToReg, SetFlags, CBZ, BL, BLT, BR, B, ImmSel);
	input logic [10:0] opcode;
	output logic Reg2Loc, RegWrite, ALUSrc, MemWrite, MemRead, MemToReg, SetFlags, CBZ, BL, BLT, BR, B;
	output logic [2:0] ALUOp;
	output logic [1:0] ImmSel;
	
	always_comb begin
		// Defaults
		Reg2Loc		= 0;
		RegWrite		= 0;
		ALUSrc		= 0;
		ALUOp			= 3'b000;
		MemWrite		= 0;
		MemRead		= 0;
		MemToReg		= 0;
		SetFlags		= 0;
		CBZ			= 0;
		BL				= 0;
		BLT			= 0;
		BR				= 0;
		B				= 0;
		ImmSel		= 2'b00;

		casez (opcode)
			// ALU instructions:
			11'b1001000100?: begin // ADDI
				RegWrite = 1; ALUSrc = 1; ALUOp = 3'b010;
			end
			11'b10101011000: begin // ADDS
				RegWrite = 1; ALUOp = 3'b010; SetFlags = 1;
			end
			11'b11101011000: begin // SUBS
				RegWrite = 1; ALUOp = 3'b011; SetFlags = 1;
			end
			// Memory instructions:
			11'b11111000010: begin // LDUR
				RegWrite = 1; ALUSrc = 1; ALUOp = 3'b010; MemRead = 1; MemToReg = 1; ImmSel = 2'b11;
			end
			11'b11111000000: begin // STUR
				Reg2Loc = 1; ALUSrc = 1; ALUOp = 3'b010; MemWrite = 1; ImmSel = 2'b11;
			end
			// Branch instructions:
			11'b10110100???: begin // CBZ
				Reg2Loc = 1; CBZ = 1; ImmSel = 2'b10;
			end
			11'b000101?????: begin // B
				B = 1; ImmSel = 2'b01;
			end
			11'b100101?????: begin // BL
				RegWrite = 1; BL = 1; ImmSel = 2'b01;  // Write PC + 4 to X30
			end
			11'b01010100???: begin // B.cond (B.LT: branch if negative != overflow)
				BLT = 1; ImmSel = 2'b10;
			end
			11'b11010110000: begin // BR
				Reg2Loc = 1; BR = 1; // PC = R[rd]
			end
		endcase
	end
endmodule 