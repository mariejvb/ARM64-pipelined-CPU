// Flag Forwarding Module
//		Inputs: ex_mem_SetFlags, mem_wb_SetFlags, [3:0] flags, [3:0] ex_mem_flags,
//					[3:0] mem_wb_flags
//		Outputs: [3:0] current_flags
`timescale 1ns/10ps
module flag_forwarding (
	input logic ex_mem_SetFlags, mem_wb_SetFlags,
	input logic [3:0] flags, ex_mem_flags, mem_wb_flags,
	output logic [3:0] current_flags
);

	// Flag forwarding logic
	logic [1:0] flag_forward;
	logic flag_fwd_bit0, flag_fwd_bit1;

	// bit1 = ex_mem_SetFlags
	assign flag_fwd_bit1 = ex_mem_SetFlags;

	// bit0 = mem_wb_SetFlags & ~ex_mem_SetFlags
	logic not_ex_mem_SetFlags;
	not #50 not_ex_mem (not_ex_mem_SetFlags, ex_mem_SetFlags);
	and #50 flag_fwd0_and (flag_fwd_bit0, mem_wb_SetFlags, not_ex_mem_SetFlags);

	assign flag_forward = {flag_fwd_bit1, flag_fwd_bit0};

	// Select current flags with 4:1 mux
	mux4 #(.WIDTH(4)) flag_mux (.i0(flags), .i1(mem_wb_flags), .i2(ex_mem_flags), .i3(ex_mem_flags), 
											.sel(flag_forward), .out(current_flags));
	
endmodule 