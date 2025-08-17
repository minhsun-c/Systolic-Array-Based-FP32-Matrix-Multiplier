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

module Adder_Subtractor25 (
	output  Cout,
	output  [24:0] Sum,
	input   [24:0] A, B,
	input   Cin
);
	wire C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12, C13, 
		C14, C15, C16, C17, C18, C19, C20, C21, C22, C23, C24;
	FullAdder F0(C1, Sum[0], A[0], B[0] ^ Cin, Cin);
	FullAdder F1(C2, Sum[1], A[1], B[1] ^ Cin, C1);
	FullAdder F2(C3, Sum[2], A[2], B[2] ^ Cin, C2);
	FullAdder F3(C4, Sum[3], A[3], B[3] ^ Cin, C3);
	FullAdder F4(C5, Sum[4], A[4], B[4] ^ Cin, C4);
	FullAdder F5(C6, Sum[5], A[5], B[5] ^ Cin, C5);
	FullAdder F6(C7, Sum[6], A[6], B[6] ^ Cin, C6);
	FullAdder F7(C8, Sum[7], A[7], B[7] ^ Cin, C7);
	FullAdder F8(C9, Sum[8], A[8], B[8] ^ Cin, C8);
	FullAdder F9(C10, Sum[9], A[9], B[9] ^ Cin, C9);
	FullAdder F10(C11, Sum[10], A[10], B[10] ^ Cin, C10);
	FullAdder F11(C12, Sum[11], A[11], B[11] ^ Cin, C11);
	FullAdder F12(C13, Sum[12], A[12], B[12] ^ Cin, C12);
	FullAdder F13(C14, Sum[13], A[13], B[13] ^ Cin, C13);
	FullAdder F14(C15, Sum[14], A[14], B[14] ^ Cin, C14);
	FullAdder F15(C16, Sum[15], A[15], B[15] ^ Cin, C15);
	FullAdder F16(C17, Sum[16], A[16], B[16] ^ Cin, C16);
	FullAdder F17(C18, Sum[17], A[17], B[17] ^ Cin, C17);
	FullAdder F18(C19, Sum[18], A[18], B[18] ^ Cin, C18);
	FullAdder F19(C20, Sum[19], A[19], B[19] ^ Cin, C19);
	FullAdder F20(C21, Sum[20], A[20], B[20] ^ Cin, C20);
	FullAdder F21(C22, Sum[21], A[21], B[21] ^ Cin, C21);
	FullAdder F22(C23, Sum[22], A[22], B[22] ^ Cin, C22);
	FullAdder F23(C24, Sum[23], A[23], B[23] ^ Cin, C23);
	FullAdder F24(Cout, Sum[24], A[24], B[24] ^ Cin, C24);
endmodule


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


module FullAdder (
    output Cout, Sum,
    input A, B, Cin
);
    assign Cout = (A & B) | (A & Cin) | (B & Cin);
    assign Sum  = A ^ B ^ Cin;
endmodule