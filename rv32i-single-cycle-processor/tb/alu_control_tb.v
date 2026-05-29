`timescale 1ns / 1ps

module alu_control_tb;

reg [1:0] alu_op;
reg [2:0] funct3;
reg [6:0] funct7;

wire [2:0] alu_control;

alu_control uut(

    .alu_op(alu_op),
    .funct3(funct3),
    .funct7(funct7),

    .alu_control(alu_control)

);

initial begin

    alu_op = 2'b00;
    funct3 = 3'b000;
    funct7 = 7'b0000000;
    #10;

    alu_op = 2'b01;
    #10;

    alu_op = 2'b10;
    funct3 = 3'b000;
    funct7 = 7'b0000000;
    #10;

    funct7 = 7'b0100000;
    #10;

    funct3 = 3'b111;
    #10;

    funct3 = 3'b110;
    #10;

    funct3 = 3'b010;
    #10;

    $finish;

end

endmodule