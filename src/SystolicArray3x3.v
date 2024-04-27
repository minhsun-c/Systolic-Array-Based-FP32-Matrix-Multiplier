module Systolic_Array3x3 (
	output [31:0]
		 out0_0, out0_1, out0_2,
		 out1_0, out1_1, out1_2,
		 out2_0, out2_1, out2_2,
	input [31:0]
		 W0, W1, W2,
		 N0, N1, N2,
	input clk, reset
);

	wire [31:0]
		ROW00_00, ROW00_01, ROW00_02,
		ROW01_00, ROW01_01, ROW01_02,
		ROW02_00, ROW02_01, ROW02_02;

	wire [31:0]
		COL00_00, COL00_01, COL00_02,
		COL01_00, COL01_01, COL01_02,
		COL02_00, COL02_01, COL02_02;

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
	P_Element PE_00_02 (
		.OUT(out0_2),	.OUT_RIGHT(ROW00_02),	.OUT_BOTTOM(COL00_02),
		.IN_LEFT(ROW00_01),	.IN_TOP(N2),
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
	P_Element PE_01_02 (
		.OUT(out1_2),	.OUT_RIGHT(ROW01_02),	.OUT_BOTTOM(COL01_02),
		.IN_LEFT(ROW01_01),	.IN_TOP(COL00_02),
		.CLK(clk),	.RST_N(reset)
	);
	P_Element PE_02_00 (
		.OUT(out2_0),	.OUT_RIGHT(ROW02_00),	.OUT_BOTTOM(COL02_00),
		.IN_LEFT(W2),	.IN_TOP(COL01_00),
		.CLK(clk),	.RST_N(reset)
	);
	P_Element PE_02_01 (
		.OUT(out2_1),	.OUT_RIGHT(ROW02_01),	.OUT_BOTTOM(COL02_01),
		.IN_LEFT(ROW02_00),	.IN_TOP(COL01_01),
		.CLK(clk),	.RST_N(reset)
	);
	P_Element PE_02_02 (
		.OUT(out2_2),	.OUT_RIGHT(ROW02_02),	.OUT_BOTTOM(COL02_02),
		.IN_LEFT(ROW02_01),	.IN_TOP(COL01_02),
		.CLK(clk),	.RST_N(reset)
	);
endmodule
