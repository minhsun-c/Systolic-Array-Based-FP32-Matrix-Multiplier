module Systolic_Array2x2 (
	output [31:0]
		 out0_0, out0_1,
		 out1_0, out1_1,
	input [31:0]
		 W0, W1,
		 N0, N1,
	input clk, reset
);

	wire [31:0]
		ROW00_00, ROW00_01,
		ROW01_00, ROW01_01;

	wire [31:0]
		COL00_00, COL00_01,
		COL01_00, COL01_01;

	P_Element PE_00_00 (
		.OUT(out0_0),	.OUT_RIGHT(ROW00_00),	.OUT_BOTTOM(COL00_00),
		.IN_LEFT(W0),	.IN_TOP(N0),
		.CLK(clk),	.RST_N(reset)
	);
	P_Element PE_00_01 (
		.OUT(out0_1),	.OUT_RIGHT(ROW00_01),	.OUT_BOTTOM(COL00_01),
		.IN_LEFT(ROW00_00),	.IN_TOP(N1),
		.CLK(clk),	.RST_N(reset)
	);
	P_Element PE_01_00 (
		.OUT(out1_0),	.OUT_RIGHT(ROW01_00),	.OUT_BOTTOM(COL01_00),
		.IN_LEFT(W1),	.IN_TOP(COL00_00),
		.CLK(clk),	.RST_N(reset)
	);
	P_Element PE_01_01 (
		.OUT(out1_1),	.OUT_RIGHT(ROW01_01),	.OUT_BOTTOM(COL01_01),
		.IN_LEFT(ROW01_00),	.IN_TOP(COL00_01),
		.CLK(clk),	.RST_N(reset)
	);
endmodule
