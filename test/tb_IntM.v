`include "src/include.v"

module tb;
    reg     [23:0]  A;
    reg     [23:0]  B;
    wire    [47:0]  Out;

    Int_Multiplier MUL(
        A, B, Out
    );

    initial begin
        $dumpfile("build/IntM.vcd");
        $dumpvars(0, tb);

        A = 24'b110100000000000000000000;   
        B = 24'b111100000000000000000000;   
        #5
        $finish;

    end
endmodule