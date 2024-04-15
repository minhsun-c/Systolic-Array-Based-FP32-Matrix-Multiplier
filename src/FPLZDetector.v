`ifndef __LEADING_ZERO_DETECTOR
`define __LEADING_ZERO_DETECTOR

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
    wire [5:0]  s_temp;

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

    assign m_result04 = r04[s_temp[5:4]];
    assign m_result08 = r08[s_temp[5:3]];
    assign m_result16 = r16[s_temp[5:2]];
    assign m_result32 = r32[s_temp[5:1]];

    assign s_temp = {
        result32,
        (s_temp[5]) ? result16_1 : result16_0,
        m_result04,
        m_result08,
        m_result16,
        m_result32
    };

    assign s = s_temp + 6'b1;

endmodule

`endif