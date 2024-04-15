`include "src/include.v"

module tb;

    wire  [31 : 0]          Out;
    wire                    Zero;
    reg   [31 : 0]          A;
    reg   [31 : 0]          B;

    FP_Adder_Subtractor32 FPAS(
        .Out(Out),
        .isZero(Zero),
        .A(A),
        .B(B)
    );
    initial begin
        $dumpfile("build/FPA.vcd");
        $dumpvars(0, tb);
    end

    initial begin
        // 12.5
        A = 32'h40c80000; // 6.25
        B = 32'h40c80000; // 6.25
        #2
        // 0
        A = 32'h40c80000; // 6.25
        B = 32'hc0c80000; // -6.25
        #2
        // -1.5
        A = 32'h40c80000; // 6.25
        B = 32'hc0f80000; // -7.75
        #2
        // 2.875
        A = 32'hc0580000; // -3.375
        B = 32'h40c80000; // 6.25
        #2
        $finish;
    end

endmodule