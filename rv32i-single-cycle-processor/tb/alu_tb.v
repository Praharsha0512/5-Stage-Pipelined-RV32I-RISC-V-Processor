`timescale 1ns / 1ps

module alu_tb;

reg [31:0] a;
reg [31:0] b;

reg [2:0] alu_control;

wire [31:0] result;
wire zero;

alu uut(

    .a(a),
    .b(b),
    .alu_control(alu_control),

    .result(result),
    .zero(zero)

);

initial begin

    a = 10;
    b = 5;

    alu_control = 3'b000;
    #10;

    alu_control = 3'b001;
    #10;

    alu_control = 3'b010;
    #10;

    alu_control = 3'b011;
    #10;

    alu_control = 3'b100;
    #10;

    a = 5;
    b = 5;

    alu_control = 3'b001;
    #10;

    $finish;

end

endmodule
