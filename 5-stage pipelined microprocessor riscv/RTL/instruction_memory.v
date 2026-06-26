`timescale 1ns / 1ps

module instruction_memory(
    input [31:0] address,
    output reg [31:0] instruction
);
    always @(*) begin
        case (address)
            // ADD, SUB, LW, SW, BEQ
            // ADDI, AND, OR, XOR, ANDI, ORI,
            // XORI, SLT, SLTI, SLL, SRL, SRA, LUI, BNE, BLT, JAL
 
            // ADDI x1, x0, 5      
            32'h00000000: instruction = 32'h00500093;
 
            // ADDI x2, x0, 10     
            32'h00000004: instruction = 32'h00A00113;
 
            // ADD  x3, x1, x2     
            32'h00000008: instruction = 32'h002081B3;
 
            // SUB  x4, x2, x1      
            32'h0000000C: instruction = 32'h40110233;
 
            // AND  x5, x1, x2      
            32'h00000010: instruction = 32'h0020F2B3;
 
            // OR   x6, x1, x2       
            32'h00000014: instruction = 32'h0020E333;
 
            // XOR  x7, x1, x2   
            32'h00000018: instruction = 32'h0020C3B3;
 
            // SLL  x8, x1, x2       
            32'h0000001C: instruction = 32'h00209433;
 
            // SRL  x9, x2, x1      
            32'h00000020: instruction = 32'h002154B3;
 
            // SRA  x10, x4, x1      
            32'h00000024: instruction = 32'h40125533;
 
            // SLT  x11, x1, x2      
            32'h00000028: instruction = 32'h0020A5B3;
 
            // SLTI x12, x1, 7      
            32'h0000002C: instruction = 32'h00702613;
 
            // ANDI x13, x2, 7      
            32'h00000030: instruction = 32'h00717693;
 
            // ORI  x14, x2, 7       
            32'h00000034: instruction = 32'h00716713;
 
            // XORI x15, x2, 7     
            32'h00000038: instruction = 32'h00714793;
 
            // LUI  x16, 1          
            32'h0000003C: instruction = 32'h00001837;
 
            // SW   x3, 0(x0)      
            32'h00000040: instruction = 32'h00302023;
 
            // LW   x17, 0(x0)       
            32'h00000044: instruction = 32'h00002883;
 
            // ADDI x18, x17, 1      
            32'h00000048: instruction = 32'h00188913;
 
            // BNE  x1, x2, +8     
            32'h0000004C: instruction = 32'h00209463;
 
            // ADDI x19, x0, 99     
            32'h00000050: instruction = 32'h06300993;
 
            // BLT  x1, x2, +8      
            32'h00000054: instruction = 32'h0020C463;
 
            // ADDI x20, x0, 99     
            32'h00000058: instruction = 32'h06300A13;
 
            // BEQ  x1, x1, +8     
            32'h0000005C: instruction = 32'h00108463;
 
            // ADDI x21, x0, 99    
            32'h00000060: instruction = 32'h06300A93;

            // BGE  x1, x2, +8       -> 5 >= 10 is FALSE, should NOT branch (fall through)
            32'h00000064: instruction = 32'h0020D463;

           // ADDI x22, x0, 190     -> should EXECUTE normally (proves fall-through works)
           32'h00000068: instruction = 32'h0BE00B13;

          // JAL  x0, +0           -> infinite loop (halt), rd=x0 (discard)
          32'h0000006C: instruction = 32'h0000006F;
 
            // Default: NOP (ADDI x0, x0, 0)
            default:      instruction = 32'h00000013;
        endcase
    end
endmodule
     