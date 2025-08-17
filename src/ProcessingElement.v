module P_Element(
    output reg  [31:0]  out,
    output      [31:0]  bottom_o,
    output      [31:0]  right_o,
    input       [31:0]  top_i,
    input       [31:0]  left_i,
    input               clk,            // Positive Edge Triggered
    input               rst_n           // Negative Edge Triggered
);

// ==============================================================================================
// Declaration : registers, wires
// ==============================================================================================
    reg     [31:0]  REG_TOP;        // To store input from top of PE
    reg     [31:0]  REG_LEFT;       // To store input from left of PE
    reg     [31:0]  REG_MUL;        // To store the product of REG_TOP, REG_LEFT
    reg     [31:0]  REG_ADD;        // To store the sum of product, out
    reg     [31:0]  PRE_ADD;        // Give the correct operand for Adder, depend by CUR_STATE
    wire    [31:0]  RESULT_MUL;     
    wire    [31:0]  RESULT_ADD;
    wire            RESULT_isZero;

// ==============================================================================================
// STAGE 1: Store input to REG_TOP, REG_LEFT
// ==============================================================================================
    always @(posedge clk) begin
        if (rst_n == 1'b0) begin
            REG_TOP     <= `FPZero;
            REG_LEFT    <= `FPZero;
        end
        else begin
            REG_TOP     <= top_i;
            REG_LEFT    <= left_i;
        end
    end
    assign bottom_o   = REG_TOP;
    assign right_o    = REG_LEFT;

// ==============================================================================================
// STAGE 2: REG_TOP * REG_LEFT, result stores in pipeline register (REG_MUL)
// ==============================================================================================
    FP_Multiplier MUL(
        REG_TOP, REG_LEFT, RESULT_MUL
    );
    always @(posedge clk) begin 
        if (rst_n == 1'b0) begin
            REG_MUL     <= `FPZero;
        end
        else if (~(|REG_TOP) | ~(|REG_LEFT))
            REG_MUL     <= `FPZero;
        else
            REG_MUL     <= RESULT_MUL;
    end

// ==============================================================================================
// STAGE 3: out + REG_MUL , result stores in pipeline register (REG_ADD)
//      BUT data hazard occurs between stage 3, 4.
//      Therefore, adding a forwarding path instead passing `out` directly
// Forwarding Path:
//      Store the previous sum in register (PRE_ADD), then add it with REG_MUL  
// ==============================================================================================
    FP_Adder_Subtractor32 ADD(
        .Out(RESULT_ADD),       .isZero(RESULT_isZero),
        .A(REG_MUL),                .B(PRE_ADD)
    );
    always @(posedge clk) begin
        if (rst_n == 1'b0) begin
            REG_ADD     <= `FPZero;
            PRE_ADD     <= `FPZero;
        end
        // (out == 0 && REG_MUL == 0) or (A + B == 0)
        else if ((~(|PRE_ADD) & ~(|REG_MUL )) | RESULT_isZero) begin
            REG_ADD     <= `FPZero;
            PRE_ADD     <= `FPZero;
        end
        // out == 0
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
// STAGE 4: REG_ADD  -> out
// ==============================================================================================
    always @(posedge clk) begin
        if (rst_n == 1'b0) begin
            out         <= `FPZero; 
        end
        else begin
            out         <= REG_ADD ;
        end
    end

endmodule
