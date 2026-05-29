`timescale 1ns / 1ps

module data_memory_tb;

reg clk;

reg mem_read;
reg mem_write;

reg [31:0] address;
reg [31:0] write_data;

wire [31:0] read_data;

data_memory uut(

    .clk(clk),

    .mem_read(mem_read),
    .mem_write(mem_write),

    .address(address),
    .write_data(write_data),

    .read_data(read_data)

);

always #5 clk = ~clk;

initial begin

    clk = 0;

    mem_read = 0;
    mem_write = 0;

    address = 0;
    write_data = 0;

    #10;

    mem_write = 1;
    address = 4;
    write_data = 32'd100;
    #10;

    mem_write = 0;

    mem_read = 1;
    address = 4;
    #10;

    mem_read = 0;

    #10;

    $finish;

end

endmodule