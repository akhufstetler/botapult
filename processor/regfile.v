module regfile (
	clock,
	ctrl_writeEnable, ctrl_reset, ctrl_writeReg,
	ctrl_readRegA, ctrl_readRegB, data_writeReg,
	data_readRegA, data_readRegB
);

	input clock, ctrl_writeEnable, ctrl_reset;
	input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	input [31:0] data_writeReg;

	output [31:0] data_readRegA, data_readRegB;

	wire [31:0] writeRegCtrl, readRegA, readRegB, writeRegEn;

	decoder_32 WRITEREG_DEC(ctrl_writeReg, writeRegCtrl);
	decoder_32 READREGA_DEC(ctrl_readRegA, readRegA);
	decoder_32 READREGB_DEC(ctrl_readRegB, readRegB);

	genvar i;

	for (i = 1; i < 32; i = i + 1) begin
		and(writeRegEn[i], writeRegCtrl[i], ctrl_writeEnable);

		wire [31:0] data_out;

		reg_32 REG(data_out, data_writeReg, clock, writeRegEn[i], ctrl_reset);

		genvar j;

		for (j = 0; j < 32; j = j + 1) begin
			tristate bufferA(data_out[j], readRegA[i], data_readRegA[j]);
			tristate bufferB(data_out[j], readRegB[i], data_readRegB[j]);
		end
	end

	wire [31:0] output_0;

	reg_32 REG0(output_0, 32'b0, 1'b0, 1'b0, 1'b0);

	genvar k;

	for (k = 0; k < 32; k = k + 1)  begin
		tristate bufferA(output_0[k], readRegA[0], data_readRegA[k]);
		tristate bufferB(output_0[k], readRegB[0], data_readRegB[k]);
	end

endmodule