module tristate(in, oe, out);

    input in, oe;
    output out;
    assign out = oe ? in : 1'bz;
    
endmodule

module tristate_32(in, oe, out);

    input [31:0] in;
    input oe;
    output [31:0] out;
    assign out = oe ? in : 32'bz;
    
endmodule

module tristate_5(in, oe, out);

    input [4:0] in;
    input oe;
    output [4:0] out;
    assign out = oe ? in : 5'bz;
    
endmodule

module tristate_2(in, oe, out);

    input [1:0] in;
    input oe;
    output [1:0] out;
    assign out = oe ? in : 2'bz;
    
endmodule