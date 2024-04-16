`include "src/include.v"

module tb;

    reg                     clk;
    reg                   rst_n;
    reg     [31 : 0]        Top;
    reg     [31 : 0]       Left;
    wire    [31 : 0]        Out;

    P_Element PE(
        .OUT(Out),
        .IN_TOP(Top),
        .IN_LEFT(Left),
        .CLK(clk),            
        .RST_N(rst_n)       
    );

    initial begin
        $dumpfile("build/PE.vcd");
        $dumpvars(0, tb);
    end

    initial begin
        clk = 0;
        rst_n = 1;
        #1
        rst_n = 0;
        #2      // 0.125 : 3E000000
        Top     = 32'h3f000000; // 0.5
        Left    = 32'h3E800000; // 0.25
        clk = 1;    // 0.125 : 3E000000
        #2
        clk = 0;
        #2      // 0.21875 : 3E600000
        Top     = 32'h3ee00000; // 0.4375
        Left    = 32'h3F000000; // 0.5
        clk = 1;    // 0.34375 : 3EB00000
        #2
        clk = 0;
        #2
        clk = 1;
        #2
        clk = 0;
        #2
        clk = 1;
        #2
        clk = 0;
        #2
        clk = 1;
        #2
        clk = 0;
        #2
        clk = 1;
        #2
        clk = 0;
        #2
        clk = 1;
        #2
        clk = 0;
        #2
        clk = 1;
        #2
        clk = 0;
        #2
        clk = 1;
        #2
        clk = 0;
        #2
        clk = 1;
        #2
        clk = 0;
        #2
        clk = 1;
        #2
        clk = 0;
        #2
        clk = 1;
        #2
        clk = 0;
        #2
        clk = 1;
        #2
        $finish;
    end

endmodule