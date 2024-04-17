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

// ================================================================================
// Declaration : registers, wires
// ================================================================================
    reg     [6:0]   CUR_STATE;
    reg     [2:0]   REG_STATE;
    reg     [31:0]  REG_TOP;
    reg     [31:0]  REG_LEFT;
    reg     [31:0]  REG_MUL;
    reg     [31:0]  REG_ADD;
    reg     [31:0]  FW_ADD;
    wire    [31:0]  RESULT_MUL;
    wire    [31:0]  RESULT_ADD;
    wire            RESULT_isZero;

// ================================================================================
// RESET = 0 : reset all the register to 0
// ================================================================================
    always @(negedge RST_N) begin
        REG_STATE   <=  3'b0;
        REG_TOP     <= 32'b0;
        REG_LEFT    <= 32'b0;
        REG_MUL     <= 32'b0;
        REG_ADD     <= 32'b0;
        OUT         <= 32'b0;
        CUR_STATE   <= 7'b0;
        FW_ADD      <= 32'b0;
    end

    always @(posedge CLK) CUR_STATE <= CUR_STATE + 1;
    always @(posedge CLK) 
        if (REG_STATE < 3'd2)
            REG_STATE <= REG_STATE + 1;

// ================================================================================
// STAGE 1: Store input to REG_TOP, REG_LEFT
// ================================================================================
    always @(posedge CLK) begin
        REG_TOP     <= IN_TOP;
        REG_LEFT    <= IN_LEFT;
    end
    assign OUT_BOTTOM   = IN_TOP;
    assign OUT_RIGHT    = IN_LEFT;

// ================================================================================
// STAGE 2: REG_TOP * REG_LEFT, result stores in pipeline register (REG_MUL)
// ================================================================================
    FP_Multiplier MUL(
        REG_TOP, REG_LEFT, RESULT_MUL
    );
    always @(posedge CLK) begin 
        if (~(|REG_TOP) | ~(|REG_LEFT))
            REG_MUL     <= `FPZero;
        else
            REG_MUL     <= RESULT_MUL;
    end

// ================================================================================
// STAGE 3: OUT + REG_MUL , result stores in pipeline register (REG_ADD)
// ================================================================================
    FP_Adder_Subtractor32 ADD(
        .Out(RESULT_ADD),       .isZero(RESULT_isZero),
        .A(FW_ADD),                .B(REG_MUL)
    );
    always @(posedge CLK) begin
        if (REG_STATE == 3'd3)
            FW_ADD      <= REG_ADD;
        else
            FW_ADD      <= `FPZero;

        if ((~(|OUT) & ~(|REG_MUL )) | RESULT_isZero)
            REG_ADD     <= `FPZero;
        else if (~|OUT) 
            REG_ADD     <= REG_MUL ;
        else if (~|REG_MUL ) 
            REG_ADD     <= OUT;
        else 
            REG_ADD     <= RESULT_ADD;
    end

// ================================================================================
// STAGE 4: REG_ADD  -> OUT
// ================================================================================
    always @(posedge CLK) begin
        OUT             <= REG_ADD ;
        
    end

endmodule

`endif