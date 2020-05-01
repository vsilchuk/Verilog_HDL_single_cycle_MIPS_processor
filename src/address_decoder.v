// Module: address_decoder.v
// Project: Single-cycle MIPS processor in Verilog HDL.	
// Description: The module takes the incoming address and checks its compliance with the address spaces of the corresponding modules. 
// 		If these addresses match, a write enable signal is generated.		
// Author: github.com/vsilchuk

module address_decoder(i_clk, i_we, i_address, o_ram_we, o_ddir_we, o_dout_we, o_din_re, o_dcycle_we, o_config_we);	

input i_clk;
input i_we;
input [31:0] i_address;
output o_ram_we; 
output o_ddir_we;
output o_dout_we;
output o_din_re;
output o_dcycle_we;
output o_config_we;

reg [5:0] decoder_o;

assign o_ram_we = (i_we & decoder_o[0]);
assign o_ddir_we = (i_we & decoder_o[1]);
assign o_dout_we = (i_we & decoder_o[2]);
assign o_din_re = (i_we & decoder_o[3]);
assign o_dcycle_we = (i_we & decoder_o[4]);
assign o_config_we = (i_we & decoder_o[5]);

always @(*) begin
	// Start initialization:
	decoder_o = {6{1'b0}};

	casez(i_address[7:0]) 
		8'b0???????: decoder_o = 6'b000001;	// RAM_ADDR | RAM address range - [127:0], JUST CHECKING INPUT ADDRESS, 127 = 0b1111111
		8'b10000000: decoder_o = 6'b000010;	// GPIO_DDIR | [128] - DDIR, 128 = 0b10000000
		8'b10000001: decoder_o = 6'b000100;	// GPIO_DOUT | [129] - DOUT, 129 = 0b10000001
		8'b10000010: decoder_o = 6'b001000;	// GPIO_DIN | [130] - DIN, 130 = 0b10000010
		8'b10000011: decoder_o = 6'b010000;	// BAM_DCYCLE | [131] - 32-bit DCYCLE register for BAM module, 131 = 0b10000011
		8'b10000100: decoder_o = 6'b100000;	// BAM_CONFIG | [132] - 32-bit CONFIG register for BAM module, 132 = 0b10000100

		default: 
			begin
				decoder_o = {6{1'b0}};
			end
	endcase
end
endmodule

