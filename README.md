# 5-Stage-Pipelined-RV32I-RISC-V-Processor

A 32-bit RISC-V processor implementing the RV32I base instruction set, built first as a single-cycle design and then re-architected into a 5-stage pipelined datapath with hazard detection and data forwarding. Implemented in Verilog HDL and verified in Xilinx Vivado 2023.2.

## Architecture

5-stage pipeline: **IF → ID → EX → MEM → WB**

- **IF (Instruction Fetch):** Program Counter + Instruction Memory
- **ID (Instruction Decode):** Control Unit, Register File, Immediate Generator
- **EX (Execute):** ALU, ALU Control, branch target/condition resolution
- **MEM (Memory Access):** Data Memory (load/store)
- **WB (Write Back):** Register file write-back mux

### Modules (14 total)

pc.v, instruction_memory.v, if_id.v, control_unit.v, register_file.v, immediate_generator.v, hazard_detection_unit.v, id_ex.v, alu_control.v, alu.v, ex_mem.v, data_memory.v, mem_wb.v, pipelined_processor.v (top-level integration)

## Supported Instructions (21)

| Category | Instructions |
|---|---|
| R-type arithmetic/logical | ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT |
| I-type immediate | ADDI, ANDI, ORI, XORI, SLTI |
| Load/Store | LW, SW |
| Branch | BEQ, BNE, BLT, BGE |
| Upper immediate | LUI |
| Jump | JAL |

## Hazard Handling

- **Data hazards (RAW):** Resolved via 2 forwarding bypass paths — EX/MEM → EX and MEM/WB → EX — eliminating stalls for back-to-back dependent instructions wherever forwarding is sufficient.
- **Load-use hazard:** Detected by a dedicated hazard detection unit, which inserts a single-cycle stall only when a load's result is needed by the immediately following instruction.
- **Control hazards (branches/jumps):** Resolved in the EX stage. A dual-stage flush (IF/ID and ID/EX) squashes incorrectly fetched instructions on taken branches and jumps. Both taken and not-taken branch outcomes are verified.

## Verification

Functional correctness verified with a self-checking Verilog testbench in Vivado, exercising all 21 instructions, the load-use stall, EX/MEM and MEM/WB forwarding, taken branches (BEQ, BNE, BLT), a not-taken branch (BGE), and the JAL halt loop.

**Result: 22 registers checked against expected values — ALL CHECKS PASSED.**

| Register | Instruction | Result | Notes |
|---|---|---|---|
| x1 | ADDI | 5 | ✓ |
| x2 | ADDI | 10 | ✓ |
| x3 | ADD | 15 | ✓ |
| x4 | SUB | 5 | ✓ |
| x5 | AND | 0 | ✓ |
| x6 | OR | 15 | ✓ |
| x7 | XOR | 15 | ✓ |
| x8 | SLL | 5120 | ✓ |
| x9 | SRL | 0 | ✓ |
| x10 | SRA | 0 | ✓ |
| x11 | SLT | 1 | ✓ |
| x12 | SLTI | 1 | ✓ |
| x13 | ANDI | 2 | ✓ |
| x14 | ORI | 15 | ✓ |
| x15 | XORI | 13 | ✓ |
| x16 | LUI | 4096 | ✓ |
| x17 | LW | 15 | ✓ forwarding verified |
| x18 | ADDI | 16 | ✓ load-use stall verified |
| x19 | BNE | 0 | ✓ correctly skipped (not taken) |
| x20 | BEQ | 0 | ✓ correctly skipped (not taken) |
| x21 | BLT | 0 | ✓ correctly skipped (not taken) |
| x22 | BGE | 190 | ✓ fall-through verified (not taken) |

**Memory[0] = 15** ✓

## Repository Structure
.
├── 5-stage-pipelined-microprocessor/
│   ├── RTL/              # Verilog source modules
│   ├── Synthesis/        # Synthesis reports (Vivado, xc7k70tfbv676-1)
│   ├── Testbench/        # Testbench + program.hex test vectors
│   └── Waveforms/        # Simulation waveforms (VCD) and screenshots
├── rv32i-single-cycle-processor/
│   ├── rtl/              # Single-cycle Verilog source modules
│   ├── tb/               # Single-cycle testbench
│   └── waveforms/        # Single-cycle waveforms
└── README.md

##How to Run

Clone the repository and open the project in Vivado 2023.2.
Add all files from 5-stage-pipelined-microprocessor/RTL/ and 5-stage-pipelined-microprocessor/Testbench/ as sources.
Set pipelined_processor_tb as the simulation top module.
Run Behavioral Simulation.
Console output reports per-register results and prints a final ALL CHECKS PASSED / SOME CHECKS FAILED summary.

Make sure program.hex from Testbench/ is in the working directory so the instruction memory initializes correctly.

##Tools

-Xilinx Vivado 2023.2
-Target device: xc7k70tfbv676-1 (Kintex-7)
-HDL: Verilog


##Known Limitations / Future Work

- JALR and byte/halfword memory operations (LB, LH, LBU, LHU, SB, SH) are not yet implemented.
- AUIPC is partially scaffolded but not wired into the EX-stage PC-relative addressing mux.
- No top-level debug output ports are currently exposed; internal state is verified via hierarchical testbench access in simulation.
- Timing constraints (clock period) were not specified prior to synthesis, so timing closure (WNS/TNS) was not evaluated; synthesis was run primarily to confirm structural correctness of the design.
