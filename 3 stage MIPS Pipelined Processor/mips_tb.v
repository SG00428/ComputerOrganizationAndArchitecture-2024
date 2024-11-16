////////////// FACTORIAL /////////////////////

module test_mips32;
	reg clk1, clk2;
	integer k;
	pipe_MIPS32 mips (clk1, clk2);

	initial begin
		clk1 = 0;
		clk2 = 0;
		repeat (50) begin
			#5 clk1 = 1; #5 clk1 = 0;
			#5 clk2 = 1; #5 clk2 = 0;
		end
	end

	initial begin
		// Initialize register values
		for (k = 0; k < 31; k = k + 1)
			mips.Reg[k] = k;

		// Initialize memory with instructions
		mips.Mem[0] = 32'h280a00c8; // ADDI R10,R0,200
		mips.Mem[1] = 32'h28020001; // ADDI R2,R0,1
		mips.Mem[2] = 32'h0e94a000; // Dummy instr
		mips.Mem[3] = 32'h21430000; // LW R3,0(R10)
		mips.Mem[4] = 32'h0e94a000; // Dummy instr
		mips.Mem[5] = 32'h14431000; // Loop : MUL R2,R2,R3
		mips.Mem[6] = 32'h2c630001; // SUBI R3,R3,1
		mips.Mem[7] = 32'h0e94a000; // Dummy instr
		mips.Mem[8] = 32'h3460fffc; // BNEQZ R3,Loop
		mips.Mem[9] = 32'h2542fffe; // SW R2,-2(R10)
		mips.Mem[10] = 32'hfc000000; // HLT
		mips.Mem[200] = 7;

		// Initialize control signals
		mips.HALTED = 0;
		mips.PC = 0;
		mips.TAKEN_BRANCH = 0;

		#3000;
		$display("Mem[200] = %2d, Mem[198] = %6d", mips.Mem[200], mips.Mem[198]);
	end

	initial begin
		$dumpfile("mips.vcd");
		$dumpvars(0, test_mips32);
		$monitor ("R10: %4d", mips.Reg[10]);
    	$monitor ("R2: %4d", mips.Reg[2]);
   	    $monitor ("R3: %4d", mips.Reg[3]);
		#4000 $finish;
	end
endmodule



/////////////// Arithmetic ////////////////////

//module test_mips32;
//	reg clk1, clk2;
//	integer k;
//	pipe_MIPS32 mips (clk1, clk2);

//	initial begin
//		clk1 = 0;
//		clk2 = 0;
//		repeat (20) begin
//			#5 clk1 = 1; #5 clk1 = 0;
//			#5 clk2 = 1; #5 clk2 = 0;
//		end
//	end

//	initial begin
//		// Initialize register values
//		for (k = 0; k < 32; k = k + 1)
//			mips.Reg[k] = k;

//		// Initialize memory with instructions
//		mips.Mem[0] = 32'h2801000a; // ADDI R1, R0, 10
//		mips.Mem[1] = 32'h28020014; // ADDI R2, R0, 20
//		mips.Mem[2] = 32'h28030019; // ADDI R3, R0, 25
//		mips.Mem[3] = 32'h00222000; // ADD R4, R1, R2
//		mips.Mem[4] = 32'h0ce77800; // Dummy instruction
//		mips.Mem[5] = 32'h00832800; // ADD R5, R4, R3
//		mips.Mem[6] = 32'hfc000000; // HLT

//		// Initialize control signals
//		mips.HALTED = 0;
//		mips.PC = 0;
//		mips.TAKEN_BRANCH = 0;

//		#280;
//		for (k = 0; k < 6; k = k + 1)
//			$display("R%1d - %2d", k, mips.Reg[k]);
//	end

//	initial begin
//		$dumpfile("mips.vcd");
//		$dumpvars(0, test_mips32);
//		#300 $finish;
//	end
//endmodule



//////////////// LOAD STORE ///////////

//module test_mips32;
//	reg clk1, clk2;
//	integer k;
//	pipe_MIPS32 mips (clk1, clk2);

//	initial begin
//		clk1 = 0;
//		clk2 = 0;
//		repeat (20) begin
//			#5 clk1 = 1; #5 clk1 = 0;
//			#5 clk2 = 1; #5 clk2 = 0;
//		end
//	end

//	initial begin
//		// Initialize register values
//		for (k = 0; k < 32; k = k + 1)
//			mips.Reg[k] = k;

//		// Initialize memory with instructions
//      mips.Mem[0] = 32'h28010078; // ADDI R1,R0,120
//      mips.Mem[1] = 32'h0c631800; // Dummy instruction
//      mips.Mem[2] = 32'h20220000; // LW R2, 0(R1)
//      mips.Mem[3] = 32'h0c631800; // Dummy instruction
//      mips.Mem[4] = 32'h2842002d; // ADDI R2, R2, 45
//      mips.Mem[5] = 32'h0c631800; // Dummy instruction
//      mips.Mem[6] = 32'h24220001; // SW R2,1(R1)
//      mips.Mem[7] = 32'hfc000000; // HLT
//      mips.Mem[120] = 85;
//		// Initialize control signals
//		mips.HALTED = 0;
//		mips.PC = 0;
//		mips.TAKEN_BRANCH = 0;

//		#500;
//      $display("Mem[120] - %4d  \nMem[121] : %4d", mips.Mem[120], mips.Mem[121]);
//	end

//	initial begin
//		$dumpfile("mips.vcd");
//		$dumpvars(0, test_mips32);
//		$monitor ("R1: %4d", mips.Reg[1]);
//		$monitor ("R2: %4d", mips.Reg[2]);
//		#600 $finish;
//	end
//endmodule
