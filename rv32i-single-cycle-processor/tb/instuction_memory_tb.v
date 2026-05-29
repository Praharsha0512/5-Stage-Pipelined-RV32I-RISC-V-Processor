`timescale 1ns / 1ps

module instruction_memory_tb;

    reg [31:0] address;
    wire [31:0] instruction;

    // DUT
    instruction_memory uut (
        .address(address),
        .instruction(instruction)
    );

    initial begin

        // Test Address 0
        address = 32'd0;
        #10;

        // Test Address 4
        address = 32'd4;
        #10;

        // Test Address 8
        address = 32'd8;
        #10;

        // Test Address 12
        address = 32'd12;
        #10;

        // Test Address 16
        address = 32'd16;
        #10;

        $finish;

    end

endmodule
