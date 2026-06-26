`timescale 1ns / 1ps

module id_ex(
    input clk,
    input reset,
    input stall,
    input flush,

    // Data inputs
    input [31:0] pc_in,
    input [31:0] read_data1_in,
    input [31:0] read_data2_in,
    input [31:0] immediate_in,
    input [4:0] rs1_in,
    input [4:0] rs2_in,
    input [4:0] rd_in,
    input [2:0] funct3_in,
    input [6:0] funct7_in,
    // Control inputs
    input reg_write_in,
    input alu_src_in,
    input mem_read_in,
    input mem_write_in,
    input mem_to_reg_in,
    input branch_in,
    input jump_in,
    input [1:0] alu_op_in,
    // Data outputs
    output reg [31:0] pc_out,
    output reg [31:0] read_data1_out,
    output reg [31:0] read_data2_out,
    output reg [31:0] immediate_out,
    output reg [4:0] rs1_out,
    output reg [4:0] rs2_out,
    output reg [4:0] rd_out,
    output reg [2:0] funct3_out,
    output reg [6:0] funct7_out,
    // Control outputs
    output reg reg_write_out,
    output reg alu_src_out,
    output reg mem_read_out,
    output reg mem_write_out,
    output reg mem_to_reg_out,
    output reg branch_out,
    output reg jump_out,
    output reg [1:0] alu_op_out
);

always @(posedge clk or posedge reset)
begin
    if (reset || stall || flush) begin
            // Insert NOP bubble: zero out ALL control signals.
            // Data values don't matter since nothing will write/access.
            pc_out <= 32'b0;
            read_data1_out <= 32'b0;
            read_data2_out <= 32'b0;
            immediate_out <= 32'b0;
            rs1_out <= 5'b0;
            rs2_out <= 5'b0;
            rd_out <= 5'b0;
            funct3_out <= 3'b0;
            funct7_out <= 7'b0;
            reg_write_out <= 1'b0;
            alu_src_out <= 1'b0;
            mem_read_out <= 1'b0;
            mem_write_out <= 1'b0;
            mem_to_reg_out <= 1'b0;
            branch_out <= 1'b0;
            jump_out <= 1'b0;
            alu_op_out <= 2'b0;
    end
    else begin
        pc_out <= pc_in;
        read_data1_out <= read_data1_in;
        read_data2_out <= read_data2_in;
        immediate_out <= immediate_in;
        rs1_out <= rs1_in;
        rs2_out <= rs2_in;
        rd_out <= rd_in;
        funct3_out <= funct3_in;
        funct7_out <= funct7_in;
        reg_write_out <= reg_write_in;
        alu_src_out <= alu_src_in;
        mem_read_out <= mem_read_in;
        mem_write_out <= mem_write_in;
        mem_to_reg_out <= mem_to_reg_in;
        branch_out <= branch_in;
        jump_out <=jump_in;
        alu_op_out <= alu_op_in;
    end
end
endmodule
