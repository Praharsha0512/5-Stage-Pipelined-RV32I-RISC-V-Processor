// ============================
// alu.v
// ============================

module alu(

    input [31:0] a,
    input [31:0] b,

    input [2:0] alu_control,

    output reg [31:0] result,

    output zero

);

always @(*) begin

    case(alu_control)

        // ADD
        3'b000: result = a + b;

        // SUB
        3'b001: result = a - b;

        // AND
        3'b010: result = a & b;

        // OR
        3'b011: result = a | b;

        default: result = 32'b0;

    endcase

end

assign zero = (result == 0);

endmodule