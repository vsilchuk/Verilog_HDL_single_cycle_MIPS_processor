// Module: sign_extender.v
// Project: Single-cycle MIPS processor in Verilog HDL.	
// Description: Sign extending 16-bit value to 32-bit 
// Author: github.com/vsilchuk

module sign_extender(i_input16, o_output32);

input wire [15:0] i_input16;
output reg [31:0] o_output32;

always @*	// always, if any signal changed
begin
	o_output32[15:0] = i_input16[15:0];
	o_output32[31:16] = {16{i_input16[15]}};

	// o_output32 = {{16{i_input16[15]}}, i_input16[15:0]};	// another variant, shorter
end 
endmodule

