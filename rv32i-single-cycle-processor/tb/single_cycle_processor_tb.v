`timescale 1ns / 1ps

module single_cycle_processor_tb;

reg clk;
reg reset;

single_cycle_processor uut (
    .clk(clk),
    .reset(reset)
);

always #5 clk = ~clk;

initial begin

    clk = 0;
    reset = 1;

    #10;
    reset = 0;

    #40;

    $finish;

end

endmodule