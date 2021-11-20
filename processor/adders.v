module neg_2s_32(in, out);

    input [31:0] in;

    output [31:0] out;

    wire [2:0] tmp;

    cla_32bit adder(32'b0, ~in, 1'b1, out, tmp[0], tmp[1], tmp[2]);

endmodule

module cla_32bit(A, B, Cin, S, NE, LT, OF);
    
    input [31:0] A, B;
    input Cin;

    output [31:0] S;
    output NE, LT, OF;

    wire [3:0] P, G;
    wire [2:0] C;
    wire Cout;

    // First 8-bit Block
    cla_8bit block0(A[7:0], B[7:0], Cin, S[7:0], P[0], G[0]);

    //Calculating C8
    wire c8_tmp;
    and C8_AND(c8_tmp, P[0], Cin);
    or C8_OR(C[0], c8_tmp, G[0]);

    //Second 8-bit Block
    cla_8bit block1(A[15:8], B[15:8], C[0], S[15:8], P[1], G[1]);

    //Calculating C16
    wire c16_tmp[1:0];
    and C16_AND_1(c16_tmp[0], Cin, P[0], P[1]);
    and C16_AND_2(c16_tmp[1], G[0], P[1]);
    or C16_OR(C[1], G[1], c16_tmp[0], c16_tmp[1]);

    //Third 8-bit Block
    cla_8bit block2(A[23:16], B[23:16], C[1], S[23:16], P[2], G[2]);

    //Calculating C24
    wire c24_tmp[2:0];
    and C24_AND_1(c24_tmp[0], Cin, P[0], P[1], P[2]);
    and C24_AND_2(c24_tmp[1], G[0], P[1], P[2]);
    and C24_AND_3(c24_tmp[2], G[1], P[2]);
    or C24_OR(C[2], G[2], c24_tmp[0], c24_tmp[1], c24_tmp[2]);

    //Fourth 8-bit Block
    cla_8bit block3(A[31:24], B[31:24], C[2], S[31:24], P[3], G[3]);

    //Calculating C24
    wire c32_tmp[3:0];
    and C32_AND_1(c32_tmp[0], Cin, P[0], P[1], P[2], P[3]);
    and C32_AND_2(c32_tmp[1], G[0], P[1], P[2], P[3]);
    and C32_AND_3(c32_tmp[2], G[1], P[2], P[3]);
    and C32_AND_4(c32_tmp[3], G[2], P[3]);
    or C32_OR(Cout, G[3], c32_tmp[0], c32_tmp[1], c32_tmp[2], c32_tmp[3]);

    //Overflow
    assign OF = (~A[31] & ~B[31] & S[31]) | (A[31] & B[31] & ~S[31]);

    //Not Equal
    assign NE = |S[31:0];

    //Less Than
    assign LT = S[31] ^ OF;

endmodule

module cla_8bit(A, B, Cin, S, P, G);

    input [7:0] A, B;
    input Cin;
    output [7:0] S;
    output P, G;

    // Calculating P
    wire P, p0, p1, p2, p3, p4, p5, p6, p7;

    or P_OR_0(p0, A[0], B[0]);
    or P_OR_1(p1, A[1], B[1]);
    or P_OR_2(p2, A[2], B[2]);
    or P_OR_3(p3, A[3], B[3]);
    or P_OR_4(p4, A[4], B[4]);
    or P_OR_5(p5, A[5], B[5]);
    or P_OR_6(p6, A[6], B[6]);
    or P_OR_7(p7, A[7], B[7]);

    and P_AND(P, p0, p1, p2, p3, p4, p5, p6, p7);

    //Calculating G
    wire G, g0, g1, g2, g3, g4, g5, g6, g7;

    and G_AND_0(g0, A[0], B[0]);
    and G_AND_1(g1, A[1], B[1]);
    and G_AND_2(g2, A[2], B[2]);
    and G_AND_3(g3, A[3], B[3]);
    and G_AND_4(g4, A[4], B[4]);
    and G_AND_5(g5, A[5], B[5]);
    and G_AND_6(g6, A[6], B[6]);
    and G_AND_7(g7, A[7], B[7]);

    wire pg0, pg1, pg2, pg3, pg4, pg5, pg6;

    and PG_AND_0(pg0, g0, p1, p2, p3, p4, p5, p6, p7);
    and PG_AND_1(pg1, g1, p2, p3, p4, p5, p6, p7);
    and PG_AND_2(pg2, g2, p3, p4, p5, p6, p7);
    and PG_AND_3(pg3, g3, p4, p5, p6, p7);
    and PG_AND_4(pg4, g4, p5, p6, p7);
    and PG_AND_5(pg5, g5, p6, p7);
    and PG_AND_6(pg6, g6, p7);

    or G_OR(G, pg0, pg1, pg2, pg3, pg4, pg5, pg6, g7);

    //Calculating intermediary carry-overs
    wire [7:0] carries;
    assign carries[0] = Cin;

    //C1
    wire c1_tmp;
    and C1_AND(c1_tmp, p0, carries[0]);
    or C1_OR(carries[1], c1_tmp, g0);

    //C2
    wire [1:0] c2_tmp;
    and C2_AND_1(c2_tmp[0], p1, g0);
    and C2_AND_2(c2_tmp[1], p1, p0, Cin);
    or C2_OR(carries[2], c2_tmp[0], c2_tmp[1], g1);

    //C3
    wire [2:0] c3_tmp;
    and C3_AND_1(c3_tmp[0], p2, g1);
    and C3_AND_2(c3_tmp[1], p2, p1, g0);
    and C3_AND_3(c3_tmp[2], p2, p1, p0, Cin);
    or C3_OR(carries[3], c3_tmp[0], c3_tmp[1], c3_tmp[2], g2);

    //C4
    wire [3:0] c4_tmp;
    and C4_AND_1(c4_tmp[0], p3, g2);
    and C4_AND_2(c4_tmp[1], p3, p2, g1);
    and C4_AND_3(c4_tmp[2], p3, p2, p1, g0);
    and C4_AND_4(c4_tmp[3], p3, p2, p1, p0, Cin);
    or C4_OR(carries[4], c4_tmp[0], c4_tmp[1], c4_tmp[2], c4_tmp[3], g3);

    //C5
    wire [4:0] c5_tmp;
    and C5_AND_1(c5_tmp[0], p4, g3);
    and C5_AND_2(c5_tmp[1], p4, p3, g2);
    and C5_AND_3(c5_tmp[2], p4, p3, p2, g1);
    and C5_AND_4(c5_tmp[3], p4, p3, p2, p1, g0);
    and C5_AND_5(c5_tmp[4], p4, p3, p2, p1, p0, Cin);
    or C5_OR(carries[5], c5_tmp[0], c5_tmp[1], c5_tmp[2], c5_tmp[3], c5_tmp[4], g4);

    //C6
    wire [5:0] c6_tmp;
    and C6_AND_1(c6_tmp[0], p5, g4);
    and C6_AND_2(c6_tmp[1], p5, p4, g3);
    and C6_AND_3(c6_tmp[2], p5, p4, p3, g2);
    and C6_AND_4(c6_tmp[3], p5, p4, p3, p2, g1);
    and C6_AND_5(c6_tmp[4], p5, p4, p3, p2, p1, g0);
    and C6_AND_6(c6_tmp[5], p5, p4, p3, p2, p1, p0, Cin);
    or C6_OR(carries[6], c6_tmp[0], c6_tmp[1], c6_tmp[2], c6_tmp[3], c6_tmp[4], c6_tmp[5], g5);

    //C6
    wire [6:0] c7_tmp;
    and C7_AND_1(c7_tmp[0], p6, g5);
    and C7_AND_2(c7_tmp[1], p6, p5, g4);
    and C7_AND_3(c7_tmp[2], p6, p5, p4, g3);
    and C7_AND_4(c7_tmp[3], p6, p5, p4, p3, g2);
    and C7_AND_5(c7_tmp[4], p6, p5, p4, p3, p2, g1);
    and C7_AND_6(c7_tmp[5], p6, p5, p4, p3, p2, p1, g0);
    and C7_AND_7(c7_tmp[6], p6, p5, p4, p3, p2, p1, p0, Cin);
    or C7_OR(carries[7], c7_tmp[0], c7_tmp[1], c7_tmp[2], c7_tmp[3], c7_tmp[4], c7_tmp[5], c7_tmp[6], g6);

    //Calculating S
    xor S_XOR_0(S[0], A[0], B[0], carries[0]);
    xor S_XOR_1(S[1], A[1], B[1], carries[1]);
    xor S_XOR_2(S[2], A[2], B[2], carries[2]);
    xor S_XOR_3(S[3], A[3], B[3], carries[3]);
    xor S_XOR_4(S[4], A[4], B[4], carries[4]);
    xor S_XOR_5(S[5], A[5], B[5], carries[5]);
    xor S_XOR_6(S[6], A[6], B[6], carries[6]);
    xor S_XOR_7(S[7], A[7], B[7], carries[7]);

endmodule

module cla_6bit(A, B, Cin, S);

    input [5:0] A, B;
    input Cin;
    output [5:0] S;

    // Calculating P
    wire p0, p1, p2, p3, p4, p5;

    or P_OR_0(p0, A[0], B[0]);
    or P_OR_1(p1, A[1], B[1]);
    or P_OR_2(p2, A[2], B[2]);
    or P_OR_3(p3, A[3], B[3]);
    or P_OR_4(p4, A[4], B[4]);
    or P_OR_5(p5, A[5], B[5]);

    //Calculating G
    wire g0, g1, g2, g3, g4, g5;

    and G_AND_0(g0, A[0], B[0]);
    and G_AND_1(g1, A[1], B[1]);
    and G_AND_2(g2, A[2], B[2]);
    and G_AND_3(g3, A[3], B[3]);
    and G_AND_4(g4, A[4], B[4]);
    and G_AND_5(g5, A[5], B[5]);

    //Calculating intermediary carry-overs
    wire [5:0] carries;
    assign carries[0] = Cin;

    //C1
    wire c1_tmp;
    and C1_AND(c1_tmp, p0, carries[0]);
    or C1_OR(carries[1], c1_tmp, g0);

    //C2
    wire [1:0] c2_tmp;
    and C2_AND_1(c2_tmp[0], p1, g0);
    and C2_AND_2(c2_tmp[1], p1, p0, Cin);
    or C2_OR(carries[2], c2_tmp[0], c2_tmp[1], g1);

    //C3
    wire [2:0] c3_tmp;
    and C3_AND_1(c3_tmp[0], p2, g1);
    and C3_AND_2(c3_tmp[1], p2, p1, g0);
    and C3_AND_3(c3_tmp[2], p2, p1, p0, Cin);
    or C3_OR(carries[3], c3_tmp[0], c3_tmp[1], c3_tmp[2], g2);

    //C4
    wire [3:0] c4_tmp;
    and C4_AND_1(c4_tmp[0], p3, g2);
    and C4_AND_2(c4_tmp[1], p3, p2, g1);
    and C4_AND_3(c4_tmp[2], p3, p2, p1, g0);
    and C4_AND_4(c4_tmp[3], p3, p2, p1, p0, Cin);
    or C4_OR(carries[4], c4_tmp[0], c4_tmp[1], c4_tmp[2], c4_tmp[3], g3);

    //C5
    wire [4:0] c5_tmp;
    and C5_AND_1(c5_tmp[0], p4, g3);
    and C5_AND_2(c5_tmp[1], p4, p3, g2);
    and C5_AND_3(c5_tmp[2], p4, p3, p2, g1);
    and C5_AND_4(c5_tmp[3], p4, p3, p2, p1, g0);
    and C5_AND_5(c5_tmp[4], p4, p3, p2, p1, p0, Cin);
    or C5_OR(carries[5], c5_tmp[0], c5_tmp[1], c5_tmp[2], c5_tmp[3], c5_tmp[4], g4);

    //Calculating S
    xor S_XOR_0(S[0], A[0], B[0], carries[0]);
    xor S_XOR_1(S[1], A[1], B[1], carries[1]);
    xor S_XOR_2(S[2], A[2], B[2], carries[2]);
    xor S_XOR_3(S[3], A[3], B[3], carries[3]);
    xor S_XOR_4(S[4], A[4], B[4], carries[4]);
    xor S_XOR_5(S[5], A[5], B[5], carries[5]);

endmodule

module cla_5bit(A, B, Cin, S);

    input [4:0] A, B;
    input Cin;
    output [4:0] S;

    // Calculating Ps
    wire p0, p1, p2, p3, p4;

    or P_OR_0(p0, A[0], B[0]);
    or P_OR_1(p1, A[1], B[1]);
    or P_OR_2(p2, A[2], B[2]);
    or P_OR_3(p3, A[3], B[3]);
    or P_OR_4(p4, A[4], B[4]);

    //Calculating Gs
    wire g0, g1, g2, g3, g4;

    and G_AND_0(g0, A[0], B[0]);
    and G_AND_1(g1, A[1], B[1]);
    and G_AND_2(g2, A[2], B[2]);
    and G_AND_3(g3, A[3], B[3]);
    and G_AND_4(g4, A[4], B[4]);

    //Calculating intermediary carry-overs
    wire [4:0] carries;
    assign carries[0] = Cin;

    //C1
    wire c1_tmp;
    and C1_AND(c1_tmp, p0, carries[0]);
    or C1_OR(carries[1], c1_tmp, g0);

    //C2
    wire [1:0] c2_tmp;
    and C2_AND_1(c2_tmp[0], p1, g0);
    and C2_AND_2(c2_tmp[1], p1, p0, Cin);
    or C2_OR(carries[2], c2_tmp[0], c2_tmp[1], g1);

    //C3
    wire [2:0] c3_tmp;
    and C3_AND_1(c3_tmp[0], p2, g1);
    and C3_AND_2(c3_tmp[1], p2, p1, g0);
    and C3_AND_3(c3_tmp[2], p2, p1, p0, Cin);
    or C3_OR(carries[3], c3_tmp[0], c3_tmp[1], c3_tmp[2], g2);

    //C4
    wire [3:0] c4_tmp;
    and C4_AND_1(c4_tmp[0], p3, g2);
    and C4_AND_2(c4_tmp[1], p3, p2, g1);
    and C4_AND_3(c4_tmp[2], p3, p2, p1, g0);
    and C4_AND_4(c4_tmp[3], p3, p2, p1, p0, Cin);
    or C4_OR(carries[4], c4_tmp[0], c4_tmp[1], c4_tmp[2], c4_tmp[3], g3);

    //Calculating S
    xor S_XOR_0(S[0], A[0], B[0], carries[0]);
    xor S_XOR_1(S[1], A[1], B[1], carries[1]);
    xor S_XOR_2(S[2], A[2], B[2], carries[2]);
    xor S_XOR_3(S[3], A[3], B[3], carries[3]);
    xor S_XOR_4(S[4], A[4], B[4], carries[4]);

endmodule