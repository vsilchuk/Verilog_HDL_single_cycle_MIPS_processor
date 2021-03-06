// Module: address_space.v
// Project: Single-cycle MIPS processor in Verilog HDL.	
// Description: Module, which connects BAM, GPIO and RAM modules together in the form, allowing to use them in the single-cycle MIPS processor.
// Author: github.com/vsilchuk

module address_space(i_clk, i_we, i_arst, i_address, i_write_data, o_read_data, io_IO, bam_output);	

input i_clk;							// Input clock signal, 50MHz system clock on Altera DE2 FPGA board, for example
input i_we;							// We want to write data in the RAM, or, maybe in some other configuration registers, like GPIO or BAM registers
input i_arst;							// Reset signal
input [31:0] i_address;						// Generated by ALU
input [31:0] i_write_data;					// Input data, which will be written
output [31:0] o_read_data;					// RAM HAS AN ASYNCHONOUS READING - ONLY i_address --> assign 
inout [31:0] io_IO;						// GPIO inout 32-bit port
output bam_output;						// Output pin, which is the source of BAM signal

wire RAM_WE;
wire GPIO_DDIR_WE;
wire GPIO_DOUT_WE;
wire GPIO_DIN_RE;
wire BAM_DC_WE;
wire BAM_CFG_WE;

wire [31:0] DIN;						// Read data from GPIO
wire [31:0] o_ram_data;						// Read data from RAM
assign o_read_data = (GPIO_DIN_RE) ? DIN : o_ram_data;		// To choose between output data from RAM and output data from GPIO DIN register

wire bam_enable;						// Signals the GPIO module (i_ALT) that the BAM module generates a signal
wire bam_signal;						// Source of the BAM signal in the GPIO module (i_ALT_IN)

reg [3:0] CONFIG;						// BAM configuration register, precsaler mode and start module bit
reg [15:0] DCYCLE;						// BAM configuration register, duty cycle

always @(posedge i_clk, posedge i_arst, posedge BAM_CFG_WE, posedge BAM_DC_WE) begin
	if(i_arst) begin 
		CONFIG <= {4{1'b0}};
		DCYCLE <= {16{1'b0}};
	end else if (BAM_CFG_WE) begin
		CONFIG <= i_write_data[3:0];
	end else if(BAM_DC_WE) begin
		DCYCLE <= i_write_data[15:0];
	end else begin
		CONFIG <= CONFIG;
		DCYCLE <= DCYCLE;
	end
end

address_decoder adec_inst(.i_clk(i_clk),
				.i_we(i_we),
				.i_address(i_address),
				.o_ram_we(RAM_WE),
				.o_ddir_we(GPIO_DDIR_WE),
				.o_dout_we(GPIO_DOUT_WE),
				.o_din_re(GPIO_DIN_RE),
				.o_dcycle_we(BAM_DC_WE),
				.o_config_we(BAM_CFG_WE));

data_memory RAM_inst(.i_clk(i_clk),				// same as module in the MIPS folder
			.i_we(RAM_WE),
			.i_arst(i_arst),
			.i_address(i_address),
			.i_write_data(i_write_data),
			.o_read_data(o_ram_data));

GPIO GPIO_inst(.i_clk(i_clk),
		.i_arst(i_arst),
		.i_DATA(i_write_data),
		.i_ALT(bam_enable),
		.i_ALT_IN(bam_signal),
		.i_DDIR_WE(GPIO_DDIR_WE),
		.i_DIN_RE(GPIO_DIN_RE),
		.i_DOUT_WE(GPIO_DOUT_WE),
		.o_DIN(DIN),
		.io_IO(io_IO),
		.BAM_output(bam_output));

BAM BAM_inst(.i_clk(i_clk),
		.i_arst(i_arst),
		.i_on(CONFIG[0]),
		.i_presc_mode(CONFIG[3:1]),
		.i_duty_cycle(DCYCLE[15:0]),
		.o_bam_enable(bam_enable),
		.o_signal(bam_signal));
endmodule

