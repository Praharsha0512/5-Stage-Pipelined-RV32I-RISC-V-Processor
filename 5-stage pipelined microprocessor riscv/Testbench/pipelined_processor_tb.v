`timescale 1ns / 1ps

module pipelined_processor_tb;
 
    reg clk;
    reg reset;
 
    // Instantiate the processor
    pipelined_processor uut (
        .clk  (clk),
        .reset(reset)
    );
 
    // 10ns clock period (100 MHz)
    initial clk = 0;
    always #5 clk = ~clk;
 
    // ?? Simulation control ??
    initial begin
        // Hold reset for 2 cycles
        reset = 1;
        @(posedge clk); #1;
        @(posedge clk); #1;
        reset = 0;
 
        // Run for 40 cycles - enough for all 26 instructions + pipeline drain
        repeat(60) @(posedge clk);
        repeat (10) @(posedge clk);
 
        // ?? Final register check ??
        $display("x1 = %0d", uut.RF.registers[1]);
        $display("");
        $display("============================================================");
        $display("         FINAL REGISTER FILE STATE");
        $display("============================================================");
        $display("x1  (ADDI)  = %0d  (expected 5)",   uut.RF.registers[1]);
        $display("x2  (ADDI)  = %0d  (expected 10)",  uut.RF.registers[2]);
        $display("x3  (ADD)   = %0d  (expected 15)",  uut.RF.registers[3]);
        $display("x4  (SUB)   = %0d  (expected 5)",   uut.RF.registers[4]);
        $display("x5  (AND)   = %0d  (expected 0)",   uut.RF.registers[5]);
        $display("x6  (OR)    = %0d  (expected 15)",  uut.RF.registers[6]);
        $display("x7  (XOR)   = %0d  (expected 15)",  uut.RF.registers[7]);
        $display("x8  (SLL)   = %0d  (expected 5120)",uut.RF.registers[8]);
        $display("x9  (SRL)   = %0d  (expected 0)",   uut.RF.registers[9]);
        $display("x10 (SRA)   = %0d  (expected 0)",   uut.RF.registers[10]);
        $display("x11 (SLT)   = %0d  (expected 1)",   uut.RF.registers[11]);
        $display("x12 (SLTI)  = %0d  (expected 1)",   uut.RF.registers[12]);
        $display("x13 (ANDI)  = %0d  (expected 2)",   uut.RF.registers[13]);
        $display("x14 (ORI)   = %0d  (expected 15)",  uut.RF.registers[14]);
        $display("x15 (XORI)  = %0d  (expected 13)",  uut.RF.registers[15]);
        $display("x16 (LUI)   = %0d  (expected 4096)",uut.RF.registers[16]);
        $display("x17 (LW)    = %0d  (expected 15)",  uut.RF.registers[17]);
        $display("x18 (ADDI)  = %0d  (expected 16)",  uut.RF.registers[18]);
        $display("x19 (BNE skip) = %0d  (expected 0, MUST be 0)", uut.RF.registers[19]);
        $display("x20 (BEQ skip) = %0d  (expected 0, MUST be 0)", uut.RF.registers[20]);
        $display("x21 (BLT skip) = %0d  (expected 0, MUST be 0)", uut.RF.registers[21]);
        $display("x22 (BGE not-taken) = %0d  (expected 190)", uut.RF.registers[22]);
        $display("============================================================");
        $display("Memory[0] (SW x3 then LW) = %0d  (expected 15)", uut.DM.memory[0]);
        $display("============================================================");
 
        // ?? Pass/Fail ??
        if (uut.RF.registers[3]  == 15 &&
            uut.RF.registers[11] == 1  &&
            uut.RF.registers[17] == 15 &&
            uut.RF.registers[18] == 16 &&
            uut.RF.registers[19] == 0  &&
            uut.RF.registers[20] == 0  &&
            uut.RF.registers[21] == 0  &&
            uut.RF.registers[22] == 190)
            $display("ALL CHECKS PASSED");
        else
            $display("SOME CHECKS FAILED - review waveform");
            // Wait extra cycles for pipeline to fully drain
        $finish;
    end
    // ?? Cycle-by-cycle monitor (prints to Vivado TCL console) ??
    always @(posedge clk) begin
        if (!reset) begin
            $display("clk=%0t | PC=%0d | instr=%h | stall=%b | flush=%b",
                $time,
                uut.pc_current,
                uut.instruction,
                uut.stall,
                uut.take_flush
            );
        end
    end
endmodule
