`timescale 1ns / 1ps

module pc(

    input clk,
    input reset,
    input [31:0] next_pc,
    input stall, // 1 = freeze PC (load-use hazard)
    input flush, // 1 = load branch/jump target
    input [31:0] branch_target,// branch/jump resolved address
    output reg [31:0] current_pc

  );

    always @(posedge clk or posedge reset) begin
        if(reset)
            current_pc <= 32'b0;
         else if (flush)        
            current_pc <= branch_target;
        else if(!stall)
            current_pc <= next_pc;
     end
endmodule
