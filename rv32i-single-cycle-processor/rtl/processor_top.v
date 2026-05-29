module processor_top(

    input clk,
    input reset

);

wire [31:0] current_pc;
wire [31:0] next_pc;
wire [31:0] instruction;

assign next_pc = current_pc + 4;

pc PC(

    .clk(clk),
    .reset(reset),
    .next_pc(next_pc),
    .current_pc(current_pc)

);

instruction_memory IM(

    .address(current_pc),
    .instruction(instruction)

);

endmodule
