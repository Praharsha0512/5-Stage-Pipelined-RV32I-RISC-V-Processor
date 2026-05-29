// ============================
// instruction_memory.v
// ============================

module instruction_memory(

    input [31:0] address,
    output reg [31:0] instruction

);

always @(*) begin

    case(address)

        32'h00000000: instruction = 32'h00500093; // addi x1,x0,5

        32'h00000004: instruction = 32'h00A00113; // addi x2,x0,10

        32'h00000008: instruction = 32'h002081B3; // add x3,x1,x2

        32'h0000000C: instruction = 32'h00302023; // sw x3,0(x0)

        32'h00000010: instruction = 32'h00002203; // lw x4,0(x0)

        32'h00000014: instruction = 32'h401102B3; // sub x5,x2,x1

        32'h00000018: instruction = 32'h0020F333; // and x6,x1,x2

        32'h0000001C: instruction = 32'h0020E3B3; // or x7,x1,x2

        32'h00000020: instruction = 32'h00108463; // beq x1,x1,+8

        default: instruction = 32'h00000013;

    endcase

end

endmodule