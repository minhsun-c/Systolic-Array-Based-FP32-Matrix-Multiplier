module FP_Multiplier(
    input   [31:0]  A,
    input   [31:0]  B,
    output  [31:0]  Out
);
    wire    [7:0]   Exp_temp;
    wire    [7:0]   Exp_sum;
    wire    [47:0]  Mts_temp;
    wire    [5:0]   Shift_amount;
    wire    [47:0]  Mts_shifted;

// ======================================================================
// Sign : sign_A ^ sign_B
// ======================================================================
    assign Out[31] = A[31] ^ B[31];

// ======================================================================
// Exponent : exp_A + exp_B - bias
// ======================================================================
    Adder_Subtractor8 Sub(
        , Exp_temp,     
        B[30:23],   8'd125,     `SubMode
    );

    Adder_Subtractor8 Add(
        , Exp_sum,     
        A[30:23],   Exp_temp,   `AddMode
    );

// ======================================================================
// Mantissa : mts_A * mts_B
// ======================================================================
    Int_Multiplier W0(
        {1'b1, A[22:0]}, {1'b1, B[22:0]}, Mts_temp
    );

// ======================================================================
// Normalize : detect leading zeros + left shift (<<) 
// ======================================================================
    LZDetector48 LZD(
        Shift_amount, Mts_temp
    );
    
    Adder_Subtractor8 NORM(
        , Out[30:23],   
        Exp_sum,   {2'b0, Shift_amount},   `SubMode
    );
    
    assign Mts_shifted = Mts_temp << Shift_amount;
    assign Out[22 : 0] = Mts_shifted[47 : 25];
endmodule
