`include "src/include.v"

module tb;

    reg                     clk;
    reg                     rst_n;
    reg     [31 : 0]        W0, W1, N0, N1;
    wire    [31 : 0]        out0_0, out0_1, out1_0, out1_1;

    Systolic_Array2x2 SYS(
        .out0_0(out0_0), 
        .out0_1(out0_1),
        .out1_0(out1_0), 
        .out1_1(out1_1),
        .W0(W0), 
        .W1(W1),
        .N0(N0), 
        .N1(N1),
        .clk(clk), 
        .reset(rst_n)
    );
    /*
    0.5     0.25    |   0.5     0.25
    0.125   0.5     |   0.125   0.5
    ====
    3E0 + 3D0   3E0 + 3E0
    3D8 + 3D8   3D0 + 3E8
    ===
    3E9 3E8
    3E0 3E9
    */
    initial begin
        $dumpfile("build/SYS2.vcd");
        $dumpvars(0, tb);
    end

    initial begin
        clk = 0;
        rst_n = 1;
        #1
        rst_n = 0;
        #2      
        W0 = 32'h3f000000;
        W1 = 32'h0;
        N0 = 32'h3f000000;
        N1 = 32'h0;
        clk = 1;    
        #2
        clk = 0;
        #2      
        W0 = 32'h3e800000;
        W1 = 32'h3e000000;
        N0 = 32'h3e000000;
        N1 = 32'h3e800000;
        clk = 1;    
        #2
        clk = 0;
        #2      
        W0 = 32'h0;
        W1 = 32'h3f000000;
        N0 = 32'h0;
        N1 = 32'h3f000000;
        clk = 1;    
        #2
        clk = 0;
        #2  
        W0 = 32'h0;
        W1 = 32'h0;
        N0 = 32'h0;
        N1 = 32'h0;
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
        $finish;
    end

endmodule