`include "src/include.v"

module tb;

    reg                     clk;
    reg                     rst_n;
    reg     [31 : 0]        W0, W1, W2, N0, N1, N2;
    wire    [31 : 0]        
        out0_0, out0_1, out0_2, 
        out1_0, out1_1, out1_2,
        out2_0, out2_1, out2_2;

    Systolic_Array3x3 SYS(
        .out0_0(out0_0), .out0_1(out0_1), .out0_2(out0_2),
        .out1_0(out1_0), .out1_1(out1_1), .out1_2(out1_2),
        .out2_0(out2_0), .out2_1(out2_1), .out2_2(out2_2),
        .W0(W0), 
        .W1(W1),
        .W2(W2),
        .N0(N0), 
        .N1(N1),
        .N2(N2),
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
        $dumpfile("build/SYS3.vcd");
        $dumpvars(0, tb);
    end

    initial begin
        clk = 0;
        rst_n = 0;
        #2
        clk = 1;
        #1
        rst_n = 1;
        #1
        clk = 0;
        #2  
        W0 = 32'h3f800000;  // 1
        W1 = 32'h0;
        W2 = 32'h0;
        N0 = 32'hc20dc000;  // -35.4375
        N1 = 32'h0;
        N2 = 32'h0;
        clk = 1;    
        #2
        clk = 0;
        #2      
        W0 = 32'h40400000;  // 3
        W1 = 32'h3f200000;  // 0.625
        W2 = 32'h0;
        N0 = 32'h42480000;  // 50
        N1 = 32'h4313d400;  // 147.828125
        N2 = 32'h0;
        clk = 1;    
        #2
        clk = 0;
        #2      
        W0 = 32'h3F000000;  // 0.5
        W1 = 32'h3EE00000;  // 0.4375
        W2 = 32'h425A0000;  // 54.5
        N0 = 32'h42888000;  // 68.25
        N1 = 32'hC292C000;  // -73.375
        N2 = 32'h00000000;  // 0
        clk = 1;    
        #2
        clk = 0;
        #2  
        W0 = 32'h00000000;  // 0
        W1 = 32'h41278000;  // 10.46875
        W2 = 32'hBE800000;  // -0.25
        N0 = 32'h00000000;  // 0
        N1 = 32'h00000000;  // 0
        N2 = 32'h3FC00000;  // 1.5
        clk = 1;    
        #2
        clk = 0;
        #2  
        W0 = 32'h00000000;  // 0
        W1 = 32'h00000000;  // 0
        W2 = 32'h42900000;  // 72
        N0 = 32'h00000000;  // 0
        N1 = 32'h00000000;  // 0
        N2 = 32'h41200000;  // 10
        clk = 1;    
        #2
        clk = 0;
        #2  
        W0 = 32'h0;
        W1 = 32'h0;
        W2 = 32'h0;
        N0 = 32'h0;
        N1 = 32'h0;
        N2 = 32'h0;
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