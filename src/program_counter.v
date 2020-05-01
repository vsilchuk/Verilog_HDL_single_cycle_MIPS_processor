// Module: program_counter.v
// Project: Single-cycle MIPS processor in Verilog HDL.	
// Description: Program counter for a single-cycle MIPS processor.
// Author: github.com/vsilchuk

module program_counter(i_clk, i_arst, i_next_addr, o_curr_addr); 

input i_clk;
input i_arst;
input [31:0] i_next_addr;
output reg [31:0] o_curr_addr;

always @(posedge i_clk, posedge i_arst) 
	if(i_arst) begin
		o_curr_addr <= 32'd0;
	end else begin
		o_curr_addr <= i_next_addr;
	end
endmodule

