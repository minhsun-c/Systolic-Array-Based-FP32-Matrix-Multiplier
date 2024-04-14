`ifndef __LEADING_ZERO_DETECTOR
`define __LEADING_ZERO_DETECTOR

module LZDetector08(
    output reg  [2:0]   s,
    input       [7:0]   q 
); 
    always@(*)begin
        s[2] = ~(|q[7:4]);
        s[1] = (s[2]) ? ~(|q[3:2]) : ~(|q[7:6]);
        case({s[2], s[1]})
            2'b00 : s[0] = ~q[7];
            2'b01 : s[0] = ~q[5];
            2'b10 : s[0] = ~q[3];
            2'b11 : s[0] = ~q[1];
        endcase
    end
endmodule

module LZDetector32(
    output reg  [4:0]   s,
    input       [31:0]  q 
);
    wire result16, result8_0, result8_1, result4_0, result4_1, result4_2, result4_3;
    wire m_result04, m_result08, m_result16;
    wire [3:0] r4;

    assign result16  = ~(|q[31:16]);
    assign result8_0 = ~(|q[31:24]);
    assign result8_1 = ~(|q[15:8]);
    assign result4_0 = ~(|q[31:28]);
    assign result4_1 = ~(|q[23:20]);
    assign result4_2 = ~(|q[15:12]);
    assign result4_3 = ~(|q[7:4]);
    assign r4        = {result4_3, result4_2, result4_1, result4_0};

    always@(*) begin
        s[4] = result16;
        s[3] = (s[4])? result8_1:result8_0;
        s[2] = m_result04;
        s[1] = m_result08;
        s[0] = m_result16;
    end
endmodule

module LZDetector48(
    output      [5:0]   s,
    input       [47:0]  q 
);
    wire        result32, result16_0, result16_1;
    wire        m_result04, m_result08, m_result16, m_result32;
    wire [3:0]  r04;
    wire [7:0]  r08;
    wire [15:0] r16;
    wire [31:0] r32;

    assign result32     = ~(|q[47:16]);
    assign result16_0   = ~(|q[47:32]);
    assign result16_1   = ~(|q[15:0]);
    
    assign r04 = {
        1'b0, 
        ~(|q[15:8]), ~(|q[31:24]), ~(|q[47:40])
    };
    assign r08 = {
        2'b0,
        ~(|q[7:4]), ~(|q[15:12]), ~(|q[23:20]), ~(|q[31:28]), 
        ~(|q[39:36]), ~(|q[47:44])
    };
    assign r16 = {
        4'b0, 
        ~(|q[3:2]), ~(|q[7:6]), ~(|q[11:10]), ~(|q[15:14]), 
        ~(|q[19:18]), ~(|q[23:22]), ~(|q[27:26]), ~(|q[31:30]), 
        ~(|q[35:34]), ~(|q[39:38]), ~(|q[43:42]), ~(|q[47:46])
    };
    assign r32 = {
        8'b0, 
        ~q[1], ~q[3], ~q[5], ~q[7], ~q[9], ~q[11], ~q[13], 
        ~q[15], ~q[17], ~q[19], ~q[21], ~q[23], ~q[25], ~q[27], 
        ~q[29], ~q[31], ~q[33], ~q[35], ~q[37], ~q[39], ~q[41], 
        ~q[43], ~q[45], ~q[47]
    };

    assign m_result04 = r04[s[5:4]];
    assign m_result08 = r08[s[5:3]];
    assign m_result16 = r16[s[5:2]];
    assign m_result32 = r32[s[5:1]];

    assign s = {
        result32,
        (s[5]) ? result16_1 : result16_0,
        m_result04,
        m_result08,
        m_result16,
        m_result32
    };

endmodule

`endif