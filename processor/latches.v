module sr_latch (S, R, Q);

	input S, R; 
	output Q;
	wire not_q;

	nor(not_q, S, Q);
	nor(Q, R, not_q);

endmodule

module fd_latch(pc_in, pc_out, ir_in, ir_out, clk, en, clr);

	input [31:0] pc_in, ir_in;
	input clk, en, clr;

	output [31:0] pc_out, ir_out;

	reg_32 PC_REG(pc_out, pc_in, clk, en, clr);
	reg_32 IR_REG(ir_out, ir_in, clk, en, clr);

endmodule

module dx_latch(pc_in, pc_out, a_in, a_out, b_in, b_out, ir_in, ir_out, clk, en, clr);

	input [31:0] pc_in, a_in, b_in, ir_in;
	input clk, en, clr;

	output [31:0] pc_out, a_out, b_out, ir_out;

	reg_32 PC_REG(pc_out, pc_in, clk, en, clr);
	reg_32 A_REG(a_out, a_in, clk, en, clr);
	reg_32 B_REG(b_out, b_in, clk, en, clr);
	reg_32 IR_REG(ir_out, ir_in, clk, en, clr);

endmodule

module xm_latch(o_in, o_out, b_in, b_out, ir_in, ir_out, ovf_in, ovf_out, clk, en, clr);

	input [31:0] o_in, b_in, ir_in;
	input ovf_in, clk, en, clr;

	output [31:0] o_out, b_out, ir_out;
	output ovf_out;

	reg_32 O_REG(o_out, o_in, clk, en, clr);
	reg_32 B_REG(b_out, b_in, clk, en, clr);
	reg_32 IR_REG(ir_out, ir_in, clk, en, clr);

	dffe_ref OVF_DFFE(ovf_out, ovf_in, clk, en, clr);

endmodule

module mw_latch(o_in, o_out, d_in, d_out, ir_in, ir_out, ovf_in, ovf_out, clk, en, clr);

	input [31:0] o_in, d_in, ir_in;
	input ovf_in, clk, en, clr;

	output [31:0] o_out, d_out, ir_out;
	output ovf_out;

	reg_32 O_REG(o_out, o_in, clk, en, clr);
	reg_32 D_REG(d_out, d_in, clk, en, clr);
	reg_32 IR_REG(ir_out, ir_in, clk, en, clr);

	dffe_ref OVF_DFFE(ovf_out, ovf_in, clk, en, clr);

endmodule

module md_latch(a_in, a_out, b_in, b_out, ir_in, ir_out, clk, en, clr, rdy, status);

	input [31:0] a_in, b_in, ir_in;
	input clk, en, clr, rdy;

	output [31:0] a_out, b_out, ir_out;
	output status;

	reg_32 A_REG(a_out, a_in, clk, en, clr);
	reg_32 B_REG(b_out, b_in, clk, en, clr);
	reg_32 IR_REG(ir_out, ir_in, clk, en, clr);

	dffe_ref STATUS_DFFE(status, 1'b1, clk, en, rdy);

endmodule