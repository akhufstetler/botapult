module div32(ctrl, on, dvnd, dvsr, clk, result, e, rdy);

// Defining I/O
    input [31:0] dvnd, dvsr;
    input ctrl, on, clk;

    output [31:0] result;
    output e, rdy;

// Initial Calculations
    wire [63:0] rem_quo;
    wire [31:0] new_dvnd, not_dvsr, quot, rmdr, tc_dvnd, tc_dvsr, tc_quot;

    assign rmdr = rem_quo[63:32];
    assign quot = rem_quo[31:0];
    neg_2s_32 dvndTC(dvnd, tc_dvnd);
	neg_2s_32 dvsrTC(dvsr, tc_dvsr);
	neg_2s_32 quotTC(quot, tc_quot);
    assign new_dvnd = dvnd[31] ? tc_dvnd : dvnd;
    assign not_dvsr = dvsr[31] ? ~tc_dvsr : ~dvsr;

// Subtractor
    wire [31:0] sub_result;
    wire ne, lt, of, nlt;

    cla_32bit subtractor(rmdr, not_dvsr, 1'b1, sub_result, ne, lt, of);
    assign nlt = ~lt;

// Counter
    wire [5:0] count;

    counter64 counter(count, clk, on, ctrl);

// Shifting Register
    wire [63:0] reg_in;
    wire reg_in_ctrl, reg_en;

    assign reg_en = |(~count);
    assign reg_in_ctrl = |count;
    assign reg_in[63:32] = nlt ? sub_result : rmdr;
    assign reg_in[31:0] = reg_in_ctrl ? quot : new_dvnd;

    reg_64_sl1 register(rem_quo, reg_in, nlt, clk, reg_en, reg_in_ctrl, ctrl);

// Final Output Calculations
    wire oppo_sign;

    assign oppo_sign = dvnd[31] ^ dvsr[31];
	assign result = oppo_sign ? tc_quot : quot;
    assign rdy = count[5] & ~count[4] & ~count[3] & ~count[2] & count[1] & ~count[0];
    assign e = (result[31] ^ oppo_sign) & |result[31:0];
    
endmodule