// 4:1 multiplexor
//		Inputs: i0, i1, i2, i3, [1:0] sel
//		Output: out
module mux4 #(parameter WIDTH = 64) (i0, i1, i2, i3, sel, out);
	input  logic [WIDTH-1:0] i0;
	input  logic [WIDTH-1:0] i1;
	input  logic [WIDTH-1:0] i2;
	input  logic [WIDTH-1:0] i3;
	input  logic [1:0] sel;
	output logic [WIDTH-1:0] out;

	logic [WIDTH-1:0] mux_low, mux_high;

	// First layer: select between i0/i1 and i2/i3
	mux2 #(.WIDTH(WIDTH)) low_mux  (.i0(i0), .i1(i1), .sel(sel[0]), .out(mux_low));
	mux2 #(.WIDTH(WIDTH)) high_mux (.i0(i2), .i1(i3), .sel(sel[0]), .out(mux_high));

	// Second layer: select between mux_low and mux_high
	mux2 #(.WIDTH(WIDTH)) final_mux (.i0(mux_low), .i1(mux_high), .sel(sel[1]), .out(out));

endmodule
