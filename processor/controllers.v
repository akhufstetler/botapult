module decoder_fd_ctrl(ir, regA, regB);

	input [31:0] ir;
	output [4:0] regA, regB;
    wire r_type, branch;
	
	assign r_type = ~ir[31] & ~ir[30] & ~ir[29] & ~ir[28] & ~ir[27];
	assign branch = ir[31] & ~ir[30] &  ir[29] &  ir[28] & ~ir[27];
	assign regA = ir[21:17];
	assign regB = r_type ? ir[16:12] : (branch ? 5'd30 : ir[26:22]);

endmodule

module decoder_dx_ctrl(ir, r_type, branch);

	input [31:0] ir;
    output r_type, branch;
	
	assign r_type = ~ir[31] & ~ir[30] & ~ir[29] & ~ir[28] & ~ir[27];
	assign branch = (~ir[31] & ~ir[30] &  ~ir[29] &  ir[28] & ~ir[27]) | (~ir[31] & ~ir[30] &  ir[29] &  ir[28] & ~ir[27]);

endmodule

module r_status_ctrl(op, alu_ctrl, r_status);

    input [4:0] op, alu_ctrl;
    output [31:0] r_status;

    wire r_type, add, addi, sub, mult, div;
    assign r_type = ~op[4] & ~op[3] & ~op[2] & ~op[1] & ~op[0];
    assign add = r_type & ~alu_ctrl[4] & ~alu_ctrl[3] & ~alu_ctrl[2] & ~alu_ctrl[1] & ~alu_ctrl[0];
    assign addi = ~op[4] & ~op[3] & op[2] & ~op[1] & op[0];
    assign sub = r_type & ~alu_ctrl[4] & ~alu_ctrl[3] & ~alu_ctrl[2] & ~alu_ctrl[1] & alu_ctrl[0];
    assign mult = r_type & ~alu_ctrl[4] & ~alu_ctrl[3] & alu_ctrl[2] & alu_ctrl[1] & ~alu_ctrl[0];
    assign div = r_type & ~alu_ctrl[4] & ~alu_ctrl[3] & alu_ctrl[2] & alu_ctrl[1] & alu_ctrl[0];

    tristate_32 ADD_TRI(32'd1, add, r_status);
    tristate_32 ADDI_TRI(32'd2, addi, r_status);
    tristate_32 SUB_TRI(32'd3, sub, r_status);
    tristate_32 MULT_TRI(32'd4, mult, r_status);
    tristate_32 DIV_TRI(32'd5, div, r_status);

endmodule

module mw_ctrl(ir, ovf, md_ir, md_rdy, md_err, writeReg, writeEn, lw);

	input [31:0] ir, md_ir;
    input ovf, md_rdy, md_err;

    output [4:0] writeReg;
    output writeEn, lw;
	
    wire r_type, addi, jal, setx, normal, status, jal_ct, muldiv;

	assign r_type = ~ir[31] & ~ir[30] & ~ir[29] & ~ir[28] & ~ir[27];
	assign addi = ~ir[31] & ~ir[30] & ir[29] & ~ir[28] & ir[27];
    assign lw = ~ir[31] & ir[30] & ~ir[29] & ~ir[28] & ~ir[27];
    assign jal = ~ir[31] & ~ir[30] & ~ir[29] & ir[28] & ir[27];
    assign setx = ir[31] & ~ir[30] & ir[29] & ~ir[28] & ir[27];

    assign normal = !(ovf | setx) & !jal & !(md_rdy && !md_err);
    assign status = (ovf | setx) & !jal & !(md_rdy && !md_err);
    assign jal_ct = !(ovf | setx) & jal & !(md_rdy && !md_err);
    assign muldiv = !(ovf | setx) & !jal & (md_rdy && !md_err);

    tristate_5 NORMAL_TRI(ir[26:22], normal, writeReg);
    tristate_5 STATUS_TRI(5'd30, status, writeReg);
    tristate_5 JAL_CT_TRI(5'd31, jal_ct, writeReg);
    tristate_5 MULDIV_TRI(md_ir[26:22], muldiv, writeReg);

    assign writeEn = r_type | addi | lw | jal | setx | (md_rdy & !md_err);

endmodule

module xm_o_ctrl(xm_o_in, dx_ir, alu_res, r_status, dx_pc, ovrflw);

    input [31:0] dx_ir, alu_res, r_status, dx_pc;
    input ovrflw;

    output [31:0] xm_o_in;

    wire [31:0] dx_setx_t;
    wire dx_jal, dx_setx, xm_o_alu, xm_o_rs, xm_o_pc, xm_o_sx;

    assign dx_jal = ~dx_ir[31] & ~dx_ir[30] & ~dx_ir[29] & dx_ir[28] & dx_ir[27];
    assign dx_setx = dx_ir[31] & ~dx_ir[30] & dx_ir[29] & ~dx_ir[28] & dx_ir[27];
    assign xm_o_alu = !ovrflw & !dx_jal & !dx_setx;
    assign xm_o_rs = ovrflw & !dx_jal & !dx_setx;
    assign xm_o_pc = !ovrflw & dx_jal & !dx_setx;
    assign xm_o_sx = !ovrflw & !dx_jal & dx_setx;

    assign dx_setx_t = { 5'b0, dx_ir[26:0] };
    tristate_32 ALU_TRI(alu_res, xm_o_alu, xm_o_in);
    tristate_32 RS_TRI(r_status, xm_o_rs, xm_o_in);
    tristate_32 PC_TRI(dx_pc, xm_o_pc, xm_o_in);
    tristate_32 SX_TRI(dx_setx_t, xm_o_sx, xm_o_in);

endmodule

module stall_ctrl(fd_ir, dx_ir, xm_ir, md_status, md_rdy, hazard);

    input [31:0] fd_ir, dx_ir, xm_ir;
    input md_status, md_rdy;
    output hazard;

    wire fd_sw, dx_lw, dx_r_type, dx_mult, dx_div;

    assign fd_sw = ~fd_ir[31] & ~fd_ir[30] & fd_ir[29] & fd_ir[28] & fd_ir[27];
    assign dx_lw = ~dx_ir[31] & dx_ir[30] & ~dx_ir[29] & ~dx_ir[28] & ~dx_ir[27];
    assign dx_r_type = ~dx_ir[31] & ~dx_ir[30] & ~dx_ir[29] & ~dx_ir[28] & ~dx_ir[27];
    assign dx_mult = dx_r_type & ~dx_ir[6] & ~dx_ir[5] & dx_ir[4] & dx_ir[3] & ~dx_ir[2];
    assign dx_div = dx_r_type & ~dx_ir[6] & ~dx_ir[5] & dx_ir[4] & dx_ir[3] & dx_ir[2];

    assign hazard = (dx_lw & ((fd_ir[21:17] == dx_ir[26:22]) | ((fd_ir[16:12] == dx_ir[26:22]) & !fd_sw))) | md_status | dx_mult | dx_div;

endmodule

module bypass_ctrl(dx_ir, xm_ir, mw_ir, xm_ovf, mw_ovf, select_a, select_b, select_wm);
    
    input [31:0] dx_ir, xm_ir, mw_ir;
    input xm_ovf, mw_ovf;
    
    output [1:0] select_a, select_b;
    output select_wm;

    wire xm_sw, mw_sw, xm_branch, mw_branch, xm_setx, mw_setx, dx_r, dx_bex;

    assign xm_sw = ~xm_ir[31] & ~xm_ir[30] & xm_ir[29] & xm_ir[28] & xm_ir[27];
    assign mw_sw = ~mw_ir[31] & ~mw_ir[30] & mw_ir[29] & mw_ir[28] & mw_ir[27];
    assign xm_branch = (~xm_ir[31] & ~xm_ir[30] &  ~xm_ir[29] &  xm_ir[28] & ~xm_ir[27]) | (~xm_ir[31] & ~xm_ir[30] & xm_ir[29] & xm_ir[28] & ~xm_ir[27]);
    assign mw_branch = (~mw_ir[31] & ~mw_ir[30] &  ~mw_ir[29] &  mw_ir[28] & ~mw_ir[27]) | (~mw_ir[31] & ~mw_ir[30] & mw_ir[29] & mw_ir[28] & ~mw_ir[27]);
    assign xm_setx = xm_ir[31] & ~xm_ir[30] & xm_ir[29] & ~xm_ir[28] & xm_ir[27];
    assign mw_setx = mw_ir[31] & ~mw_ir[30] & mw_ir[29] & ~mw_ir[28] & mw_ir[27];
    assign dx_r = ~dx_ir[31] & ~dx_ir[30] & ~dx_ir[29] & ~dx_ir[28] & ~dx_ir[27];
    assign dx_bex = dx_ir[31] & ~dx_ir[30] & dx_ir[29] & dx_ir[28] & ~dx_ir[27];

    wire [4:0] dx_a, dx_b, xm_rd, mw_rd;

    assign dx_a = dx_ir[21:17];
    assign dx_b = dx_r ? dx_ir[16:12] : (dx_bex ? 5'd30 : dx_ir[26:22]);
    assign xm_rd = (xm_ovf | xm_setx) ? 5'd30 : xm_ir[26:22];
    assign mw_rd = (mw_ovf | mw_setx) ? 5'd30 : mw_ir[26:22];

    wire xm_a_bypass, mw_a_bypass, xm_b_bypass, mw_b_bypass;
    assign xm_a_bypass = !xm_sw & !xm_branch & (dx_a == xm_rd) & (xm_rd != 5'b0);
    assign mw_a_bypass = !mw_sw & !mw_branch & (dx_a == mw_rd) & (mw_rd != 5'b0); 
    assign xm_b_bypass = !xm_sw & !xm_branch & (dx_b == xm_rd) & (xm_rd != 5'b0); 
    assign mw_b_bypass = !mw_sw & !mw_branch & (dx_b == mw_rd) & (mw_rd != 5'b0);

    assign select_a[1] = !xm_a_bypass & !mw_a_bypass;
    assign select_a[0] = !xm_a_bypass & mw_a_bypass;
    assign select_b[1] = !xm_b_bypass & !mw_b_bypass;
    assign select_b[0] = !xm_b_bypass & mw_b_bypass;

    assign select_wm = xm_sw && (xm_ir[26:22] == mw_ir[26:22]);

endmodule

module processor_ctrl(pc_nxt, dx_pc, sx_imm, dx_ir, alu_b, alu_neq, alu_lt, pc_in, bj_taken);

    input [31:0] pc_nxt, dx_pc, sx_imm, dx_ir, alu_b;
    input alu_neq, alu_lt;

    output [31:0] pc_in;
    output bj_taken;

    wire [31:0] pc_branch, dx_setx_t, pc_mux;
    wire [2:0] pc_sel, pc_uu;
    wire dx_bex, alu_lt_ctrl;

    cla_32bit PC_ADDER(dx_pc, sx_imm, 1'b0, pc_branch, pc_uu[0], pc_uu[1], pc_uu[2]);
    assign dx_setx_t = { 5'b0, dx_ir[26:0] };
    assign dx_bex = dx_ir[31] & ~dx_ir[30] & dx_ir[29] & dx_ir[28] & ~dx_ir[27];
    assign pc_sel = dx_bex ? 3'b0 : dx_ir[29:27];
    assign alu_lt_ctrl = alu_neq ? ~alu_lt : 1'b0;

    mux_8 PC_MUX(pc_mux, pc_sel, pc_nxt, 
                                 dx_setx_t, 
                                 alu_neq ? pc_branch : pc_nxt, 
                                 dx_setx_t, alu_b,
                                 pc_nxt,
                                 alu_lt_ctrl ? pc_branch : pc_nxt,
                                 pc_nxt);
    
    assign pc_in = (dx_bex & (alu_b != 0)) ? dx_setx_t : pc_mux;
    assign bj_taken = pc_in != pc_nxt;

endmodule