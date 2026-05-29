`timescale 1ns / 1ps

module immediate_generator_tb;

reg [31:0] instruction;

wire [31:0] immediate;

immediate_generator uut(

    .instruction(instruction),
    .immediate(immediate)

);

initial begin

    instruction = 32'h00500093;
    #10;

    instruction = 32'h00802023;
    #10;

    instruction = 32'h00208463;
    #10;

    $finish;

end

endmodule
