module Systolic_Array2x2 (
	output [31:0]
		 out0_0, out0_1,
		 out1_0, out1_1,
	input [31:0]
		 W0_i, W1_i,
		 N0_i, N1_i,
	input clk, reset
);

	wire [31:0]
		ROW00_00, ROW00_01,
		ROW01_00, ROW01_01;

	wire [31:0]
		COL00_00, COL00_01,
		COL01_00, COL01_01;

	P_Element PE_00_00 (
		.out(out0_0),	.right_o(ROW00_00),	.bottom_o(COL00_00),
		.left_i(W0_i),	.top_i(N0_i),
		.clk(clk),	.rst_n(reset)
	);
	P_Element PE_00_01 (
		.out(out0_1),	.right_o(ROW00_01),	.bottom_o(COL00_01),
		.left_i(ROW00_00),	.top_i(N1_i),
		.clk(clk),	.rst_n(reset)
	);
	P_Element PE_01_00 (
		.out(out1_0),	.right_o(ROW01_00),	.bottom_o(COL01_00),
		.left_i(W1_i),	.top_i(COL00_00),
		.clk(clk),	.rst_n(reset)
	);
	P_Element PE_01_01 (
		.out(out1_1),	.right_o(ROW01_01),	.bottom_o(COL01_01),
		.left_i(ROW01_00),	.top_i(COL00_01),
		.clk(clk),	.rst_n(reset)
	);
endmodule
