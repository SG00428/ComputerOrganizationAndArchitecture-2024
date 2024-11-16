`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////

module pipe_MIPS32 (clk1, clk2);
	input clk1, clk2;	// Two-phase clock
	reg [31:0] PC, IF_EX_IR, IF_EX_NPC;

	reg [31:0] EX_MEM_IR, EX_MEM_ALUOut, EX_MEM_B;
	reg EX_MEM_cond;
	reg [2:0]  IF_EX_type, EX_MEM_type;

	reg [31:0] Reg [0:31];   // Registers (32 x 32)
	reg [31:0] Mem [0:1023]; // 1024 x 32 memory
	reg [31:0] A, B, Imm;

	parameter ADD = 6'b000000, SUB = 6'b000001, AND = 6'b000010, OR = 6'b000011,
		  SLT = 6'b000100, MUL = 6'b000101, HLT = 6'b111111, LW = 6'b001000,
		  SW = 6'b001001, ADDI = 6'b001010, SUBI = 6'b001011, SLTI = 6'b001100,
		  BNEQZ = 6'b001101, BEQZ = 6'b001110;

	parameter RR_ALU = 3'b000, RM_ALU = 3'b001, LOAD = 3'b010, STORE = 3'b011,
		  BRANCH = 3'b100, HALT = 3'b101;

	reg HALTED;
	reg TAKEN_BRANCH;

always @(posedge clk1)	// IF
	if (HALTED == 0)
	begin
		if (((EX_MEM_IR[31:26] == BEQZ) && (EX_MEM_cond == 1)) || ((EX_MEM_IR[31:26] == BNEQZ) && (EX_MEM_cond == 0)))
		begin
			IF_EX_IR <= #2 Mem[EX_MEM_ALUOut];
			TAKEN_BRANCH <= #2 1'b1;
			IF_EX_NPC <= #2 EX_MEM_ALUOut + 1;
			PC <= #2 EX_MEM_ALUOut + 1;
		end
		else
		begin
			IF_EX_IR <= #2 Mem[PC];
			IF_EX_NPC <= #2 PC + 1;
			PC <= #2 PC + 1;
		end
	end

always @(posedge clk2)  // EX
	if (HALTED == 0)
	begin
		// Decode and execute in a single cycle

		if (IF_EX_IR[25:21] == 5'b00000) A = 0;
		else A <= #2 Reg[IF_EX_IR[25:21]];

		if (IF_EX_IR[20:16] == 5'b00000) B = 0;
		else B <= #2 Reg[IF_EX_IR[20:16]];

		Imm <= #2 {{16{IF_EX_IR[15]}}, {IF_EX_IR[15:0]}};

		case (IF_EX_IR[31:26])
			ADD, SUB, AND, OR, SLT, MUL:    IF_EX_type <= #2 RR_ALU;
			ADDI, SUBI, SLTI:		IF_EX_type <= #2 RM_ALU;
			LW:				IF_EX_type <= #2 LOAD;
			SW:				IF_EX_type <= #2 STORE;
			BNEQZ, BEQZ:			IF_EX_type <= #2 BRANCH;
			HLT:				IF_EX_type <= #2 HALT;
			default:			IF_EX_type <= #2 HALT;
		endcase
	end
  
always @(negedge clk2)
		if (HALTED == 0)
	begin
		case (IF_EX_type)
			RR_ALU : begin
				case (IF_EX_IR[31:26])
					ADD: EX_MEM_ALUOut <= #2 A + B;
					SUB: EX_MEM_ALUOut <= #2 A - B;
					AND: EX_MEM_ALUOut <= #2 A & B;
					OR : EX_MEM_ALUOut <= #2 A | B;
					SLT: EX_MEM_ALUOut <= #2 (A < B);
					MUL: EX_MEM_ALUOut <= #2 A * B;
					default: EX_MEM_ALUOut <= #2 32'hxxxxxxxx;
				endcase
			end
			RM_ALU : begin
				case (IF_EX_IR[31:26])
					ADDI: EX_MEM_ALUOut <= #2 A + Imm;
					SUBI: EX_MEM_ALUOut <= #2 A - Imm;
					SLTI: EX_MEM_ALUOut <= #2 (A < Imm);
					default: EX_MEM_ALUOut <= #2 32'hxxxxxxxx;
				endcase
			end
			LOAD, STORE: begin
				EX_MEM_ALUOut <= #2 A + Imm;
				EX_MEM_B <= #2 B;
			end
			BRANCH: begin
				EX_MEM_ALUOut <= #2 IF_EX_NPC + Imm;
				EX_MEM_cond <= #2 (A == 0);
			end
		endcase
		EX_MEM_type <= #2 IF_EX_type;
		EX_MEM_IR   <= #2 IF_EX_IR;
		TAKEN_BRANCH <= #2 0;
	end

always @(posedge clk1)  // MEM
	if (HALTED == 0)
	begin
		case (EX_MEM_type)
			RR_ALU:
				Reg[EX_MEM_IR[15:11]] <= #2 EX_MEM_ALUOut;
			RM_ALU:
				Reg[EX_MEM_IR[20:16]] <= #2 EX_MEM_ALUOut;

			LOAD: 
				Reg[EX_MEM_IR[20:16]] <= #2 Mem[EX_MEM_ALUOut];

			STORE: 
				if (TAKEN_BRANCH == 0)
					Mem[EX_MEM_ALUOut] <= #2 EX_MEM_B;
			HALT: 
				HALTED <= #2 1'b1;
		endcase
	end
endmodule

