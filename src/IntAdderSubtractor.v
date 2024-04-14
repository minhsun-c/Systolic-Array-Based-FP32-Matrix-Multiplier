`ifndef __INTEGER_ADDER_SUBTRACTOR
`define __INTEGER_ADDER_SUBTRACTOR

module Adder_Subtractor8 (
	output  Cout,
	output  [7:0] Sum,
	input   [7:0] A, B,
	input   Cin
);
	wire C1, C2, C3, C4, C5, C6, C7;
	FullAdder F0(C1,    Sum[0], A[0], B[0] ^ Cin, Cin);
	FullAdder F1(C2,    Sum[1], A[1], B[1] ^ Cin, C1 );
	FullAdder F2(C3,    Sum[2], A[2], B[2] ^ Cin, C2 );
	FullAdder F3(C4,    Sum[3], A[3], B[3] ^ Cin, C3 );
	FullAdder F4(C5,    Sum[4], A[4], B[4] ^ Cin, C4 );
	FullAdder F5(C6,    Sum[5], A[5], B[5] ^ Cin, C5 );
	FullAdder F6(C7,    Sum[6], A[6], B[6] ^ Cin, C6 );
	FullAdder F7(Cout,  Sum[7], A[7], B[7] ^ Cin, C7 );
endmodule   

`endif

`ifndef __CARRY_LOOKAHEAD_ADDER
`define __CARRY_LOOKAHEAD_ADDER

module CarryLookaheadAdder #(
    parameter WIDTH = 32
)(
    output  [WIDTH-1 : 0]   Sum,
    output                  Cout,
    input   [WIDTH-1 : 0]   A, B,
    input                   Cin
);
    wire    [WIDTH:0]       C;
    assign  C[0] = Cin;
    
    genvar i;
    generate for (i=0; i<WIDTH; i=i+1) begin
            FullAdder FA(C[i+1], Sum[i], A[i], B[i], C[i]);
        end
    endgenerate

    assign  Cout = C[WIDTH];
endmodule

`endif

`ifndef __FULL_ADDER
`define __FULL_ADDER

module FullAdder (
    output Cout, Sum,
    input A, B, Cin
);
    assign Cout = (A & B) | (A & Cin) | (B & Cin);
    assign Sum  = A ^ B ^ Cin;
endmodule

`endif