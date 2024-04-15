`include "src/include.v"

module tb;

    wire  [5 : 0]          Out;
    reg   [47 : 0]          A;

    LZDetector48 LZD(
        Out, A
    );

    initial begin
        $dumpfile("build/LZD.vcd");
        $dumpvars(0, tb);
    end

    initial begin
        A = 48'h100000000000;
        #2
        $finish;
    end

endmodule