`ifndef __FLOATING_POINT_ADDER_SUBTRACTOR
`define __FLOATING_POINT_ADDER_SUBTRACTOR

// ############################################################################################
// Given 2 32-bit floating point numbers,
// After some preprocessing, send them into floating point adder.
// 
// Note that mantissa part include prepend 1 bit 
// ############################################################################################

module FP_Adder_Subtractor32 #(
    parameter EXP_IEEE754 = 8,      // exponent in IEEE-754 standard
    parameter MTS_IEEE754 = 23      // mantissa in IEEE-754 standard
)(
    output  [31:0]                          Out,
    output                                  isZero,
    input   [EXP_IEEE754 + MTS_IEEE754 : 0] A,
    input   [EXP_IEEE754 + MTS_IEEE754 : 0] B
);
    wire                                    sign_o;
    wire    [EXP_IEEE754 - 1 : 0]           exp_o;
    wire    [MTS_IEEE754 - 1 : 0]           mts_o;

// ********************************************************************************************
// Compare exponents
// ********************************************************************************************
    wire    [EXP_IEEE754 - 1 : 0]           exp_A;
    wire    [EXP_IEEE754 - 1 : 0]           exp_B;
    wire                                    A_greater_than_B;   
    assign  exp_A   = A[MTS_IEEE754 + EXP_IEEE754 - 1 : MTS_IEEE754];
    assign  exp_B   = B[MTS_IEEE754 + EXP_IEEE754 - 1 : MTS_IEEE754];
    assign  A_greater_than_B = (exp_A >= exp_B);

// ********************************************************************************************
// Extract sign, exponent, mantissa
// ********************************************************************************************
    wire                                    sign_X;
    wire                                    sign_Y;
    wire    [EXP_IEEE754 - 1 : 0]           exp_X;
    wire    [EXP_IEEE754 - 1 : 0]           exp_Y;
    wire    [MTS_IEEE754 + 1 : 0]           mts_X;
    wire    [MTS_IEEE754 + 1 : 0]           mts_Y;
    
    assign  sign_X = 
            (A[EXP_IEEE754 + MTS_IEEE754] & A_greater_than_B) |
            (B[EXP_IEEE754 + MTS_IEEE754] & ~A_greater_than_B);
    assign  sign_Y = 
            (A[EXP_IEEE754 + MTS_IEEE754] & ~A_greater_than_B)|
            (B[EXP_IEEE754 + MTS_IEEE754] & A_greater_than_B) ;
    
    assign  exp_X = 
            (A[MTS_IEEE754 + EXP_IEEE754 - 1 : MTS_IEEE754] & {8{A_greater_than_B}}) |
            (B[MTS_IEEE754 + EXP_IEEE754 - 1 : MTS_IEEE754] & {8{~A_greater_than_B}});
    assign  exp_Y = 
            (A[MTS_IEEE754 + EXP_IEEE754 - 1 : MTS_IEEE754] & {8{~A_greater_than_B}})|
            (B[MTS_IEEE754 + EXP_IEEE754 - 1 : MTS_IEEE754] & {8{A_greater_than_B}}) ;

    assign  mts_X = 
            ({2'b1, A[MTS_IEEE754 - 1 : 0]} & {25{A_greater_than_B}}) |
            ({2'b1, B[MTS_IEEE754 - 1 : 0]} & {25{~A_greater_than_B}});
    assign  mts_Y = 
            ({2'b1, A[MTS_IEEE754 - 1 : 0]} & {25{~A_greater_than_B}})|
            ({2'b1, B[MTS_IEEE754 - 1 : 0]} & {25{A_greater_than_B}}) ;

// ********************************************************************************************
// Send into FP_Adder
// Output the absolute value
// ********************************************************************************************
    wire    [EXP_IEEE754 - 1 : 0]           exp_added;
    wire    [MTS_IEEE754 + 1 : 0]           mts_added;
    wire                                    negative;
    FP_Adder32 FPADD(
        .exp_o(exp_added),  .mts_o(mts_added),  .negative(negative),
        .sign_X(sign_X),    .exp_X(exp_X),      .mts_X(mts_X),
        .sign_Y(sign_Y),    .exp_Y(exp_Y),      .mts_Y(mts_Y)
    );

// ********************************************************************************************
// Normalize
// ********************************************************************************************
    wire    [5 : 0]                         Shift_amount;
    wire    [5 : 0]                         Shift_real;
    wire    [MTS_IEEE754 + 1 : 0]           mts_shift;
    
    LZDetector48 LZD(
        Shift_amount, {23'b0, mts_added} 
    );
    
    assign Shift_real   = Shift_amount - 5'd23;
    assign mts_shift    = mts_added << Shift_real;
    assign mts_o        = mts_shift[24:2];
    assign isZero       = ~(|mts_added);
    assign exp_o        = exp_added - Shift_real + 2;

// ********************************************************************************************
// Sign
// If both sign_X, sign_Y are negative or negative result for subtraction,
// then the sign will be negative.
// Otherwise the sign is positive. 
// ********************************************************************************************
    assign sign_o = ((sign_X ^ sign_Y) & negative) | (sign_X & sign_Y);

    assign Out = {sign_o, exp_o, mts_o};
endmodule

`endif

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

`ifndef __FLOATING_POINT_ADDER
`define __FLOATING_POINT_ADDER

// ############################################################################################
// Given 2 pairs of exponent and mantissa,
// Suppose exponent of X is greater than exponent Y,
// return the solution after addition, but without normalization
//
// Note that mantissa part include prepend 1 bit 
// ############################################################################################

module FP_Adder32 #(
    parameter EXP_IEEE754 = 8,      // exponent in IEEE-754 standard
    parameter MTS_IEEE754 = 23      // mantissa in IEEE-754 standard
)(
    output                          negative,
    output  [EXP_IEEE754 - 1 : 0]   exp_o,
    output  [MTS_IEEE754 + 1: 0]    mts_o,
    input                           sign_X,
    input   [EXP_IEEE754 - 1 : 0]   exp_X,
    input   [MTS_IEEE754 + 1 : 0]   mts_X,
    input                           sign_Y,
    input   [EXP_IEEE754 - 1 : 0]   exp_Y,
    input   [MTS_IEEE754 + 1 : 0]   mts_Y
);
// ********************************************************************************************
// Get the difference of exponent
// ********************************************************************************************
    wire    [EXP_IEEE754 - 1 : 0]   exp_diff;
    Adder_Subtractor8 ExpSubtract(
        .Sum(exp_diff), .A(exp_X), .B(exp_Y), .Cin(`SubMode)
    );

// ********************************************************************************************
// Shift right mts_Y "exp_diff" bits
// ********************************************************************************************
    wire    [MTS_IEEE754 + 1 : 0]       mts_Y_new;
    assign  mts_Y_new = mts_Y >> exp_diff;

// ********************************************************************************************
// Check 2's complement of X
// ********************************************************************************************
    wire    [MTS_IEEE754 + 1 : 0]       mts_X_compl;
    Adder_Subtractor25 Complement2_X(
        .Sum(mts_X_compl), .A(25'b0), .B(mts_X), 
        .Cin((sign_X ^ sign_Y) & sign_X)
    );

// ********************************************************************************************
// Check 2's complement of Y
// ********************************************************************************************
    wire    [MTS_IEEE754 + 1 : 0]       mts_Y_compl;
    Adder_Subtractor25 Complement2_Y(
        .Sum(mts_Y_compl), .A(25'b0), .B(mts_Y_new), 
        .Cin((sign_X ^ sign_Y) & sign_Y)
    );

// ************************************************************
// Mantissa addition
// ************************************************************
    wire    [MTS_IEEE754 + 1 : 0]       mts_pre_ovf;
    Adder_Subtractor25 MTSAdd(
        .Sum(mts_pre_ovf), 
        .A(mts_X_compl),    .B(mts_Y_compl), 
        .Cin(1'b0)
    );
// ********************************************************************************************
// Detect Overflow
// If a positive number + a negative number, come out as a negative number
// then we should perform 2's complement
// Since IEEE-754 stores the absolute value
// ********************************************************************************************
    assign negative = (sign_X ^ sign_Y) & mts_pre_ovf[24];
    Adder_Subtractor25 Complement2_MTS(
        .Sum(mts_o), .A(25'b0), .B(mts_pre_ovf), 
        .Cin(negative)
    );
// ********************************************************************************************
// Output Exponent
// ********************************************************************************************
    assign exp_o = exp_X;

endmodule

`endif