`timescale 1ns / 1ps

module control_unit(

    input [6:0] opcode,
    output reg reg_write,
    output reg alu_src,
    output reg mem_read,
    output reg mem_write,
    output reg mem_to_reg,
    output reg branch,
    output reg jump,
    output reg [1:0] alu_op
);
    always @(*) begin
        reg_write = 1'b0;
        alu_src = 1'b0;
        mem_read = 1'b0;
        mem_write = 1'b0;
        mem_to_reg = 1'b0;
        branch = 1'b0;
        jump = 1'b0;
        alu_op = 2'b00;
 
        case (opcode)
 
            // ?? R-type: ADD, SUB, AND, OR, XOR, SLT, SLL, SRL, SRA ??
            7'b0110011: begin
                reg_write = 1'b1;
                alu_op = 2'b10;  // ALU control uses funct3/funct7
            end
 
            // ?? I-type ALU: ADDI, ANDI, ORI, XORI, SLTI, SLLI, SRLI ??
            // BUG FIX: was alu_op=2'b00 (always ADD). Now 2'b10 so
            // alu_control uses funct3 to select ADDI vs ANDI etc.
            7'b0010011: begin
                reg_write = 1'b1;
                alu_src = 1'b1;   // use immediate
                alu_op = 2'b10;  // FIXED: was 2'b00
            end
 
            // ?? Load: LW ??
            7'b0000011: begin
                reg_write = 1'b1;
                alu_src = 1'b1;
                mem_read = 1'b1;
                mem_to_reg = 1'b1;
                alu_op = 2'b00;  // ADD for address calculation
            end
 
            // ?? Store: SW ??
            7'b0100011: begin
                alu_src = 1'b1;
                mem_write = 1'b1;
                alu_op = 2'b00;  // ADD for address calculation
            end
 
            // ?? Branch: BEQ, BNE, BLT, BGE ??
            // EX stage uses funct3 to pick the right condition
            7'b1100011: begin
                branch = 1'b1;
                alu_op = 2'b01;  // SUB - result used for comparison
            end
 
            // ?? LUI ??
            7'b0110111: begin
                reg_write = 1'b1;
                alu_src = 1'b1;
                alu_op = 2'b11;  // pass-through mode in ALU
            end
 
            // ?? JAL ??
            7'b1101111: begin
                reg_write = 1'b1;
                jump = 1'b1;
                // rd = PC+4, target = PC + imm (handled in EX)
            end
 
            default: begin
                // NOP / unimplemented: all signals stay 0
            end
        endcase
    end
endmodule