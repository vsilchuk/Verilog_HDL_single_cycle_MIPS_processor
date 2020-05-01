// Module: main_decoder.v
// Project: Single-cycle MIPS processor in Verilog HDL.	
// Description: Main Control module for MIPS. 
//		The main task is to generate control signals for each of Instruction: MemtoReg, MemWrite, Branch, Jump, ALUSrc, RegDst, RegWrite.
// Author: github.com/vsilchuk

module main_decoder(i_opcode, o_memto_reg, o_mem_write, o_branch_beq, o_branch_bne, o_jump, o_alu_src, o_reg_dst, o_reg_write);

input [5:0] i_opcode;
output reg o_memto_reg;
output reg o_mem_write;
output reg o_branch_beq;
output reg o_branch_bne;
output reg o_jump;
output reg o_alu_src;
output reg o_reg_dst;
output reg o_reg_write;

always @(i_opcode) begin
	// Start initialization of control signals:
	o_reg_write = 1'bx;
	o_reg_dst = 1'bx;
	o_alu_src = 1'bx;
	o_branch_beq = 1'bx;
	o_branch_bne = 1'bx;
	o_mem_write = 1'bx;
	o_memto_reg = 1'bx;
	o_jump = 1'bx;
	//o_alu_op = 2'bxx;	// undefined state (nor 1, nor 0)

	casez(i_opcode)
		6'b000000:	// R-type: ADD, SUB, AND, OR, SLT, XOR, NOR, [Added]: SLL, SRL, SRA, ROR, ROL
			begin
				o_reg_write = 1'b1;	
				o_reg_dst = 1'b1;
				o_alu_src = 1'b0;
				o_branch_beq = 1'b0;
				o_branch_bne = 1'b0;
				o_mem_write = 1'b0;
				o_memto_reg = 1'b0;
				o_jump = 1'b0;
				//o_alu_op = 2'b10;	// will watch at funct [5:0]
			end
		6'b100011:				// LW, load word
			begin
				o_reg_write = 1'b1;
				o_reg_dst = 1'b0;
				o_alu_src = 1'b1;
				o_branch_beq = 1'b0;
				o_branch_bne = 1'b0;
				o_mem_write = 1'b0;
				o_memto_reg = 1'b1;
				o_jump = 1'b0;
				//o_alu_op = 2'b00;	// will do ADD instruction
			end
		6'b101011:				// SW, store word
			begin
				o_reg_write = 1'b0;
				o_reg_dst = 1'bx;
				o_alu_src = 1'b1;
				o_branch_beq = 1'b0;
				o_branch_bne = 1'b0;
				o_mem_write = 1'b1;
				o_memto_reg = 1'bx;
				o_jump = 1'b0;
				//o_alu_op = 2'b00;	// will do ADD instruction
			end
		6'b000100:				// BEQ, branch if equal
			begin
				o_reg_write = 1'b0;
				o_reg_dst = 1'bx;
				o_alu_src = 1'b0;
				o_branch_beq = 1'b1;
				o_branch_bne = 1'b0;
				o_mem_write = 1'b0;
				o_memto_reg = 1'bx;
				o_jump = 1'b0;
				//o_alu_op = 2'b01;	// will do SUB instruction
			end
		6'b000101:				// BNE, branch if not equal
			begin
				o_reg_write = 1'b0;
				o_reg_dst = 1'bx;
				o_alu_src = 1'b0;
				o_branch_beq = 1'b0;
				o_branch_bne = 1'b1;
				o_mem_write = 1'b0;
				o_memto_reg = 1'bx;
				o_jump = 1'b0;
				//o_alu_op = 2'b01;	// will do SUB instruction
			end
		6'b001000:				// ADDI, add with an immediate
			begin
				o_reg_write = 1'b1;
				o_reg_dst = 1'b0;
				o_alu_src = 1'b1;
				o_branch_beq = 1'b0;
				o_branch_bne = 1'b0;
				o_mem_write = 1'b0;
				o_memto_reg = 1'b0;
				o_jump = 1'b0;
				//o_alu_op = 2'b00;	// will do ADD instruction
			end
		6'b001010:				// SLTI, set less than with an immediate
			begin
				o_reg_write = 1'b1;	// we will write to Register File
				o_reg_dst = 1'b0;	// destination register is in RT field of the instruction Instr (20:16)
				o_alu_src = 1'b1;	// we will use immediate 
				o_branch_beq = 1'b0;	// not branch
				o_branch_bne = 1'b0;
				o_mem_write = 1'b0;	// we will not write to memory
				o_memto_reg = 1'b0;	// result is forming using ALU - we don't use Data Memory to read it from
				o_jump = 1'b0;		// not jump
			end
		6'b001100:				// ANDI, logic operation AND with an immediate
			begin
				o_reg_write = 1'b1;
				o_reg_dst = 1'b0;
				o_alu_src = 1'b1;
				o_branch_beq = 1'b0;
				o_branch_bne = 1'b0;
				o_mem_write = 1'b0;
				o_memto_reg = 1'b0;
				o_jump = 1'b0;
			end
		6'b001101:				// ORI, logic operation OR with an immediate
			begin
				o_reg_write = 1'b1;
				o_reg_dst = 1'b0;
				o_alu_src = 1'b1;
				o_branch_beq = 1'b0;
				o_branch_bne = 1'b0;
				o_mem_write = 1'b0;
				o_memto_reg = 1'b0;
				o_jump = 1'b0;
			end
		6'b001110:				// XORI, logic operation XOR with an immediate
			begin
				o_reg_write = 1'b1;
				o_reg_dst = 1'b0;
				o_alu_src = 1'b1;
				o_branch_beq = 1'b0;
				o_branch_bne = 1'b0;
				o_mem_write = 1'b0;
				o_memto_reg = 1'b0;
				o_jump = 1'b0;
			end
		6'b000010:				// J, jump
			begin
				o_reg_write = 1'b0;
				o_reg_dst = 1'bx;
				o_alu_src = 1'bx;
				o_branch_beq = 1'bx;
				o_branch_bne = 1'bx;
				o_mem_write = 1'b0;
				o_memto_reg = 1'bx;
				o_jump = 1'b1;
				//o_alu_op = 2'bxx;	// undefined state (nor 1, nor 0)
			end
		default:	
			begin
				o_reg_write = 1'bx;
				o_reg_dst = 1'bx;
				o_alu_src = 1'bx;
				o_branch_beq = 1'bx;
				o_branch_bne = 1'bx;
				o_mem_write = 1'bx;
				o_memto_reg = 1'bx;
				o_jump = 1'bx;
				//o_alu_op = 2'bxx;	
			end
	endcase
end
endmodule

