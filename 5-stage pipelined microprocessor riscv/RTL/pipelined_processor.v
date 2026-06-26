`timescale 1ns / 1ps

module pipelined_processor(

    input clk,
    input reset

);
   // IF Stage wires
    wire [31:0] pc_current;
    wire [31:0] pc_next;
    wire [31:0] instruction;

  // IF/ID Register outputs
    wire [31:0] if_id_pc;
    wire [31:0] if_id_instruction;

  // ID stage wires
    wire [31:0] read_data1;
    wire [31:0] read_data2;
    wire [31:0] immediate;
    
    // Control signals from CU (before hazard mux)
    wire reg_write_cu;
    wire alu_src_cu;
    wire mem_read_cu;
    wire mem_write_cu;
    wire mem_to_reg_cu;
    wire branch_cu;
    wire jump_cu;
    wire [1:0]  alu_op_cu;
 
    // After bubble mux (zeroed on stall)
    wire reg_write_id;
    wire alu_src_id;
    wire mem_read_id;
    wire mem_write_id;
    wire mem_to_reg_id;
    wire branch_id;
    wire jump_id;
    wire [1:0] alu_op_id;

  // ID/EX Register outputs
    wire [31:0] id_ex_pc;
    wire [31:0] id_ex_read_data1;
    wire [31:0] id_ex_read_data2;
    wire [31:0] id_ex_immediate;
    wire [4:0] id_ex_rs1;
    wire [4:0] id_ex_rs2;
    wire [4:0] id_ex_rd;
    wire [2:0] id_ex_funct3;
    wire [6:0] id_ex_funct7;
    wire id_ex_reg_write;
    wire id_ex_alu_src;
    wire id_ex_mem_read;
    wire id_ex_mem_write;
    wire id_ex_mem_to_reg;
    wire id_ex_branch;
    wire id_ex_jump;
    wire [1:0] id_ex_alu_op;
    

  // EX Stage wires
    wire [3:0] alu_control_signal;  // 4 bits now (SRA + LUI)
    wire [31:0] alu_result;
    wire [31:0] alu_b;
    wire zero;
    wire [31:0] branch_target;      // PC + imm (for branches and JAL)
    wire [31:0] pc_plus4_ex;        // PC + 4  (for JAL link address)
    
    // Forwarding Signals
    reg [1:0] forward_a;
    reg [1:0] forward_b;

    wire [31:0] alu_input_a;
    wire [31:0] alu_input_b_forwarded;
  
    // EX/MEM Register outputs
    wire [31:0] ex_mem_alu_result;
    wire [31:0] ex_mem_read_data2;
    wire [31:0] ex_mem_branch_target;
    wire [31:0] ex_mem_pc_plus4;
    wire ex_mem_zero;
    wire [4:0] ex_mem_rd;
    wire [2:0] ex_mem_funct3;
    wire ex_mem_reg_write;
    wire ex_mem_mem_read;
    wire ex_mem_mem_write;
    wire ex_mem_mem_to_reg;
    wire ex_mem_branch;
    wire ex_mem_jump;

    // MEM Stage wires
    wire [31:0] memory_read_data;

 
    // MEM/WB Register outputs
    wire [31:0] mem_wb_memory_data;
    wire [31:0] mem_wb_alu_result;
    wire [4:0] mem_wb_rd;
    wire mem_wb_reg_write;
    wire mem_wb_mem_to_reg;
 
    // WB Stage
    wire [31:0] write_back_data;
 
    // WB mux: memory data (LW) or ALU result
    assign write_back_data = mem_wb_mem_to_reg ?
                             mem_wb_memory_data :
                             mem_wb_alu_result;
 
    // Hazard / stall signal
    wire stall;
    
    // PC logic
 
    // Branch condition evaluation (uses EX/MEM stage values)
    // All branches do rs1 - rs2; we check condition based on funct3
    // Resolve branch in EX stage (1 cycle earlier - reduces flush penalty)
wire alu_negative = alu_result[31];

wire branch_taken_ex =
    id_ex_branch && !stall && (
        (id_ex_funct3 == 3'b000 &&  zero)                         ||  // BEQ
        (id_ex_funct3 == 3'b001 && !zero)                         ||  // BNE
        (id_ex_funct3 == 3'b100 &&  alu_negative && !zero)            // BLT
    );

wire take_flush = branch_taken_ex || id_ex_jump;

// PC source
assign pc_next = take_flush ? branch_target :
                              (pc_current + 32'd4);

    // Hazard bubble mux: zero ALL control signals on stall
    // This inserts a NOP bubble into the pipeline without
    // corrupting the frozen instructions in IF/ID.
    assign reg_write_id = stall ? 1'b0 : reg_write_cu;
    assign alu_src_id = stall ? 1'b0 : alu_src_cu;
    assign mem_read_id = stall ? 1'b0 : mem_read_cu;
    assign mem_write_id = stall ? 1'b0 : mem_write_cu;
    assign mem_to_reg_id = stall ? 1'b0 : mem_to_reg_cu;
    assign branch_id = stall ? 1'b0 : branch_cu;
    assign jump_id = stall ? 1'b0 : jump_cu;
    assign alu_op_id = stall ? 2'b0 : alu_op_cu;
 
    // EX Stage logic
 
    // Forwarding mux A - selects ALU input A
    assign alu_input_a =
        (forward_a == 2'b10) ? ex_mem_alu_result :  // EX/MEM forward
        (forward_a == 2'b01) ? write_back_data    :  // MEM/WB forward
                               id_ex_read_data1;     // register file
 
    // Forwarding mux B - selects ALU input B (before immediate mux)
    assign alu_input_b_forwarded =
        (forward_b == 2'b10) ? ex_mem_alu_result :  // EX/MEM forward
        (forward_b == 2'b01) ? write_back_data    :  // MEM/WB forward
                               id_ex_read_data2;     // register file
 
    // ALU source mux - use immediate or forwarded register?
    assign alu_b = id_ex_alu_src ? id_ex_immediate : alu_input_b_forwarded;
 
    // Branch / JAL target address: PC + sign-extended immediate
    assign branch_target = id_ex_pc + id_ex_immediate;
 
    // JAL link address: PC + 4
    assign pc_plus4_ex = id_ex_pc + 32'd4;
 
    // Forwarding unit - combinational logic
    always @(*) begin
        forward_a = 2'b00;
        forward_b = 2'b00;
 
        // EX/MEM forwarding has priority over MEM/WB
        // Forward A
        if (ex_mem_reg_write && (ex_mem_rd != 5'b0) && (ex_mem_rd == id_ex_rs1))
            forward_a = 2'b10;
        else if (mem_wb_reg_write && (mem_wb_rd != 5'b0) && (mem_wb_rd == id_ex_rs1))
            forward_a = 2'b01;
 
        // Forward B
        if (ex_mem_reg_write && (ex_mem_rd != 5'b0) && (ex_mem_rd == id_ex_rs2))
            forward_b = 2'b10;
        else if (mem_wb_reg_write && (mem_wb_rd != 5'b0) && (mem_wb_rd == id_ex_rs2))
            forward_b = 2'b01;
    end

    // Module instantiations
    // IF Stage 
    pc PC (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .flush(take_flush),
        .next_pc(pc_next),
        .branch_target(branch_target),
        .current_pc(pc_current)
    );
 
    instruction_memory IM (
        .address(pc_current),
        .instruction(instruction)
    );
 
    if_id IF_ID (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .flush(take_flush),
        .pc_in(pc_current),
        .instruction_in(instruction),
        .pc_out(if_id_pc),
        .instruction_out(if_id_instruction)
    );
 
    // ?? ID Stage ??
    control_unit CU (
        .opcode(if_id_instruction[6:0]),
        .reg_write(reg_write_cu),
        .alu_src(alu_src_cu),
        .mem_read(mem_read_cu),
        .mem_write(mem_write_cu),
        .mem_to_reg(mem_to_reg_cu),
        .branch(branch_cu),
        .jump(jump_cu),
        .alu_op(alu_op_cu)
    );
 
    register_file RF (
        .clk(clk),
        .reg_write(mem_wb_reg_write),
        .rs1(if_id_instruction[19:15]),
        .rs2(if_id_instruction[24:20]),
        .rd(mem_wb_rd),
        .write_data(write_back_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );
 
    immediate_generator IG (
        .instruction(if_id_instruction),
        .immediate(immediate)
    );
 
    hazard_detection_unit HDU (
        .id_ex_mem_read(id_ex_mem_read),
        .id_ex_rd(id_ex_rd),
        .if_id_rs1(if_id_instruction[19:15]),
        .if_id_rs2(if_id_instruction[24:20]),
        .stall(stall)
    );
 
    id_ex ID_EX (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .flush(take_flush),
 
        .pc_in(if_id_pc),
        .read_data1_in(read_data1),
        .read_data2_in(read_data2),
        .immediate_in(immediate),
        .rs1_in(if_id_instruction[19:15]),
        .rs2_in(if_id_instruction[24:20]),
        .rd_in(if_id_instruction[11:7]),
        .funct3_in(if_id_instruction[14:12]),
        .funct7_in(if_id_instruction[31:25]),
 
        .reg_write_in(reg_write_id),
        .alu_src_in(alu_src_id),
        .mem_read_in(mem_read_id),
        .mem_write_in(mem_write_id),
        .mem_to_reg_in(mem_to_reg_id),
        .branch_in(branch_id),
        .jump_in(jump_id),
        .alu_op_in(alu_op_id),
 
        .pc_out(id_ex_pc),
        .read_data1_out(id_ex_read_data1),
        .read_data2_out(id_ex_read_data2),
        .immediate_out(id_ex_immediate),
        .rs1_out(id_ex_rs1),
        .rs2_out(id_ex_rs2),
        .rd_out(id_ex_rd),
        .funct3_out(id_ex_funct3),
        .funct7_out(id_ex_funct7),
 
        .reg_write_out(id_ex_reg_write),
        .alu_src_out(id_ex_alu_src),
        .mem_read_out(id_ex_mem_read),
        .mem_write_out(id_ex_mem_write),
        .mem_to_reg_out(id_ex_mem_to_reg),
        .branch_out(id_ex_branch),
        .jump_out(id_ex_jump),
        .alu_op_out(id_ex_alu_op)
    );
 
    // ?? EX Stage ??
    alu_control AC (
        .alu_op(id_ex_alu_op),
        .funct3(id_ex_funct3),
        .funct7(id_ex_funct7),
        .alu_control(alu_control_signal)
    );
 
    alu ALU (
        .a(alu_input_a),
        .b(alu_b),
        .alu_control(alu_control_signal),
        .result(alu_result),
        .zero(zero)
    );
 
    ex_mem EX_MEM (
        .clk(clk),
        .reset(reset),
 
        .alu_result_in(alu_result),
        .read_data2_in(alu_input_b_forwarded), // forwarded RS2 for SW
        .branch_target_in(branch_target),
        .pc_plus4_in(pc_plus4_ex),
        .zero_in(zero),
        .rd_in(id_ex_rd),
        .funct3_in(id_ex_funct3),
 
        .reg_write_in(id_ex_reg_write),
        .mem_read_in(id_ex_mem_read),
        .mem_write_in(id_ex_mem_write),
        .mem_to_reg_in(id_ex_mem_to_reg),
        .branch_in(id_ex_branch),
        .jump_in(id_ex_jump),
 
        .alu_result_out(ex_mem_alu_result),
        .read_data2_out(ex_mem_read_data2),
        .branch_target_out(ex_mem_branch_target),
        .pc_plus4_out(ex_mem_pc_plus4),
        .zero_out(ex_mem_zero),
        .rd_out(ex_mem_rd),
        .funct3_out(ex_mem_funct3),
 
        .reg_write_out(ex_mem_reg_write),
        .mem_read_out(ex_mem_mem_read),
        .mem_write_out(ex_mem_mem_write),
        .mem_to_reg_out(ex_mem_mem_to_reg),
        .branch_out(ex_mem_branch),
        .jump_out(ex_mem_jump)
    );
 
    // ?? MEM Stage ??
    data_memory DM (
        .clk(clk),
        .mem_read(ex_mem_mem_read),
        .mem_write(ex_mem_mem_write),
        .address(ex_mem_alu_result),
        .write_data(ex_mem_read_data2),
        .read_data(memory_read_data)
    );
 
    mem_wb MEM_WB (
        .clk(clk),
        .reset(reset),
 
        .memory_data_in(memory_read_data),
        .alu_result_in(ex_mem_alu_result),
        .rd_in(ex_mem_rd),
        .reg_write_in(ex_mem_reg_write),
        .mem_to_reg_in(ex_mem_mem_to_reg),
 
        .memory_data_out(mem_wb_memory_data),
        .alu_result_out(mem_wb_alu_result),
        .rd_out(mem_wb_rd),
        .reg_write_out(mem_wb_reg_write),
        .mem_to_reg_out(mem_wb_mem_to_reg)
    );
 
    // ?? WB Stage: write_back_data already assigned at top ??
 
endmodule