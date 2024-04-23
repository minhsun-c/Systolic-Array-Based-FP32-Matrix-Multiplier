`ifndef __PROCESSING_ELEMENT
`define __PROCESSING_ELEMENT

module P_Element(
    output reg  [31:0]  OUT,
    output      [31:0]  OUT_BOTTOM,
    output      [31:0]  OUT_RIGHT,
    input       [31:0]  IN_TOP,
    input       [31:0]  IN_LEFT,
    input               CLK,            // Positive Edge Triggered
    input               RST_N           // Negative Edge Triggered
);

// ==============================================================================================
// Declaration : registers, wires
// ==============================================================================================
    reg             OUT_CHECK;      // Decide `OUT` should be replaced or not
    reg     [2:0]   CUR_STATE;      // Counter will decide whether we should add stall or not
    reg     [31:0]  REG_TOP;        // To store input from top of PE
    reg     [31:0]  REG_LEFT;       // To store input from left of PE
    reg     [31:0]  REG_MUL;        // To store the product of REG_TOP, REG_LEFT
    reg     [31:0]  REG_ADD;        // To store the sum of product, OUT
    reg     [31:0]  REG_STALL;      // To store REG_MUL for one more cycle
    wire    [31:0]  PRE_ADD;        // Give the correct operand for Adder, depend by CUR_STATE
    wire    [31:0]  RESULT_MUL;     
    wire    [31:0]  RESULT_ADD;
    wire            RESULT_isZero;

// ==============================================================================================
// RESET = 0 : reset all the register to 0
// ==============================================================================================
    always @(negedge RST_N) begin
        REG_TOP     <= 32'b0;
        REG_LEFT    <= 32'b0;
        REG_MUL     <= 32'b0;
        REG_ADD     <= 32'b0;
        REG_STALL   <= 32'b0;
        OUT         <= 32'b0;
        CUR_STATE   <= 3'b0;
        OUT_CHECK   <= 1'b0;
    end

    always @(posedge CLK) begin
        if (CUR_STATE <= 3'd3)
            CUR_STATE <= CUR_STATE + 1; 
        else
            CUR_STATE <= CUR_STATE;
    end


// ==============================================================================================
// STAGE 1: Store input to REG_TOP, REG_LEFT
// ==============================================================================================
    always @(posedge CLK) begin
        REG_TOP     <= IN_TOP;
        REG_LEFT    <= IN_LEFT;
    end
    assign OUT_BOTTOM   = IN_TOP;
    assign OUT_RIGHT    = IN_LEFT;

// ==============================================================================================
// STAGE 2: REG_TOP * REG_LEFT, result stores in pipeline register (REG_MUL)
// ==============================================================================================
    FP_Multiplier MUL(
        REG_TOP, REG_LEFT, RESULT_MUL
    );
    always @(posedge CLK) begin 
        if (~(|REG_TOP) | ~(|REG_LEFT))
            REG_MUL     <= `FPZero;
        else
            REG_MUL     <= RESULT_MUL;
    end

// ==============================================================================================
// STAGE 3: STALL
// ==============================================================================================
    always @(posedge CLK) begin
        REG_STALL       <= REG_MUL; 
    end
// ==============================================================================================
// STAGE 4: OUT + REG_MUL , result stores in pipeline register (REG_ADD)
// ==============================================================================================
    assign PRE_ADD = (CUR_STATE > 3'd3) ? REG_STALL : REG_MUL;
    
    FP_Adder_Subtractor32 ADD(
        .Out(RESULT_ADD),       .isZero(RESULT_isZero),
        .A(OUT),                .B(PRE_ADD)
    );
    always @(posedge CLK) begin
        // (OUT == 0 && REG_MUL == 0) or (A + B == 0)
        if ((~(|OUT) & ~(|REG_MUL )) | RESULT_isZero)
            REG_ADD     <= `FPZero;
        // OUT == 0
        else if (~|OUT) 
            REG_ADD     <= REG_MUL ;
        // REG_MUL == 0
        else if (~|REG_MUL ) 
            REG_ADD     <= OUT;
        else 
            REG_ADD     <= RESULT_ADD;
    end

// ==============================================================================================
// STAGE 5: REG_ADD  -> OUT
// ==============================================================================================
    always @(posedge CLK) begin
        if (OUT_CHECK)
            OUT         <= REG_ADD ;
        else
            OUT         <= OUT;
        OUT_CHECK = ~OUT_CHECK;
    end

endmodule

`endif