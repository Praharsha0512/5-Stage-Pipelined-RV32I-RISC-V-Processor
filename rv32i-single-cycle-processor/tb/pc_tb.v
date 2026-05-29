`timescale 1ns / 1ps

module pc_tb;

reg clk;
reg reset;
reg [31:0] next_pc;

wire [31:0] current_pc;

pc uut (

    .clk(clk),
    .reset(reset),
    .next_pc(next_pc),
    .current_pc(current_pc)

);

always #5 clk = ~clk;

initial begin

    clk = 0;
    reset = 1;
    next_pc = 0;

    #10;

    reset = 0;

    next_pc = 4;
    #10;

    next_pc = 8;
    #10;

    next_pc = 12;
    #10;

    $finish;

end

endmodule
