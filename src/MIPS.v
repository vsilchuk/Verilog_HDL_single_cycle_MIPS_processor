// Module: MIPS.v
// Project: Single-cycle MIPS processor in Verilog HDL.	
// Description: Single-cycle MIPS processor main module.
// Author: github.com/vsilchuk

module MIPS(i_clk, i_arst, o_instruction, o_pc_cur, o_pc_next);

input i_clk;	// clock signal
input i_arst;	// reset signal
output wire [31:0] o_instruction;
output wire [31:0] o_pc_cur;
output wire [31:0] o_pc_next;

/* Control Signals */

wire MemtoReg;
wire MemWrite;
wire Branch_beq;
wire Branch_bne;
wire [3:0] ALUControl;
wire ALUSrc;
wire RegDst;
wire RegWrite;
wire Shift;
wire Jump;
wire Zero;						// from ALU
wire PCSrc;						// combinational logic
assign PCSrc = (Branch_beq & Zero) | (Branch_bne & !Zero);

/* End of Control Signals */

reg [31:0] pc_next;					// PC'
wire [31:0] pc_current;					// PC
wire [31:0] pc_plus4;					// PC + 4
wire [31:0] pc_branch;					// PCBranch = PC + 4 + (SignedImm * 4)
wire [31:0] pc_jump;					// jump address

wire [31:0] ROM_A;					// input Address for Instruction memory
wire [31:0] Instr;					// read Instruction, from Instruction memory
assign ROM_A = pc_current;				// PC --> A

// -----------> 

	assign o_instruction = Instr;
	assign o_pc_cur = pc_current;
	assign o_pc_next = pc_next;

rom rom_inst(.i_addr(ROM_A),				/* Instruction Memory, ROM */
		.o_data(Instr));

wire [31:0] sign_imm;					// sign extended Immediate (Instr [15:0])
wire [31:0] shifted_sign_imm;					// sign_imm << 2
assign shifted_sign_imm = {sign_imm[29:0], 2'b00};	// sign_imm << 2

assign pc_plus4 = pc_current + 32'd4;			// PC + 4
assign pc_branch = pc_plus4 + shifted_sign_imm;		// PCBranch = PC + 4 + (SignedImm * 4)
// FIXING:	assign pc_branch = pc_plus4 + shifted_sign_imm;
assign pc_jump = {pc_plus4[31:28], Instr[25:0], 2'b00};	// jump address

always @(*) begin
	casex(Jump)
		1'b0:
			begin
				casex(PCSrc)
					1'b0:
						begin
							pc_next = pc_plus4;
						end
					1'b1:	
						begin
							pc_next = pc_branch;
						end
				endcase
			end
		1'b1:	
			begin
				pc_next = pc_jump;
			end
	endcase
end
							
program_counter pc_inst(.i_clk(i_clk),			/* Programm Counter */
			.i_arst(i_arst),
			.i_next_addr(pc_next),
			.o_curr_addr(pc_current));

sign_extender sign_ext_inst(.i_input16(Instr[15:0]),	/* Sign Extender */
				.o_output32(sign_imm));	

main_decoder main_control_inst(.i_opcode(Instr[31:26]), /* Main Control */
				.o_memto_reg(MemtoReg),
				.o_mem_write(MemWrite),
				.o_branch_beq(Branch_beq),
				.o_branch_bne(Branch_bne),
				.o_jump(Jump),
				.o_alu_src(ALUSrc),
				.o_reg_dst(RegDst),
				.o_reg_write(RegWrite));

alu_decoder alu_control_inst(.i_opcode(Instr[31:26]),	/* ALU Control */
				.i_funct(Instr[5:0]),
				.o_shift(Shift),
				.o_alu_control(ALUControl));

wire [4:0] REGF_A1;	
wire [4:0] REGF_A2;
reg [4:0] REGF_A3;
wire [31:0] REGF_WD3;
wire [31:0] REGF_RD1;
wire [31:0] REGF_RD2;

reg [31:0] result;		// result: controlls by MemtoReg: if = [0] -> result = alu_result, if = [1] -> result = RAM_RD

assign REGF_A1 = Instr[25:21];	// rs
assign REGF_A2 = Instr[20:16];	// rt 
assign REGF_WD3 = result;

always @(*) begin
	casex(RegDst)
		1'b0:
			begin
				REGF_A3 = Instr[20:16];	// rt 
			end
		1'b1:
			begin
				REGF_A3 = Instr[15:11];	// rd
			end
	endcase
end

register_file reg_file_inst(.i_clk(i_clk),		/* Register File */
				.i_we(RegWrite),
				.i_arst(i_arst),
				.i_addr_1(REGF_A1),
				.i_addr_2(REGF_A2),
				.i_addr_3(REGF_A3),
				.i_wdata(REGF_WD3),
				.o_rdata_1(REGF_RD1),
				.o_rdata_2(REGF_RD2));

reg [31:0] srcA;
reg [31:0] srcB;
wire [31:0] alu_result;

always @(*) begin
	casex(Shift)
		1'b0:
			begin
				srcA = REGF_RD1;
			end
		1'b1:	
			begin
				srcA = {{27{1'b0}}, Instr[10:6]};
			end
	endcase
end

always @(*) begin
	casex(ALUSrc)
		1'b0:
			begin
				srcB = REGF_RD2;
			end
		1'b1:	
			begin
				srcB = sign_imm;
			end
	endcase
end

ALU alu_inst(.i_data_A(srcA),				/* ALU */
		.i_data_B(srcB),
		.i_alu_control(ALUControl),
		.o_zero_flag(Zero),
		.o_result(alu_result));

wire [31:0] RAM_A;
wire [31:0] RAM_WD;
wire [31:0] RAM_RD;

assign RAM_A = alu_result;
assign RAM_WD = REGF_RD2;

/* Data Memory, RAM */

/*
data_memory data_memory_inst(.i_clk(i_clk),		
				.i_we(MemWrite),
				.i_arst(i_arst),
				.i_address(RAM_A),
				.i_write_data(RAM_WD),
				.o_read_data(RAM_RD));
*/

wire IO;
wire BAM;

address_space address_space_inst(.i_clk(i_clk),		
				.i_we(MemWrite),
				.i_arst(i_arst),
				.i_address(RAM_A),
				.i_write_data(RAM_WD),
				.o_read_data(RAM_RD),
				.io_IO(IO),
				.bam_output(BAM));

always @(*) begin
	casex(MemtoReg)
		1'b0: 
			begin
				result = alu_result;
			end
		1'b1:
			begin
				result = RAM_RD;
			end
	endcase
end
endmodule

