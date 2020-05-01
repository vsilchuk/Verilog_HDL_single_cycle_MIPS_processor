// Module: ALU.v
// Project: Single-cycle MIPS processor in Verilog HDL.	
// Description: Arithmetic logic unit.
// Author: github.com/vsilchuk

module ALU(i_data_A, i_data_B, i_alu_control, o_zero_flag, o_result);

input [31:0] i_data_A;					// A operand 
input [31:0] i_data_B;					// B operand
output reg [31:0] o_result;				// ALU result
input [3:0] i_alu_control;				// Control signal

output wire o_zero_flag;				// Zero flag 
assign o_zero_flag = ~|o_result;

/*wire ovflw_add;
wire ovflw_sub;*/

reg [31:0] i_shifter_data;
reg [2:0] i_shift_mode;
reg [4:0] i_shift_cnt;
wire [31:0] o_shifted_data; 

barrel_shifter bs_inst(.i_data(i_shifter_data),
			.i_mode(i_shift_mode),
			.i_shift_count(i_shift_cnt),
			.o_data(o_shifted_data));

/* 	TO DO: add classic implementation of SLT instruction (by subtraction), 
	maybe also add an implementation of arithmetic instructions ADD and SUB by XOR	*/

/*
wire[31:0] B = i_data_B ^ {32{i_arith_op}};
wire [32:0] sum = i_data_A + B + i_arith_op;
//wire overlow = sum[32];
wire overlow = sum[32] & is_signed;	// is_signed 
*/


always @(*) begin
	// Start initialization:
	i_shifter_data = {32{1'bx}};
	i_shift_mode = {3{1'bx}};
	i_shift_cnt = {5{1'bx}};
	
	casex(i_alu_control)
		4'b0010:	// ADD
			begin
				o_result = i_data_A + i_data_B;
			end
		4'b0110:	// SUB
			begin
				o_result = i_data_A - i_data_B;
			end
		4'b0000:	// AND
			begin
				o_result = i_data_A & i_data_B;
			end
		4'b0001:	// OR 
			begin
				o_result = i_data_A | i_data_B;
			end
		4'b0111:	// SLT
			begin
				o_result = i_data_A < i_data_B ? 32'h00000001 : 32'h00000000;	
			end
		4'b0011:	// XOR 
			begin
				o_result = i_data_A ^ i_data_B;
			end
		4'b0100:	// NOR
			begin
				o_result = ~(i_data_A | i_data_B);
			end
		4'b1000:	// SLL, Shift Left Logical
			begin
				i_shifter_data = i_data_B;
				i_shift_mode = 3'b000;
				i_shift_cnt = i_data_A[4:0];	// first 5 digits (LSB) of input data A - are the Shift amount field of Instruction (10:6)
		
				o_result = o_shifted_data;		
			end
		4'b1001:	// SRL, Shift Right Logical
			begin
				i_shifter_data = i_data_B;
				i_shift_mode = 3'b001;
				i_shift_cnt = i_data_A[4:0];	
		
				o_result = o_shifted_data;	
			end
		4'b1010:	// SRA, Shift Right Arithmetic
			begin
				i_shifter_data = i_data_B;
				i_shift_mode = 3'b100;
				i_shift_cnt = i_data_A[4:0];	
		
				o_result = o_shifted_data;	
			end
		4'b1011:	// ROR, Rotate Right (Cyclic Right)
			begin
				i_shifter_data = i_data_B;
				i_shift_mode = 3'b011;
				i_shift_cnt = i_data_A[4:0];
		
				o_result = o_shifted_data;	
			end
		4'b1100:	// ROL, Rotate Left (Cyclic Left)
			begin
				i_shifter_data = i_data_B;
				i_shift_mode = 3'b010;
				i_shift_cnt = i_data_A[4:0];	
		
				o_result = o_shifted_data;	
			end
			
		default:
			begin
				o_result = {32{1'bx}};	// x-state, (nor 1, nor 0)
			end
	endcase
end
endmodule

