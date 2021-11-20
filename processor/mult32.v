module mult32 (ctrl, on, mcnd, mplr, clk, result, e, rdy);

// Defining I/O
    input [31:0] mcnd, mplr;
    input ctrl, on, clk;

    output [31:0] result;
    output e, rdy;

// Initial Calculations
    wire [64:0] product;
    wire [31:0] not_mcnd, sl_mcnd, not_sl_mcnd;

    assign sl_mcnd[0] = 1'b0;
    assign sl_mcnd[31:1] = mcnd[30:0];
    assign not_mcnd = ~mcnd;
    assign not_sl_mcnd = ~sl_mcnd;

// Adders
    wire [31:0] add_result, add_operand;
    wire [31:0] a_cnd, s_cnd, a_sr_cnd, s_sr_cnd;
    wire [11:0] tmp_ovf;

    assign add_operand = product[64:33];

    cla_32bit add_mcand(add_operand, mcnd, 1'b0, a_cnd, tmp_ovf[0], tmp_ovf[4], tmp_ovf[8]);
    cla_32bit sub_mcand(add_operand, not_mcnd, 1'b1, s_cnd, tmp_ovf[1], tmp_ovf[5], tmp_ovf[9]);
    cla_32bit add_mcans(add_operand, sl_mcnd, 1'b0, a_sr_cnd, tmp_ovf[2], tmp_ovf[6], tmp_ovf[10]);
    cla_32bit sub_mcans(add_operand, not_sl_mcnd, 1'b1, s_sr_cnd, tmp_ovf[3], tmp_ovf[7], tmp_ovf[11]);

    mux_8 booth_mux(add_result, product[2:0], add_operand, a_cnd, a_cnd, a_sr_cnd, s_sr_cnd, s_cnd, s_cnd, add_operand);

// Counter
    wire [4:0] count;

    counter32 counter(count, clk, on, ctrl);

// Shifting Register
    wire [64:0] reg_in;
    wire [32:0] apnd_mult, reg_in_lsb;
    wire reg_in_ctrl, reg_en;

    assign reg_in_ctrl = |count;
    not(reg_en, rdy);
    not(reg_en, rdy);
    assign apnd_mult = { mplr, 1'b0 };

    mux_2_33 reg_lsb_mux(reg_in_lsb, reg_in_ctrl, apnd_mult, product[32:0]);

    assign reg_in = { add_result, reg_in_lsb };

    reg_65_sr2 register(product, reg_in, clk, reg_en, reg_in_ctrl, ctrl);

// Final Output Calculations
    wire oppo_sign;

    assign oppo_sign = mcnd[31] ^ mplr[31];
    assign result = product[32:1];
    assign rdy = count[4] & ~count[3] & ~count[2] & ~count[1] & count[0];
    assign e = (result[31] ^ &product[64:33]) || (result[31] ^ |product[64:33]) | ((result[31] ^ oppo_sign) & (|mcnd) & (|mplr));

endmodule