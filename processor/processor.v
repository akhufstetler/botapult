/**
 * READ THIS DESCRIPTION!
 *
 * This is your processor module that will contain the bulk of your code submission. You are to implement
 * a 5-stage pipelined processor in this module, accounting for hazards and implementing bypasses as
 * necessary.
 *
 * Ultimately, your processor will be tested by a master skeleton, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file, Wrapper.v, acts as a small wrapper around your processor for this purpose. Refer to Wrapper.v
 * for more details.
 *
 * As a result, this module will NOT contain the RegFile nor the memory modules. Study the inputs 
 * very carefully - the RegFile-related I/Os are merely signals to be sent to the RegFile instantiated
 * in your Wrapper module. This is the same for your memory elements. 
 *
 *
 */
module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for RegFile
    ctrl_writeReg,                  // O: Register to write to in RegFile
    ctrl_readRegA,                  // O: Register to read from port A of RegFile
    ctrl_readRegB,                  // O: Register to read from port B of RegFile
    data_writeReg,                  // O: Data to write to for RegFile
    data_readRegA,                  // I: Data from port A of RegFile
    data_readRegB                   // I: Data from port B of RegFile
	 
	);

	// Control signals
	input clock, reset;
	
	// Imem
    output [31:0] address_imem;
	input [31:0] q_imem;

	// Dmem
	output [31:0] address_dmem, data;
	output wren;
	input [31:0] q_dmem;

	// Regfile
	output ctrl_writeEnable;
	output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	output [31:0] data_writeReg;
	input [31:0] data_readRegA, data_readRegB;

// PC Latch ------------------------------------------------------------------------------------------------    
    wire [31:0] pc_in, pc_out;
    wire data_haz, inv_clock;

    assign inv_clock = ~clock;
    reg_32_inv PC_LATCH(pc_out, pc_in, inv_clock, ~data_haz, reset);

// Fetch Stage ---------------------------------------------------------------------------------------------
    wire [31:0] pc_nxt, pc_alt;
    wire [2:0] pc_uu;
    wire bj_taken;

    assign address_imem = pc_out;
    cla_32bit pc_adder(pc_out, 32'b1, 1'b0, pc_nxt, pc_uu[0], pc_uu[1], pc_uu[2]);
    assign pc_in = bj_taken ? pc_alt : pc_nxt;	

// FD Latch ------------------------------------------------------------------------------------------------
    wire [31:0] fd_pc_out, fd_ir_in, fd_ir_out;

    assign fd_ir_in = bj_taken ? 32'b0 : q_imem;
    fd_latch FD_LATCH(pc_out, fd_pc_out, fd_ir_in, fd_ir_out, inv_clock, ~data_haz, reset);

// Decode Stage --------------------------------------------------------------------------------------------
    decoder_fd_ctrl FD_DECODER(fd_ir_out, ctrl_readRegA, ctrl_readRegB);

// DX Latch ------------------------------------------------------------------------------------------------
    wire [31:0] dx_ir_in, dx_ir_out, dx_a_out, dx_b_out, dx_pc_out;

    assign dx_ir_in = (bj_taken | data_haz) ? 32'b0 : fd_ir_out;
    dx_latch DX_LATCH(fd_pc_out, dx_pc_out, data_readRegA, dx_a_out, data_readRegB, dx_b_out, dx_ir_in, dx_ir_out, inv_clock, 1'b1, reset);

// Execute Stage -------------------------------------------------------------------------------------------
    // ALU Section
    wire [31:0] alu_in_a, alu_in_b, alu_mx_b, alu_res, sx_imm, xm_o_out; 
    wire [4:0] alu_ctrl, alu_shamt;
    wire [1:0] mux_a_select, mux_b_select;
    wire alu_ne, alu_lt, alu_of, dx_r_type, dx_branch;

    decoder_dx_ctrl DX_DECODER(dx_ir_out, dx_r_type, dx_branch);

    mux_4 ALU_A_MUX(alu_in_a, mux_a_select, xm_o_out, data_writeReg, dx_a_out, 32'b0);
    mux_4 ALU_B_MUX(alu_mx_b, mux_b_select, xm_o_out, data_writeReg, dx_b_out, 32'b0);

    assign sx_imm = { (dx_ir_out[16] ? 15'b111111111111111 : 15'b0) , dx_ir_out[16:0] };
    assign alu_in_b = (dx_r_type | dx_branch) ? alu_mx_b : sx_imm;
    assign alu_ctrl = dx_r_type ? dx_ir_out[6:2] : (dx_branch ? 5'b1 : 5'b0);
    assign alu_shamt = dx_ir_out[11:7];

    alu ALU(alu_in_a, alu_in_b, alu_ctrl, alu_shamt, alu_res, alu_ne, alu_lt, alu_of);

    // MultDiv Section
    wire [31:0] md_a_out, md_b_out, md_ir_out, md_res;
    wire ctrl_mult, ctrl_div, md_rdy, md_status, md_err;

    assign ctrl_mult = dx_r_type & ~alu_ctrl[4] & ~alu_ctrl[3] & alu_ctrl[2] & alu_ctrl[1] & ~alu_ctrl[0];
    assign ctrl_div = dx_r_type & ~alu_ctrl[4] & ~alu_ctrl[3] & alu_ctrl[2] & alu_ctrl[1] & alu_ctrl[0];

    md_latch MULTDIV_LATCH(alu_in_a, md_a_out, alu_in_b, md_b_out, dx_ir_out, md_ir_out, inv_clock, ctrl_mult | ctrl_div, reset, md_rdy, md_status);
    multdiv MULTDIV(md_a_out, md_b_out, ctrl_mult, ctrl_div, inv_clock, md_res, md_err, md_rdy);

    // Overflow Section
    wire ovrflw;
    assign ovrflw = alu_of | (md_err & md_rdy);

    wire [31:0] r_status;
    wire [4:0] ovrflw_ir_op, ovrflw_alu_ctrl;
    assign ovrflw_ir_op = md_rdy ? md_ir_out[31:27] : dx_ir_out[31:27];
    assign ovrflw_alu_ctrl = md_rdy ? md_ir_out[6:2] : alu_ctrl;
    r_status_ctrl R_CTRL(ovrflw_ir_op, ovrflw_alu_ctrl, r_status);

// XM Latch ------------------------------------------------------------------------------------------------
    wire [31:0] xm_o_in, xm_b_out, xm_ir_out;
    wire xm_ovf_out;
    
    xm_o_ctrl XM_CTRL(xm_o_in, dx_ir_out, alu_res, r_status, dx_pc_out, ovrflw);

    xm_latch XM_LATCH(xm_o_in, xm_o_out, alu_mx_b, xm_b_out, dx_ir_out, xm_ir_out, ovrflw, xm_ovf_out, inv_clock, 1'b1, reset);

// Memory Stage --------------------------------------------------------------------------------------------
    wire mw_bypass;

    assign wren = ~xm_ir_out[31] & ~xm_ir_out[30] & xm_ir_out[29] & xm_ir_out[28] & xm_ir_out[27];
    assign address_dmem = xm_o_out;
    assign data = mw_bypass ? data_writeReg : xm_b_out;

// MW Latch
    wire [31:0] mw_o_out, mw_d_out, mw_ir_out;
    wire mw_ovf_out;

    mw_latch MW_LATCH(xm_o_out, mw_o_out, q_dmem, mw_d_out, xm_ir_out, mw_ir_out, xm_ovf_out, mw_ovf_out, inv_clock, 1'b1, reset);

// Write Stage ---------------------------------------------------------------------------------------------
    wire mw_lw;

    mw_ctrl MW_CTRL(mw_ir_out, mw_ovf_out, md_ir_out, md_rdy, md_err, ctrl_writeReg, ctrl_writeEnable, mw_lw);
    assign data_writeReg = mw_lw ? mw_d_out : ((md_rdy & !md_err) ? md_res : mw_o_out);

// Processor High Level Controllers ------------------------------------------------------------------------
    stall_ctrl STALL(fd_ir_out, dx_ir_out, xm_ir_out, md_status, md_rdy, data_haz);

    bypass_ctrl BYPASS(dx_ir_out, xm_ir_out, mw_ir_out, xm_ovf_out, mw_ovf_out, mux_a_select, mux_b_select, mw_bypass);
    
    processor_ctrl CTRL(pc_nxt, dx_pc_out, sx_imm, dx_ir_out, alu_mx_b, alu_ne, alu_lt, pc_alt, bj_taken);

endmodule
