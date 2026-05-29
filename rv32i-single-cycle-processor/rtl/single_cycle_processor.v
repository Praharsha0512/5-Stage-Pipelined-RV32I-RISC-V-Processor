// ============================
// single_cycle_processor.v
// ============================

module single_cycle_processor(

    input clk,
    input reset

);

// =================================
// INTERNAL WIRES
// =================================

wire [31:0] current_pc;
wire [31:0] next_pc;

wire [31:0] instruction;

wire reg_write;
wire alu_src;
wire mem_read;
wire mem_write;
wire mem_to_reg;
wire branch;

wire [1:0] alu_op;

wire [4:0] rs1;
wire [4:0] rs2;
wire [4:0] rd;

wire [2:0] funct3;
wire [6:0] funct7;

wire [31:0] read_data1;
wire [31:0] read_data2;

wire [31:0] immediate;

wire [2:0] alu_control_signal;

wire [31:0] alu_input2;
wire [31:0] alu_result;

wire zero;

wire [31:0] memory_data;

wire [31:0] write_back_data;


// =================================
// FIELD EXTRACTION
// =================================

assign rs1 = instruction[19:15];
assign rs2 = instruction[24:20];
assign rd  = instruction[11:7];

assign funct3 = instruction[14:12];
assign funct7 = instruction[31:25];


// =================================
// PROGRAM COUNTER
// =================================

pc PC(

    .clk(clk),
    .reset(reset),

    .next_pc(next_pc),
    .current_pc(current_pc)

);


// =================================
// NEXT PC LOGIC
// =================================

assign next_pc =
        (branch && zero)
        ? current_pc + immediate
        : current_pc + 4;


// =================================
// INSTRUCTION MEMORY
// =================================

instruction_memory IM(

    .address(current_pc),
    .instruction(instruction)

);


// =================================
// CONTROL UNIT
// =================================

control_unit CU(

    .opcode(instruction[6:0]),

    .reg_write(reg_write),
    .alu_src(alu_src),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .mem_to_reg(mem_to_reg),
    .branch(branch),

    .alu_op(alu_op)

);


// =================================
// REGISTER FILE
// =================================

register_file RF(

    .clk(clk),

    .reg_write(reg_write),

    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),

    .write_data(write_back_data),

    .read_data1(read_data1),
    .read_data2(read_data2)

);


// =================================
// IMMEDIATE GENERATOR
// =================================

immediate_generator IG(

    .instruction(instruction),
    .immediate(immediate)

);


// =================================
// ALU CONTROL
// =================================

alu_control AC(

    .alu_op(alu_op),

    .funct3(funct3),
    .funct7(funct7),

    .alu_control(alu_control_signal)

);


// =================================
// ALU INPUT MUX
// =================================

assign alu_input2 =
        (alu_src)
        ? immediate
        : read_data2;


// =================================
// ALU
// =================================

alu ALU(

    .a(read_data1),
    .b(alu_input2),

    .alu_control(alu_control_signal),

    .result(alu_result),
    .zero(zero)

);


// =================================
// DATA MEMORY
// =================================

data_memory DM(

    .clk(clk),

    .mem_read(mem_read),
    .mem_write(mem_write),

    .address(alu_result),

    .write_data(read_data2),

    .read_data(memory_data)

);


// =================================
// WRITEBACK MUX
// =================================

assign write_back_data =
        (mem_to_reg)
        ? memory_data
        : alu_result;


endmodule