`timescale 1ns / 1ps

module hazard_detection_unit(

    input id_ex_mem_read,      // LW is currently in EX stage
    input [4:0] id_ex_rd,      // destination register of LW
    input [4:0] if_id_rs1,     // source register 1 of instruction in ID
    input [4:0] if_id_rs2,     // source register 2 of instruction in ID
    output stall           // 1 = stall PC and IF/ID, bubble ID/EX
);

    // Stall when:
    // 1. There IS a load in EX (id_ex_mem_read=1)
    // 2. The load destination is NOT x0 (x0 is always 0, no hazard)
    // 3. The load destination matches one of the source registers in ID
    assign stall = id_ex_mem_read &&
                   (id_ex_rd != 5'b0) &&
                   ((id_ex_rd == if_id_rs1) ||
                    (id_ex_rd == if_id_rs2));
endmodule
