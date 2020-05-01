// Module: barrel_shifter.v
// Project: Single-cycle MIPS processor in Verilog HDL.	
// Description: Barrel shifter: 32 bit, shifting left and right, logical and cyclic shift.
// Author: github.com/vsilchuk

// Modes: logical left [000], logical right [001], cyclic left [010], cyclic right [011].
// [Added, 17.11]: arithmetic shift, mode - [100].

// The normal shifts << and >> shift your input and pad with zeros. 
// The idea of cyclic shift by using the logical shift of concatenation of two input data vectors - by @olegovich22.
// [Added]: The arithmetic shift >>> shifts your input and pad with the sign bit.


module barrel_shifter(i_data, i_mode, i_shift_count, o_data);

input [31:0] i_data;
input [2:0] i_mode;
input [4:0] i_shift_count;
output reg [31:0] o_data;

wire [63:0] l_shifted = {i_data, i_data} << i_shift_count;
wire [63:0] r_shifted = {i_data, i_data} >> i_shift_count;

always @(*) begin
	case (i_mode)
		3'b000:
			begin
				o_data = l_shifted[31:0];				// logical left	
			end
		3'b001:
			begin
				o_data = r_shifted[63:32];				// logical right
			end
		3'b010:	
			begin							// cyclic left
				o_data = l_shifted[63:32];
			end
		3'b011:	
			begin							// cyclic right
				o_data = r_shifted[31:0];
			end
		3'b100:
			begin
				o_data = $signed(i_data) >>> i_shift_count;	// arithmetic right
			end
		default:
			begin
				o_data = {32{1'bx}};	// x-state, (nor 1, nor 0)
			end
	endcase
end
endmodule

