module Int_Multiplier(
    input [23:0] a, b,
    output [47:0] product
);

// ================================================================================
// Declare Wires
// ================================================================================

    wire [47:0] s00, c00, s01, c01, s02, c02, s03, c03, s04, c04, s05, c05, s06, c06, s07, c07;
    wire [47:0] s10, c10, s11, c11, s12, c12, s13, c13, s14, c14;
    wire [47:0] s20, c20, s21, c21, s22, c22;
    wire [47:0] s30, c30, s31, c31;
    wire [47:0] s40, c40, s41, c41;
    wire [47:0] s50, c50;
    wire [47:0] s60, c60;
    wire [47:0] 
        p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, 
        p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, 
        p20, p21, p22, p23;
    
// ================================================================================
// Generate Products
// ================================================================================

    assign p0 = a & {24{b[0]}};
    assign p1 = a & {24{b[1]}};
    assign p2 = a & {24{b[2]}};
    assign p3 = a & {24{b[3]}};
    assign p4 = a & {24{b[4]}};
    assign p5 = a & {24{b[5]}};
    assign p6 = a & {24{b[6]}};
    assign p7 = a & {24{b[7]}};
    assign p8 = a & {24{b[8]}};
    assign p9 = a & {24{b[9]}};
    assign p10 = a & {24{b[10]}};
    assign p11 = a & {24{b[11]}};
    assign p12 = a & {24{b[12]}};
    assign p13 = a & {24{b[13]}};
    assign p14 = a & {24{b[14]}};
    assign p15 = a & {24{b[15]}};
    assign p16 = a & {24{b[16]}};
    assign p17 = a & {24{b[17]}};
    assign p18 = a & {24{b[18]}};
    assign p19 = a & {24{b[19]}};
    assign p20 = a & {24{b[20]}};
    assign p21 = a & {24{b[21]}};
    assign p22 = a & {24{b[22]}};
    assign p23 = a & {24{b[23]}};


    CarrySaveAdder48 add_00(p0,      p1<<1,   p2<<2,   s00, c00);
    CarrySaveAdder48 add_01(p3<<3,   p4<<4,   p5<<5,   s01, c01);
    CarrySaveAdder48 add_02(p6<<6,   p7<<7,   p8<<8,   s02, c02);
    CarrySaveAdder48 add_03(p9<<9,   p10<<10, p11<<11, s03, c03);
    CarrySaveAdder48 add_04(p12<<12, p13<<13, p14<<14, s04, c04);
    CarrySaveAdder48 add_05(p15<<15, p16<<16, p17<<17, s05, c05);
    CarrySaveAdder48 add_06(p18<<18, p19<<19, p20<<20, s06, c06);
    CarrySaveAdder48 add_07(p21<<21, p22<<22, p23<<23, s07, c07);


    CarrySaveAdder48 add_10(s00,    c00<<1,  s01,    s10, c10);
    CarrySaveAdder48 add_11(c01<<1, s02,     c02<<1, s11, c11);
    CarrySaveAdder48 add_12(s03,    c03<<1,  s04,    s12, c12);
    CarrySaveAdder48 add_13(c04<<1, s05,     c05<<1, s13, c13);
    CarrySaveAdder48 add_14(s06,    c06<<1,  s07,    s14, c14); // c07


    CarrySaveAdder48 add_20(s10,    c10<<1, s11,    s20, c20);
    CarrySaveAdder48 add_21(c11<<1, s12,    c12<<1, s21, c21);
    CarrySaveAdder48 add_22(s13,    c13<<1, s14,    s22, c22); // c14


    CarrySaveAdder48 add_30(s20, c20<<1, s21, s30, c30);
    CarrySaveAdder48 add_31(c21<<1, s22, c22<<1, s31, c31);


    CarrySaveAdder48 add_40(s30,    c30<<1, s31,    s40, c40);
    CarrySaveAdder48 add_41(c31<<1, c07<<1, c14<<1, s41, c41);


    CarrySaveAdder48 add_50(s40, c40<<1, s41, s50, c50); // c41


    CarrySaveAdder48 add_60(s50, c50<<1, c41<<1, s60, c60);

    CarryLookaheadAdder #(48) cla(product, , s60, c60<<1, 1'b0);
endmodule

module CarrySaveAdder48(
    input   [47:0]  a,
    input   [47:0]  b,
    input   [47:0]  c, 
    output  [47:0]  Sum, 
    output  [47:0]  Cout
);
    assign Sum = a ^ b ^ c;
    assign Cout = a&b | b&c | a&c;
endmodule
