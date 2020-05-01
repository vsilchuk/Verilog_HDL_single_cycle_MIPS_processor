// Module: clk_prescaler.v
// Project: Single-cycle MIPS processor in Verilog HDL.	
// Description: Dividing input clock frequency using counter and generating clock_enable singal for future clock gating.
// Author: github.com/vsilchuk

module clk_prescaler(i_clk, i_arst, i_on, i_divide_by, o_clk_enable);

input i_clk;							// CLOCK_50, 50MHz system clock on Altera DE2 FPGA board, for example
input i_arst;							// Reset signal
input i_on;							// Count & work enable signal from CONFIG.ON bit (CONFIG[0])
input [6:0] i_divide_by;					// By 1, 2, 4, 8, 16, 32, 64 or 128
output o_clk_enable;						// Output "allow CLK" signal for clock gating

reg [6:0] counter;						// 128 possible states, counting from 0 to 127 - main counter		
reg [6:0] buffer;						// Buffer for input divide value (i_divide_by)			

assign o_clk_enable = (i_on & (counter == buffer));		// Output signal generation

always @(posedge i_clk, posedge i_arst, negedge i_on) begin
	if(i_arst) begin
		buffer <= {7{1'b0}};				// Clear buffer after reset
	end else if(~i_on) begin
		buffer <= {7{1'b0}};				// Clear buffer, if i_on == 0
	end else begin
		buffer <= i_divide_by;				// Save current i_divide_by value into the buffer
	end
end

wire is_not_changed;
assign is_not_changed = (buffer == i_divide_by);		// Checking the change of i_divide_by value between the edges of the i_clk signal
																
reg is_not_changed_state;					// We need to save is_not_changed change event to the flip-flop

always @(negedge is_not_changed) begin			
	is_not_changed_state <= 1'b1;
	counter <= {7{1'b0}};					// If we want to clear the counter immediately after the change of i_divide_by value, between the edges of i_clk
end				

always @(posedge i_clk, posedge i_arst, negedge i_on) begin
	if(i_arst) begin
		counter <= {7{1'b0}};
	end else if(~i_on) begin
		counter <= {7{1'b0}};				// Immediately cleaning of counter after the negative edge of the i_on input signal
	end else if(is_not_changed_state) begin		
		counter <= {7{1'b0}};			
		is_not_changed_state <= 1'b0;		
	end else begin
		if(o_clk_enable) begin			
			counter <= {7{1'b0}};
		end else begin
			if(i_on) begin				// To prevent useless counter iteration
				counter <= counter + 1'b1;	// Iteration only when posedge i_clk and i_on == 1 at the same time
			end else begin
				counter <= {7{1'b0}};		// If i_on != 1, we should clean counter 
			end
		end
	end
end
endmodule

