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

        A = 32'h3f000000;     
        B = 32'h3f000000; 
        #2
         
        $finish;

    end
endmodule