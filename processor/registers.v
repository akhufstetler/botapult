module reg_32 (q, d, clk, en, clr);

    input [31:0] d;
    input clk, en, clr;

    output [31:0] q;

    genvar i;

    for (i = 0; i < 32; i = i + 1) begin
        dffe_ref REG(q[i], d[i], clk, en, clr);
    end

endmodule

module reg_32_inv (q, d, clk, en, clr);

    input [31:0] d;
    input clk, en, clr;

    output [31:0] q;

    genvar i;

    for (i = 0; i < 32; i = i + 1) begin
        dffe_neg REG(q[i], d[i], clk, en, clr);
    end

endmodule

module reg_6 (q, d, clk, en, clr);

    input [5:0] d;
    input clk, en, clr;

    output [5:0] q;

    genvar i;

    for (i = 0; i < 6; i = i + 1) begin
        dffe_ref REG(q[i], d[i], clk, en, clr);
    end

endmodule

module reg_5 (q, d, clk, en, clr);

    input [4:0] d;
    input clk, en, clr;

    output [4:0] q;

    genvar i;

    for (i = 0; i < 5; i = i + 1) begin
        dffe_ref REG(q[i], d[i], clk, en, clr);
    end

endmodule

module reg_65_sr2 (q, d, clk, en, sr_en, clr);

    input [64:0] d;
    input clk, en, sr_en, clr;

    output [64:0] q;

    genvar i;

    for (i = 0; i < 63; i = i + 1) begin
        wire tmp;

        assign tmp = sr_en ? d[i+2] : d[i];

        dffe_ref REG(q[i], tmp, clk, en, clr);
    end

    wire tmp;

    assign tmp = sr_en ? d[64] : d[63];
    dffe_ref REG63(q[63], tmp, clk, en, clr);
    dffe_ref REG64(q[64], d[64], clk, en, clr);

endmodule

module reg_64_sl1 (q, d, lsb, clk, en, sl_en, clr);

    input [63:0] d;
    input lsb, clk, en, sl_en, clr;

    output [63:0] q;

    genvar i;

    for (i = 1; i < 64; i = i + 1) begin
        wire tmp;

        assign tmp = sl_en ? d[i-1] : d[i];

        dffe_ref REG(q[i], tmp, clk, en, clr);
    end

    wire tmp;

    assign tmp = sl_en ? lsb : d[0];
    dffe_ref REG0(q[0], tmp, clk, en, clr);

endmodule