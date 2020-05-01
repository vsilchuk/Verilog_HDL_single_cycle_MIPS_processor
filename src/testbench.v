// Module: testbench.v
// Project: Single-cycle MIPS processor in Verilog HDL.	
// Author: github.com/vsilchuk

`timescale 1ns / 1ns

module testbench;

parameter PERIOD = 2;	// 20	

reg clock;
reg reset;
wire [31:0] instr;
wire [31:0] cur_pc;
wire [31:0] next_pc;

// port map - connection between master ports and signals/registers   
												
MIPS MIPS_inst(.i_clk(clock),						
		.i_arst(reset),
		.o_instruction(instr),
		.o_pc_cur(cur_pc),
		.o_pc_next(next_pc));

initial begin
#10
    clock = 0;
    forever #(PERIOD/2) clock = ~clock;
end

initial begin
#0 
	reset = 1;
#10
	reset = 0;

#300000
    $finish;  
end
  
endmodule

