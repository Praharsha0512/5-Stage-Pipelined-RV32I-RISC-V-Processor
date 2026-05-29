`timescale 1ns / 1ps

module processor_top_tb;

reg clk;
reg reset;

processor_top uut(

    .clk(clk),
    .reset(reset)

);

always #5 clk = ~clk;

initial begin

    clk = 0;
    reset = 1;

    #10;

    reset = 0;

    #50;

    $finish;

end

endmodule
