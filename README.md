# ComputerOrganizationAndArchitecture-2024

Designed a 3-stage pipelined 32-bit MIPS processor.
 The design aims to efficiently execute a subset of the MIPS32 instruction set, including
 arithmetic, logical, comparison, memory access, and control flow operations. The
 processor pipeline consists of three stages: Instruction Fetch (IF), Execute (EX), and
 Memory (MEM) operating on a two-phase clock. Each stage of the pipeline processes
 one part of an instruction, allowing multiple instructions to be processed simultaneously
for increased performance. The design also includes conditional branching and basic
 hazard handling by manually writing dummy instructions that cause the stalls. This
 processor provides a foundation for understanding the core concepts of pipelining and
 instruction execution in modern RISC processors. The design is implemented in Verilog
 HDL
