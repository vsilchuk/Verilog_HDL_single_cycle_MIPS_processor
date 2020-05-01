// Module: register_file.v
// Project: Single-cycle MIPS processor in Verilog HDL.	
// Description: Register file for one-cycle MIPS processor. 32 x 32-bit resisters.
//		[Added, 17.10]: regisers[0] is a $zero register, always stores zero value.
// Author: github.com/vsilchuk

module register_file(i_clk, i_we, i_arst, i_addr_1, i_addr_2, i_addr_3, i_wdata, o_rdata_1, o_rdata_2);

input i_clk;				// clock signal
input i_we;				// write enable signal
input i_arst;
integer i;

input [4:0] i_addr_1;			// input address of 2^5 = 32 possible registers as data source for command
input [4:0] i_addr_2;			// input address of 2^5 = 32 possible registers as data source for command

input [4:0] i_addr_3;			// input address of 2^5 = 32 posible resisters for writing data in, if WE = 1, on posedge of CLK
input [31:0] i_wdata;			// input data for writing in register with address i_addr_3, if WE = 1, on posedge of CLK

output [31:0] o_rdata_1;		// outputting data from register with address i_addr_1
output [31:0] o_rdata_2;		// outputting data from register with address i_addr_2

reg [31:0] registers[31:0];		// array of 32 * 32-bit registers in register file

assign o_rdata_1 = (i_addr_1 == 0) ? 32'd0 : registers[i_addr_1];	// remember, that registers[0] is $0 register, also known as $zero
assign o_rdata_2 = (i_addr_2 == 0) ? 32'd0 : registers[i_addr_2];	// $zero

always @(posedge i_clk or posedge i_arst)			// synchronous writing data from i_wdata in register with address i_addr_3
	if(i_arst) begin
		for(i = 0; i < 32; i = i + 1) 
			registers[i] <= 32'd0;
	end else if(i_we) begin
		registers[i_addr_3] <= (i_addr_3 == 0) ? 32'd0 : i_wdata;
	end else begin
		for(i = 0; i < 32; i = i + 1) 
			registers[i] <= registers[i];	// if i_arst == 0, and i_we == 0, then we just save the state of registers
	end
endmodule

