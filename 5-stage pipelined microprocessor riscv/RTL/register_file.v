`timescale 1ns / 1ps

module register_file(
    input  wire clk,
    input  wire reg_write,
    input  wire [4:0] rs1,
    input  wire [4:0] rs2,
    input  wire [4:0] rd,
    input  wire [31:0] write_data,
    output wire [31:0] read_data1,
    output wire [31:0] read_data2
);
    reg [31:0] registers [0:31];
    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] = 32'b0;
    end

    // Synchronous write
    always @(posedge clk) begin
        if (reg_write && rd != 5'b0)
            registers[rd] <= write_data;
    end
    
    // Write-first read: if WB is writing to the reg we're reading,
    // return the new write_data directly so we never read stale data.
    assign read_data1 = (rs1 == 5'b0) ? 32'b0 :
                        (reg_write && rd == rs1 && rd != 5'b0) ? write_data :
                                                                   registers[rs1];
 
    assign read_data2 = (rs2 == 5'b0) ? 32'b0 :
                        (reg_write && rd == rs2 && rd != 5'b0) ? write_data :
                                                                   registers[rs2];
endmodule
