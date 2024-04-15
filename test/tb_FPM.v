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

        A = 32'h3f000000;   // 0.5  
        B = 32'h3f000000;   // 0.5
        #2
        // 21.875 : 41af0000
        A = 32'h3f000000;   // 3.5  
        B = 32'h3f000000;   // 6.25
        #2
         
        $finish;

    end
endmodule