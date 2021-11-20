module decoder_32 (ctrl, out);
    
    input [4:0] ctrl;
    output [31:0] out;

    wire [4:0] ctrl_neg;

    genvar i;

    for (i = 0; i < 5; i = i + 1) begin
        not(ctrl_neg[i], ctrl[i]);
    end

    and(out[0], ctrl_neg[4], ctrl_neg[3], ctrl_neg[2], ctrl_neg[1], ctrl_neg[0]);
    and(out[1], ctrl_neg[4], ctrl_neg[3], ctrl_neg[2], ctrl_neg[1], ctrl[0]);
    and(out[2], ctrl_neg[4], ctrl_neg[3], ctrl_neg[2], ctrl[1], ctrl_neg[0]);
    and(out[3], ctrl_neg[4], ctrl_neg[3], ctrl_neg[2], ctrl[1], ctrl[0]);
    and(out[4], ctrl_neg[4], ctrl_neg[3], ctrl[2], ctrl_neg[1], ctrl_neg[0]);
    and(out[5], ctrl_neg[4], ctrl_neg[3], ctrl[2], ctrl_neg[1], ctrl[0]);
    and(out[6], ctrl_neg[4], ctrl_neg[3], ctrl[2], ctrl[1], ctrl_neg[0]);
    and(out[7], ctrl_neg[4], ctrl_neg[3], ctrl[2], ctrl[1], ctrl[0]);
    and(out[8], ctrl_neg[4], ctrl[3], ctrl_neg[2], ctrl_neg[1], ctrl_neg[0]);
    and(out[9], ctrl_neg[4], ctrl[3], ctrl_neg[2], ctrl_neg[1], ctrl[0]);
    and(out[10], ctrl_neg[4], ctrl[3], ctrl_neg[2], ctrl[1], ctrl_neg[0]);
    and(out[11], ctrl_neg[4], ctrl[3], ctrl_neg[2], ctrl[1], ctrl[0]);
    and(out[12], ctrl_neg[4], ctrl[3], ctrl[2], ctrl_neg[1], ctrl_neg[0]);
    and(out[13], ctrl_neg[4], ctrl[3], ctrl[2], ctrl_neg[1], ctrl[0]);
    and(out[14], ctrl_neg[4], ctrl[3], ctrl[2], ctrl[1], ctrl_neg[0]);
    and(out[15], ctrl_neg[4], ctrl[3], ctrl[2], ctrl[1], ctrl[0]);
    and(out[16], ctrl[4], ctrl_neg[3], ctrl_neg[2], ctrl_neg[1], ctrl_neg[0]);
    and(out[17], ctrl[4], ctrl_neg[3], ctrl_neg[2], ctrl_neg[1], ctrl[0]);
    and(out[18], ctrl[4], ctrl_neg[3], ctrl_neg[2], ctrl[1], ctrl_neg[0]);
    and(out[19], ctrl[4], ctrl_neg[3], ctrl_neg[2], ctrl[1], ctrl[0]);
    and(out[20], ctrl[4], ctrl_neg[3], ctrl[2], ctrl_neg[1], ctrl_neg[0]);
    and(out[21], ctrl[4], ctrl_neg[3], ctrl[2], ctrl_neg[1], ctrl[0]);
    and(out[22], ctrl[4], ctrl_neg[3], ctrl[2], ctrl[1], ctrl_neg[0]);
    and(out[23], ctrl[4], ctrl_neg[3], ctrl[2], ctrl[1], ctrl[0]);
    and(out[24], ctrl[4], ctrl[3], ctrl_neg[2], ctrl_neg[1], ctrl_neg[0]);
    and(out[25], ctrl[4], ctrl[3], ctrl_neg[2], ctrl_neg[1], ctrl[0]);
    and(out[26], ctrl[4], ctrl[3], ctrl_neg[2], ctrl[1], ctrl_neg[0]);
    and(out[27], ctrl[4], ctrl[3], ctrl_neg[2], ctrl[1], ctrl[0]);
    and(out[28], ctrl[4], ctrl[3], ctrl[2], ctrl_neg[1], ctrl_neg[0]);
    and(out[29], ctrl[4], ctrl[3], ctrl[2], ctrl_neg[1], ctrl[0]);
    and(out[30], ctrl[4], ctrl[3], ctrl[2], ctrl[1], ctrl_neg[0]);
    and(out[31], ctrl[4], ctrl[3], ctrl[2], ctrl[1], ctrl[0]);    

endmodule

module decoder_8 (ctrl, out);

    input [2:0] ctrl;
    output [7:0] out;

    wire [2:0] ctrl_neg;
    assign ctrl_neg = ~ctrl;

    and(out[0], ctrl_neg[2], ctrl_neg[1], ctrl_neg[0]);
    and(out[1], ctrl_neg[2], ctrl_neg[1], ctrl[0]);
    and(out[2], ctrl_neg[2], ctrl[1], ctrl_neg[0]);
    and(out[3], ctrl_neg[2], ctrl[1], ctrl[0]);
    and(out[4], ctrl[2], ctrl_neg[1], ctrl_neg[0]);
    and(out[5], ctrl[2], ctrl_neg[1], ctrl[0]);
    and(out[6], ctrl[2], ctrl[1], ctrl_neg[0]);
    and(out[7], ctrl[2], ctrl[1], ctrl[0]);

endmodule