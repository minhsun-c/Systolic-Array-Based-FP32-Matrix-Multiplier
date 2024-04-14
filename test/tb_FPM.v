`include "src/include.v"

module tb;
    reg     [31:0]  A;
    reg     [31:0]  B;
    wire    [31:0]  Out;

    FP_Multiplier MUL(
        A, B, Out
    );

    initial begin
        $dumpfile("build/FPM.vcd");
        $dumpvars(0, tb);

        // 6.5 * 3.75 = 24.375 : 0_10000011_10000110000000000000000
        A = 32'h40d00000;   // 6.5  : 0_10000001_10100000000000000000000
        B = 32'h40700000;   // 3.75 : 0_10000000_11100000000000000000000
        #2
        // // 6240.5625 * 
        // A = 32'h45c30480;   // 6240.5625 : 0_10001011_10000110000010010000000
        // B = 32'h0f8300c0;   // 
        $finish;

    end
endmodule