module counter32(count, clk, en, res);

	input clk, res, en;
	output [4:0] count;
	wire [4:0] reg_in;
	
	reg_5 register(count, reg_in, clk, en, res);
	
	cla_5bit adder(count, 5'b00001, 1'b0, reg_in);

endmodule

module counter64(count, clk, en, res);

	input clk, res, en;
	output [5:0] count;
	wire [5:0] reg_in;
	
	reg_6 register(count, reg_in, clk, en, res);
	
	cla_6bit adder(count, 6'b000001, 1'b0, reg_in);

endmodule