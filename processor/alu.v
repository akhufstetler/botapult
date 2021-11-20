module alu(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan, overflow);
        
    input [31:0] data_operandA, data_operandB;
    input [4:0] ctrl_ALUopcode, ctrl_shiftamt;

    output [31:0] data_result;
    output isNotEqual, isLessThan, overflow;

    // add your code here:
    wire [31:0] add_res, sub_res, and_res, or_res, sll_res, sra_res;
    wire add_cout, sub_cout, add_of, sub_of;

    //ADDER SECTION ----------------------------------------------------------------------------------------------------------------
    wire [1:0] add_tmp;

    cla_32bit adder(data_operandA, data_operandB, 1'b0, add_res, add_tmp[0], add_tmp[1], add_of);

    //SUBTRACTOR SECTION -----------------------------------------------------------------------------------------------------------
    wire [31:0] negate_B;
    not(negate_B[0], data_operandB[0]);
    not(negate_B[1], data_operandB[1]);
    not(negate_B[2], data_operandB[2]);
    not(negate_B[3], data_operandB[3]);
    not(negate_B[4], data_operandB[4]);
    not(negate_B[5], data_operandB[5]);
    not(negate_B[6], data_operandB[6]);
    not(negate_B[7], data_operandB[7]);
    not(negate_B[8], data_operandB[8]);
    not(negate_B[9], data_operandB[9]);
    not(negate_B[10], data_operandB[10]);
    not(negate_B[11], data_operandB[11]);
    not(negate_B[12], data_operandB[12]);
    not(negate_B[13], data_operandB[13]);
    not(negate_B[14], data_operandB[14]);
    not(negate_B[15], data_operandB[15]);
    not(negate_B[16], data_operandB[16]);
    not(negate_B[17], data_operandB[17]);
    not(negate_B[18], data_operandB[18]);
    not(negate_B[19], data_operandB[19]);
    not(negate_B[20], data_operandB[20]);
    not(negate_B[21], data_operandB[21]);
    not(negate_B[22], data_operandB[22]);
    not(negate_B[23], data_operandB[23]);
    not(negate_B[24], data_operandB[24]);
    not(negate_B[25], data_operandB[25]);
    not(negate_B[26], data_operandB[26]);
    not(negate_B[27], data_operandB[27]);
    not(negate_B[28], data_operandB[28]);
    not(negate_B[29], data_operandB[29]);
    not(negate_B[30], data_operandB[30]);
    not(negate_B[31], data_operandB[31]);

    cla_32bit subtractor(data_operandA, negate_B, 1'b1, sub_res, isNotEqual, isLessThan, sub_of);

    //AND Section -------------------------------------------------------------------------------------------------------------------------------
    and(and_res[0], data_operandA[0], data_operandB[0]);
    and(and_res[1], data_operandA[1], data_operandB[1]);
    and(and_res[2], data_operandA[2], data_operandB[2]);
    and(and_res[3], data_operandA[3], data_operandB[3]);
    and(and_res[4], data_operandA[4], data_operandB[4]);
    and(and_res[5], data_operandA[5], data_operandB[5]);
    and(and_res[6], data_operandA[6], data_operandB[6]);
    and(and_res[7], data_operandA[7], data_operandB[7]);
    and(and_res[8], data_operandA[8], data_operandB[8]);
    and(and_res[9], data_operandA[9], data_operandB[9]);
    and(and_res[10], data_operandA[10], data_operandB[10]);
    and(and_res[11], data_operandA[11], data_operandB[11]);
    and(and_res[12], data_operandA[12], data_operandB[12]);
    and(and_res[13], data_operandA[13], data_operandB[13]);
    and(and_res[14], data_operandA[14], data_operandB[14]);
    and(and_res[15], data_operandA[15], data_operandB[15]);
    and(and_res[16], data_operandA[16], data_operandB[16]);
    and(and_res[17], data_operandA[17], data_operandB[17]);
    and(and_res[18], data_operandA[18], data_operandB[18]);
    and(and_res[19], data_operandA[19], data_operandB[19]);
    and(and_res[20], data_operandA[20], data_operandB[20]);
    and(and_res[21], data_operandA[21], data_operandB[21]);
    and(and_res[22], data_operandA[22], data_operandB[22]);
    and(and_res[23], data_operandA[23], data_operandB[23]);
    and(and_res[24], data_operandA[24], data_operandB[24]);
    and(and_res[25], data_operandA[25], data_operandB[25]);
    and(and_res[26], data_operandA[26], data_operandB[26]);
    and(and_res[27], data_operandA[27], data_operandB[27]);
    and(and_res[28], data_operandA[28], data_operandB[28]);
    and(and_res[29], data_operandA[29], data_operandB[29]);
    and(and_res[30], data_operandA[30], data_operandB[30]);
    and(and_res[31], data_operandA[31], data_operandB[31]);

    //OR Section --------------------------------------------------------------------------------------------------------------------------------
    or(or_res[0], data_operandA[0], data_operandB[0]);
    or(or_res[1], data_operandA[1], data_operandB[1]);
    or(or_res[2], data_operandA[2], data_operandB[2]);
    or(or_res[3], data_operandA[3], data_operandB[3]);
    or(or_res[4], data_operandA[4], data_operandB[4]);
    or(or_res[5], data_operandA[5], data_operandB[5]);
    or(or_res[6], data_operandA[6], data_operandB[6]);
    or(or_res[7], data_operandA[7], data_operandB[7]);
    or(or_res[8], data_operandA[8], data_operandB[8]);
    or(or_res[9], data_operandA[9], data_operandB[9]);
    or(or_res[10], data_operandA[10], data_operandB[10]);
    or(or_res[11], data_operandA[11], data_operandB[11]);
    or(or_res[12], data_operandA[12], data_operandB[12]);
    or(or_res[13], data_operandA[13], data_operandB[13]);
    or(or_res[14], data_operandA[14], data_operandB[14]);
    or(or_res[15], data_operandA[15], data_operandB[15]);
    or(or_res[16], data_operandA[16], data_operandB[16]);
    or(or_res[17], data_operandA[17], data_operandB[17]);
    or(or_res[18], data_operandA[18], data_operandB[18]);
    or(or_res[19], data_operandA[19], data_operandB[19]);
    or(or_res[20], data_operandA[20], data_operandB[20]);
    or(or_res[21], data_operandA[21], data_operandB[21]);
    or(or_res[22], data_operandA[22], data_operandB[22]);
    or(or_res[23], data_operandA[23], data_operandB[23]);
    or(or_res[24], data_operandA[24], data_operandB[24]);
    or(or_res[25], data_operandA[25], data_operandB[25]);
    or(or_res[26], data_operandA[26], data_operandB[26]);
    or(or_res[27], data_operandA[27], data_operandB[27]);
    or(or_res[28], data_operandA[28], data_operandB[28]);
    or(or_res[29], data_operandA[29], data_operandB[29]);
    or(or_res[30], data_operandA[30], data_operandB[30]);
    or(or_res[31], data_operandA[31], data_operandB[31]);

    //SLL Section -------------------------------------------------------------------------------------------------------------------------------
    barrel_sll BARRELSHIFT1(data_operandA, ctrl_shiftamt, sll_res);

    //SRA Section -------------------------------------------------------------------------------------------------------------------------------
    barrel_sra BARRELSHIFT2(data_operandA, ctrl_shiftamt, sra_res);

    mux_8 opcodeMUX(data_result, ctrl_ALUopcode[2:0], add_res, sub_res, and_res, or_res, sll_res, sra_res, 0, 0);

    assign overflow = ctrl_ALUopcode[0] ? sub_of : add_of;

endmodule