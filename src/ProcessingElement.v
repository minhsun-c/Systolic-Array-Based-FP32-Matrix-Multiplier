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
    reg     [31:0]  PRE_ADD;        // Give the correct operand for Adder, depend by CUR_STATE
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
        PRE_ADD     <= 32'b0;
        OUT         <= 32'b0;
        CUR_STATE   <= 3'b0;
        OUT_CHECK   <= 1'b0;
    end

    always @(posedge CLK) begin
        if (CUR_STATE < 3'd2)begin 
            CUR_STATE <= CUR_STATE + 1; 
            OUT_CHECK <= OUT_CHECK; 
        end
        else if (CUR_STATE == 3'd2) begin
            CUR_STATE <= CUR_STATE + 1;
            OUT_CHECK <= 1'b1; 
        end
        else begin
            CUR_STATE <= CUR_STATE;
            OUT_CHECK <= ~OUT_CHECK;
        end
    end


// ==============================================================================================
// STAGE 1: Store input to REG_TOP, REG_LEFT
// ==============================================================================================
    always @(posedge CLK) begin
        REG_TOP     <= IN_TOP;
        REG_LEFT    <= IN_LEFT;
    end
    assign OUT_BOTTOM   = REG_TOP;
    assign OUT_RIGHT    = REG_LEFT;

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
// STAGE 3: OUT + REG_MUL , result stores in pipeline register (REG_ADD)
//      BUT data hazard occurs between stage 3, 4.
//      Therefore, adding a forwarding path instead passing `OUT` directly
// Forwarding Path:
//      Store the previous sum in register (PRE_ADD), then add it with REG_MUL  
// ==============================================================================================
    FP_Adder_Subtractor32 ADD(
        .Out(RESULT_ADD),       .isZero(RESULT_isZero),
        .A(REG_MUL),                .B(PRE_ADD)
    );
    always @(posedge CLK) begin
        // (OUT == 0 && REG_MUL == 0) or (A + B == 0)
        if ((~(|PRE_ADD) & ~(|REG_MUL )) | RESULT_isZero) begin
            REG_ADD     <= `FPZero;
            PRE_ADD     <= `FPZero;
        end
        // OUT == 0
        else if (~|PRE_ADD) begin
            REG_ADD     <= REG_MUL ;
            PRE_ADD     <= REG_MUL ;
        end
        // REG_MUL == 0
        else if (~|REG_MUL ) begin
            REG_ADD     <= PRE_ADD;
            PRE_ADD     <= PRE_ADD;
        end
        else begin
            REG_ADD     <= RESULT_ADD;
            PRE_ADD     <= RESULT_ADD;
        end
    end

// ==============================================================================================
// STAGE 4: REG_ADD  -> OUT
// ==============================================================================================
    always @(posedge CLK) begin
        OUT         <= REG_ADD ;
    end

endmodule

`endif