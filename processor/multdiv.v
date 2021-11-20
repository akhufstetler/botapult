module multdiv(
	data_operandA, data_operandB, 
	ctrl_MULT, ctrl_DIV, 
	clock, 
	data_result, data_exception, data_resultRDY);

    input [31:0] data_operandA, data_operandB;
    input ctrl_MULT, ctrl_DIV, clock;

    output [31:0] data_result;
    output data_exception, data_resultRDY;

    wire [31:0] mult_result, div_result;
    wire mult_exception, div_exception, mult_ready, div_ready;
    wire mult_mode, div_mode;

    mult32 multiplier(ctrl_MULT, mult_mode, data_operandA, data_operandB, clock, mult_result, mult_exception, mult_ready);
    div32 divider(ctrl_DIV, div_mode, data_operandA, data_operandB, clock, div_result, div_exception, div_ready);

    dffe_ref MULT_MODE(mult_mode, ctrl_MULT, clock, ctrl_MULT | ctrl_DIV, 1'b0);
    dffe_ref DIV_MODE(div_mode, ctrl_DIV, clock, ctrl_MULT | ctrl_DIV, 1'b0);

    assign data_result = mult_mode ? mult_result : (div_mode ? div_result : 32'b0);
    assign data_exception = mult_mode ? mult_exception : (div_mode ? div_exception : 1'b0);
    assign data_resultRDY = mult_mode ? mult_ready : (div_mode ? div_ready : 1'b0);

endmodule