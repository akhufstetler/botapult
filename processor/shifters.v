module barrel_sll (data, shift, result);
    
    input [31:0] data;
    input [4:0] shift;
    output [31:0] result;
    wire [31:0] shift16, shift8, shift4, shift2, shift1;
    wire [31:0] mux16, mux8, mux4, mux2, mux1;

    assign shift16[15:0] = 16'b0;
    assign shift16[31:16] = data[15:0];

    assign mux16 = shift[4] ? shift16 : data;

    assign shift8[7:0] = 8'b0;
    assign shift8[31:8] = mux16[23:0];

    assign mux8 = shift[3] ? shift8 : mux16;

    assign shift4[3:0] = 4'b0;
    assign shift4[31:4] = mux8[27:0];

    assign mux4 = shift[2] ? shift4 : mux8;

    assign shift2[1:0] = 2'b0;
    assign shift2[31:2] = mux4[29:0];

    assign mux2 = shift[1] ? shift2 : mux4;

    assign shift1[0] = 1'b0;
    assign shift1[31:1] = mux2[30:0];

    assign result = shift[0] ? shift1 : mux2;

endmodule

module barrel_sra (data, shift, result);
    
    input [31:0] data;
    input [4:0] shift;
    output [31:0] result;
    wire [31:0] shift16, shift8, shift4, shift2, shift1;
    wire [31:0] mux16, mux8, mux4, mux2, mux1;

    assign shift16[31:16] = data[31] ? 16'b1111111111111111 : 16'b0;
    assign shift16[15:0] = data[31:16];

    assign mux16 = shift[4] ? shift16 : data;

    assign shift8[31:24] = data[31] ? 8'b11111111 : 8'b0;
    assign shift8[23:0] = mux16[31:8];

    assign mux8 = shift[3] ? shift8 : mux16;

    assign shift4[31:28] = data[31] ? 4'b1111 : 4'b0;
    assign shift4[27:0] = mux8[31:4];

    assign mux4 = shift[2] ? shift4 : mux8;

    assign shift2[31:30] = data[31] ? 2'b11 : 2'b0;
    assign shift2[29:0] = mux4[31:2];

    assign mux2 = shift[1] ? shift2 : mux4;

    assign shift1[31] = data[31] ? 1'b1 : 1'b0;
    assign shift1[30:0] = mux2[31:1];

    assign result = shift[0] ? shift1 : mux2;

endmodule