// 32x64 register file module
//		Inputs: clk, reset, RegWrite, ReadReg1, ReadReg2, WriteReg, WriteData
//		Outputs: ReadData1, ReadData2
module regfile (clk, reset, RegWrite, ReadRegister1, ReadRegister2, WriteRegister, 
					WriteData, ReadData1, ReadData2);
	
	input logic clk, reset, RegWrite;
	input logic [4:0] ReadRegister1, ReadRegister2, WriteRegister;
	input logic [63:0] WriteData;
	output logic [63:0] ReadData1, ReadData2;

	// Internal logic
	logic [31:0] write_select;
	logic [63:0] reg_array[31:0];
	logic [63:0] raw_read1, raw_read2; // Raw register file outputs

	// 5:32 decoder module instantiation
	dec5x32 find (.in(WriteRegister), .en(RegWrite), .out(write_select));

	genvar i;
	generate
		for (i = 0; i < 31; i++) begin : build_reg
			// 64-bit register module instantiation
			reg64 b64 (.clk, .reset, .en(write_select[i]), .d(WriteData), .q(reg_array[i]));
		end
	endgenerate

	// Register 31 hardwired to zero
	assign reg_array[31] = 64'b0;

	// 64x32:1 multiplexor module instantiation for raw reads
	mux32 read1 (.in(reg_array), .sel(ReadRegister1), .out(raw_read1));
	mux32 read2 (.in(reg_array), .sel(ReadRegister2), .out(raw_read2));

	// WRITE-THROUGH FORWARDING:

	// Check if we're writing to the register we're reading (and it's not X31)
	logic forward1, forward2;

	// Use the same decoder output to check if we're writing to the read register
	assign forward1 = write_select[ReadRegister1];
	assign forward2 = write_select[ReadRegister2];

	// Muxes for forwarding
	mux2 #(.WIDTH(64)) fwd_mux1 (.i0(raw_read1), .i1(WriteData), .sel(forward1), .out(ReadData1));
	mux2 #(.WIDTH(64)) fwd_mux2 (.i0(raw_read2), .i1(WriteData), .sel(forward2), .out(ReadData2));

endmodule 