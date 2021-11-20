module mux_32(out, sel, i0, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24, i25, i26, i27, i28, i29, i30, i31);

    input [4:0] sel;
    input [31:0] i0, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24, i25, i26, i27, i28, i29, i30, i31;

    output [31:0] out;

    wire [31:0] w1, w2;

    mux_16 ftop(w1, sel[3:0], i0, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15);
    mux_16 fbot(w2, sel[3:0], i16, i17, i18, i19, i20, i21, i22, i23, i24, i25, i26, i27, i28, i29, i30, i31);
    mux_2 seco(out, sel[4], w1, w2);

endmodule

module mux_16(out, sel, i0, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15);

    input [3:0] sel;
    input [31:0] i0, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15;

    output [31:0] out;

    wire [31:0] w1, w2;

    mux_8 ftop(w1, sel[2:0], i0, i1, i2, i3, i4, i5, i6, i7);
    mux_8 fbot(w2, sel[2:0], i8, i9, i10, i11, i12, i13, i14, i15);
    mux_2 seco(out, sel[3], w1, w2);

endmodule

module mux_8(out, sel, i0, i1, i2, i3, i4, i5, i6, i7);

    input [2:0] sel;
    input [31:0] i0, i1, i2, i3, i4, i5, i6, i7;

    output [31:0] out;

    wire [31:0] w1, w2;

    mux_4 ftop(w1, sel[1:0], i0, i1, i2, i3);
    mux_4 fbot(w2, sel[1:0], i4, i5, i6, i7);
    mux_2 seco(out, sel[2], w1, w2);

endmodule

module mux_4(out, sel, i0, i1, i2, i3);

    input [1:0] sel;
    input [31:0] i0, i1, i2, i3;

    output [31:0] out;

    wire [31:0] w1, w2;

    mux_2 ftop(w1, sel[0], i0, i1);
    mux_2 fbot(w2, sel[0], i2, i3);
    mux_2 secd(out, sel[1], w1, w2);

endmodule

module mux_2(out, sel, i0, i1);

    input sel;
    input [31:0] i0, i1;

    output [31:0] out;

    assign out = sel ? i1 : i0;

endmodule

module mux_2_33(out, sel, i0, i1);

    input sel;
    input [32:0] i0, i1;

    output [32:0] out;

    assign out = sel ? i1 : i0;

endmodule