// Module: bam.v
// Project: Single-cycle MIPS processor in Verilog HDL.	
// Description: Generating binary angle modulated signal.
// Author: github.com/vsilchuk

module BAM(i_clk, i_arst, i_on, i_presc_mode, i_duty_cycle, o_bam_enable, o_signal);

input i_clk;							// Input clock signal, 50MHz system clock on Altera DE2 FPGA board, for example
input i_arst;							// Reset
input i_on;							// CONFIG[0]
input [2:0] i_presc_mode;					// CONFIG[3:1]
input [15:0] i_duty_cycle;					// DCYCLE[15:0] - input value of duty cycle. DUTY CYCLE CAN BE 0%!
output o_bam_enable;						// Signaling that the module is working - if CONFIG[0] == 1.
output o_signal;						// Output binary angle modulated signal

wire clock_enable;						// Output signal from clk_prescaler module, which will be used for clock gating

reg [15:0] counter;						// Main counter 
reg [3:0] current_bit;						// Counter for moving through indexes of duty_cycle bits, from 0 to 15

assign o_bam_enable = i_on;					// Will be used in GPIO to change output signal select

assign o_signal = ((i_duty_cycle[current_bit]) & i_on) ? 1'b1 : 1'b0;

/*	
**	Input clock prescale - i_presc_mode - select bits:	
**	111 = 1:128 prescale 
**	110 = 1:64 prescale
**	101 = 1:32 prescale
**	100 = 1:16 prescale
**	011 = 1:8 prescale
**	010 = 1:4 prescale
**	001 = 1:2 prescale
**	000 = 1:1 prescale
*/

wire [6:0] divide_by;
assign divide_by = 2**i_presc_mode - 1;

reg [2:0] divide_by_buff;

always @(posedge i_clk, posedge i_arst, negedge i_on) begin				
	if(i_arst) begin
		divide_by_buff <= {3{1'b0}};			// Default state after Reset signal, all bits equal to "0".
	end else if(~i_on) begin
		divide_by_buff <= {3{1'b0}};
	end else begin
		divide_by_buff <= divide_by;			// Saved!
	end
end

wire divide_by_state;							
assign divide_by_state = (divide_by_buff == divide_by);		// Is current "divide by" value actual?
	
clk_prescaler prescaler_inst(.i_clk(i_clk),
				.i_arst(i_arst),
				.i_on(i_on),
				.i_divide_by(divide_by),
				.o_clk_enable(clock_enable));

wire [15:0] max_cnt;						// Max value for counting for current bit: 256, 128, 64, etc.
assign max_cnt = 2**current_bit;

wire max_cnt_rst;						// Signal to move to the next duty_cycle bit
assign max_cnt_rst = (counter == max_cnt);			// [Or = (counter == (max_cnt - 1));] | Yeah, we can simplify it as "counter == (2**current_bit)", but I want to have both this variables 

reg [15:0] duty_cycle_buff;					// Duty cycle buffer. [i_value_buffer]
		
always @(posedge i_clk, posedge i_arst, negedge i_on) begin				
	if(i_arst) begin
		duty_cycle_buff <= {16{1'b0}};			// Default state after Reset signal, all bits equal to "0". DUTY CYCLE CAN BE 0%!
	end else if(~i_on) begin
		duty_cycle_buff <= {16{1'b0}};
	end else begin
		duty_cycle_buff <= i_duty_cycle;		// Saved!
	end
end

wire duty_cycle_state;
assign duty_cycle_state = (duty_cycle_buff == i_duty_cycle);	// Is current input value of duty cycle actual?

always @(posedge i_clk, posedge i_arst, negedge i_on, posedge max_cnt_rst, negedge duty_cycle_state, negedge divide_by_state) begin
	if(i_arst) begin
		counter <= {16{1'b0}};
	end else if(~i_on) begin
		counter <= {16{1'b0}};				// Counter will be cleaned always when i_on == 0
	end else if(max_cnt_rst) begin
		counter <= {16{1'b0}};
	end else if(~duty_cycle_state) begin
		counter <= {16{1'b0}};				// Clear our main counter, if the duty cycle value has changed
	end else if(~divide_by_state) begin
		counter <= {16{1'b0}};
	end else begin
		if(clock_enable) begin
			counter <= counter + 1'b1;
		end else begin
			counter <= counter;			// Just save the state
		end
	end
end

always @(posedge i_clk, posedge i_arst, negedge i_on, posedge max_cnt_rst, negedge duty_cycle_state, negedge divide_by_state) begin		
	if(i_arst) begin
		current_bit <= {4{1'b1}};			// 15 in decimal, 0b1111 in binary
	end else if(~i_on) begin
		current_bit <= {4{1'b1}};
	end else if(~duty_cycle_state) begin
		current_bit <= {4{1'b1}};			// Clear bit index counter, if the duty cycle value has changed
	end else if(~divide_by_state) begin
		current_bit <= {4{1'b1}};			// Clear bit index counter, if the "divide by" value has changed
	end else begin
		if(max_cnt_rst) begin
			current_bit <= current_bit - 1'b1;	// Moving to the next digit (bit) after overflow
		end else begin
			current_bit <= current_bit;		// Just save the state
		end
	end
end
endmodule

