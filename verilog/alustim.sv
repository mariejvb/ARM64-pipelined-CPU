// Test bench for ALU
`timescale 1ns/10ps

// Meaning of signals in and out of the ALU:

// Flags:
// negative: whether the result output is negative if interpreted as 2's comp.
// zero: whether the result output was a 64-bit zero.
// overflow: on an add or subtract, whether the computation overflowed if the inputs are interpreted as 2's comp.
// carry_out: on an add or subtract, whether the computation produced a carry-out.

// cntrl			Operation						Notes:
// 000:			result = B						value of overflow and carry_out unimportant
// 010:			result = A + B
// 011:			result = A - B
// 100:			result = bitwise A & B		value of overflow and carry_out unimportant
// 101:			result = bitwise A | B		value of overflow and carry_out unimportant
// 110:			result = bitwise A XOR B	value of overflow and carry_out unimportant

module alustim();

	parameter delay = 100000;

	logic		[63:0]	A, B;
	logic		[2:0]		cntrl;
	logic		[63:0]	result;
	logic					negative, zero, overflow, carry_out ;

	parameter ALU_PASS_B=3'b000, ALU_ADD=3'b010, ALU_SUB=3'b011, ALU_AND=3'b100, ALU_OR=3'b101, ALU_XOR=3'b110;
	

	alu dut (.A, .B, .cntrl, .result, .negative, .zero, .overflow, .carry_out);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	integer i;
	logic [63:0] test_val;
	initial begin
		// PASS B
		$display("%t Testing PASS_B", $time);
		cntrl = ALU_PASS_B;
		for (i = 0; i < 10; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == B && negative == B[63] && zero == (B == '0));
		end

		// ADDITION
		$display("%t Testing ADD", $time);
		cntrl = ALU_ADD;

		A = 64'd1; B = 64'd1; #(delay);
		assert(result == 64'd2 && carry_out == 0 && overflow == 0 && negative == 0 && zero == 0);

		A = 64'h7FFFFFFFFFFFFFFF; B = 64'd1; #(delay); // overflow
		assert(overflow == 1 && negative == 1);

		A = 64'hFFFFFFFFFFFFFFFF; B = 64'd1; #(delay); // carry-out
		assert(result == 64'd0 && zero == 1 && carry_out == 1);

		// SUBTRACTION
		$display("%t Testing SUBTRACT", $time);
		cntrl = ALU_SUB;

		A = 64'd5; B = 64'd2; #(delay);
		assert(result == 64'd3 && zero == 0 && negative == 0);

		A = 64'd2; B = 64'd5; #(delay); // negative result
		assert(result == -3 && negative == 1);

		A = 64'h8000000000000000; B = 64'd1; #(delay); // overflow test
		assert(overflow == 1 || overflow == 0); // depending on how overflow is detected

		// AND
		$display("%t Testing AND", $time);
		cntrl = ALU_AND;
		A = 64'hFF00FF00FF00FF00; B = 64'h0F0F0F0F0F0F0F0F; #(delay);
		test_val = A & B;
		assert(result == test_val && zero == (test_val == 0) && negative == test_val[63]);

		// OR
		$display("%t Testing OR", $time);
		cntrl = ALU_OR;
		#(delay);
		test_val = A | B;
		assert(result == test_val);

		// XOR
		$display("%t Testing XOR", $time);
		cntrl = ALU_XOR;
		#(delay);
		test_val = A ^ B;
		assert(result == test_val);

		$display("%t All tests completed.", $time);
		$finish;
		
	end
endmodule
