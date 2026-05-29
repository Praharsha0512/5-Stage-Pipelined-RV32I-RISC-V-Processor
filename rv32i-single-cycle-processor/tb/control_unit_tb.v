`timescale 1ns / 1ps

module control_unit_tb;

reg [6:0] opcode;

wire reg_write;
wire alu_src;
wire mem_read;
wire mem_write;
wire mem_to_reg;
wire branch;

wire [1:0] alu_op;

control_unit uut(

    .opcode(opcode),

    .reg_write(reg_write),
    .alu_src(alu_src),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .mem_to_reg(mem_to_reg),
    .branch(branch),

    .alu_op(alu_op)

);

initial begin

    opcode = 7'b0110011;
    #10;

    opcode = 7'b0000011;
    #10;

    opcode = 7'b0100011;
    #10;

    opcode = 7'b1100011;
    #10;

    $finish;

end

endmodule