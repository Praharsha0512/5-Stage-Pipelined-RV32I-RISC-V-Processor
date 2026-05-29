// ============================
// alu_control.v
// ============================

module alu_control(

    input [1:0] alu_op,

    input [2:0] funct3,
    input [6:0] funct7,

    output reg [2:0] alu_control

);

always @(*) begin

    case(alu_op)

        // ADD
        2'b00: begin

            alu_control = 3'b000;

        end

        // SUB FOR BEQ
        2'b01: begin

            alu_control = 3'b001;

        end

        // R-TYPE
        2'b10: begin

            case(funct3)

                // ADD / SUB
                3'b000: begin

                    if(funct7 == 7'b0100000)
                        alu_control = 3'b001; // SUB
                    else
                        alu_control = 3'b000; // ADD

                end

                // AND
                3'b111: begin

                    alu_control = 3'b010;

                end

                // OR
                3'b110: begin

                    alu_control = 3'b011;

                end

                default: begin

                    alu_control = 3'b000;

                end

            endcase

        end

        default: begin

            alu_control = 3'b000;

        end

    endcase

end

endmodule