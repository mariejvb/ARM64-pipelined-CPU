// Hazard Detection Unit
//		Inputs: id_ex_MemRead, [4:0] id_ex_rd, [4:0] if_id_rs1, [4:0] if_id_rs2
//		Outputs: stall
`timescale 1ns/10ps
module hazard_unit (
	input logic id_ex_MemRead,
	input logic [4:0] id_ex_rd,
	input logic [4:0] if_id_rs1,
	input logic [4:0] if_id_rs2,
	output logic stall
);
	
	// Detect load-use hazard
	logic rs1_hazard, rs2_hazard, rd_nonzero;

	// Check if rd is not X31 (zero register)
	logic [4:0] all_ones;
	assign all_ones = 5'b11111;
	logic rd_is_31;

	// Compare rd with 31
	xnor #50 xnor0 (rd_is_31, id_ex_rd[0], all_ones[0]);
	logic temp1, temp2, temp3, temp4;
	xnor #50 xnor1 (temp1, id_ex_rd[1], all_ones[1]);
	xnor #50 xnor2 (temp2, id_ex_rd[2], all_ones[2]);
	xnor #50 xnor3 (temp3, id_ex_rd[3], all_ones[3]);
	xnor #50 xnor4 (temp4, id_ex_rd[4], all_ones[4]);

	logic rd_is_31_final;
	and #50 and_rd31 (rd_is_31_final, rd_is_31, temp1, temp2, temp3, temp4);
	not #50 not_rd31 (rd_nonzero, rd_is_31_final);

	// Check if rs1 matches rd
	logic rs1_match0, rs1_match1, rs1_match2, rs1_match3, rs1_match4;
	xnor #50 xnor_rs1_0 (rs1_match0, if_id_rs1[0], id_ex_rd[0]);
	xnor #50 xnor_rs1_1 (rs1_match1, if_id_rs1[1], id_ex_rd[1]);
	xnor #50 xnor_rs1_2 (rs1_match2, if_id_rs1[2], id_ex_rd[2]);
	xnor #50 xnor_rs1_3 (rs1_match3, if_id_rs1[3], id_ex_rd[3]);
	xnor #50 xnor_rs1_4 (rs1_match4, if_id_rs1[4], id_ex_rd[4]);

	logic rs1_matches;
	and #50 and_rs1 (rs1_matches, rs1_match0, rs1_match1, rs1_match2, rs1_match3, rs1_match4);

	// Check if rs2 matches rd
	logic rs2_match0, rs2_match1, rs2_match2, rs2_match3, rs2_match4;
	xnor #50 xnor_rs2_0 (rs2_match0, if_id_rs2[0], id_ex_rd[0]);
	xnor #50 xnor_rs2_1 (rs2_match1, if_id_rs2[1], id_ex_rd[1]);
	xnor #50 xnor_rs2_2 (rs2_match2, if_id_rs2[2], id_ex_rd[2]);
	xnor #50 xnor_rs2_3 (rs2_match3, if_id_rs2[3], id_ex_rd[3]);
	xnor #50 xnor_rs2_4 (rs2_match4, if_id_rs2[4], id_ex_rd[4]);

	logic rs2_matches;
	and #50 and_rs2 (rs2_matches, rs2_match0, rs2_match1, rs2_match2, rs2_match3, rs2_match4);

	// Hazard exists if load in EX and (rs1 or rs2 matches rd)
	logic either_matches;
	or #50 or_matches (either_matches, rs1_matches, rs2_matches);

	logic hazard_temp;
	and #50 and_hazard (hazard_temp, id_ex_MemRead, either_matches);
	and #50 and_final (stall, hazard_temp, rd_nonzero);
 
endmodule 