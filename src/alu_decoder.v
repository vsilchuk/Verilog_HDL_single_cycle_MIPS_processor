// Module: alu_decoder.v
// Project: Single-cycle MIPS processor in Verilog HDL.	
// Description: ALU Control module for MIPS.
//		The main task is to generate ALUControl signal, which depends on OPcode and Function fields of Instruction.
// Author: github.com/vsilchuk

module alu_decoder(i_opcode, i_funct, o_shift, o_alu_control);

input [5:0] i_opcode;		// OPcode field of Instruction (31:26)
input [5:0] i_funct;		// Function field of Instruction (5:0) for R-type instructions
output reg o_shift;
output reg [3:0] o_alu_control;	// ALU Control signal

always @(*) begin 
	// Start initialization:
	o_alu_control = 4'bxxxx;	// undefined state (nor 1, nor 0)
	o_shift = 1'bx;
	
	casez(i_opcode)
		6'b000000:	// R-type instructions, - will watch at funct [5:0]
			begin
				casez(i_funct)
					6'b100000:	
						begin	
							o_alu_control = 4'b0010; // ADD
							o_shift = 1'b0;
						end 
					6'b100010:	
						begin	
							o_alu_control = 4'b0110; // SUB
							o_shift = 1'b0;
						end
					6'b100100:	
						begin
							o_alu_control = 4'b0000; // AND
							o_shift = 1'b0;
						end
					6'b100101:	
						begin	
							o_alu_control = 4'b0001; // OR 
							o_shift = 1'b0;
						end
					6'b101010:	
						begin	
							o_alu_control = 4'b0111; // SLT
							o_shift = 1'b0;
						end
					6'b100110:	
						begin	
							o_alu_control = 4'b0011; // XOR - MY OWN CODE --> UNEXPECTED BEHAVIOUR
							o_shift = 1'b0;
						end
					6'b100111:	
						begin	
							o_alu_control = 4'b0100; // NOR - MY OWN CODE --> UNEXPECTED BEHAVIOUR
							o_shift = 1'b0;
						end
					6'b000000:									// Shifts:
						begin
							o_alu_control = 4'b1000; // SLL, Shift Left Logical
							o_shift = 1'b1;
						end
					6'b000010:
						begin
							o_alu_control = 4'b1001; // SRL, Shift Right Logical
							o_shift = 1'b1;
						end
					6'b000011:	
						begin
							o_alu_control = 4'b1010; // SRA, Shift Right Arithmetic
							o_shift = 1'b1;
						end
					6'b000101:	
						begin
							o_alu_control = 4'b1011; // ROR, Rotate Right (Cyclic Right) - 2'b000101 - MY OWN CODE --> UNEXPECTED BEHAVIOUR
							o_shift = 1'b1;
						end
					6'b001001:	
						begin
							o_alu_control = 4'b1100; // ROL, Rotate Left (Cyclic Left) - 2'b001001 - - MY OWN CODE --> UNEXPECTED BEHAVIOUR
							o_shift = 1'b1;
						end
					
					/*	i_funct field values for ROR and ROL are my own, and aren't taken from official instruction set documents, 
						so you must add to instruction memory custom instructions codes for this instructions	*/
						
					default: 	
						begin
							o_alu_control = 4'bxxxx; // default value - undefined state (nor 1, nor 0)
							o_shift = 1'bx;
						end
				endcase	
			end
		6'b100011:	// LW
			begin
				o_alu_control = 4'b0010;	// ADD 
				o_shift = 1'b0;
			end
		6'b101011:	// SW
			begin
				o_alu_control = 4'b0010;	// ADD 
				o_shift = 1'b0;
			end
		6'b000100:	// BEQ
			begin
				o_alu_control = 4'b0110;	// SUB
				o_shift = 1'b0;
			end
		6'b000101:	// BNE
			begin
				o_alu_control = 4'b0110;	// SUB
				o_shift = 1'b0;
			end
		6'b001000:	// ADDI
			begin
				o_alu_control = 4'b0010;	// ADD 
				o_shift = 1'b0;
			end
		6'b001010:	// SLTI
			begin
				o_alu_control = 4'b0111;	// SLT
				o_shift = 1'b0;
			end
		6'b001100:	// ANDI
			begin
				o_alu_control = 4'b0000;	// AND
				o_shift = 1'b0;
			end
		6'b001101:	// ORI
			begin
				o_alu_control = 4'b0001;	// OR 
				o_shift = 1'b0;
			end
		6'b001110:	// XORI
			begin
				o_alu_control = 4'b0011;	// XOR
				o_shift = 1'b0;
			end
		6'b000010:	// J
			begin
				o_alu_control = 4'bxxxx;	// undefined state (nor 1, nor 0)
				o_shift = 1'b0;
			end
		default:	// default state
			begin
				o_alu_control = 4'bxxxx;	// undefined state (nor 1, nor 0)
				o_shift = 1'bx;
			end
	endcase
end
endmodule
		
