// Module: GPIO.v
// Project: Single-cycle MIPS processor in Verilog HDL.	
// Description: GPIO module.
// Author: github.com/vsilchuk

module GPIO(i_clk, i_arst, i_DATA, i_ALT, i_ALT_IN, i_DDIR_WE, o_DIN, i_DIN_RE, i_DOUT_WE, io_IO, BAM_output);

input i_clk;		// system clock input for registers synchr.
input i_arst;		// clear data in registers
input [31:0] i_DATA;	// data input from ALU
input i_ALT;		// enable flag for alternative data source for output mode 
input i_ALT_IN;		// alternative data source for output - BAM signal
input i_DDIR_WE;	// we'll write in the DDIR register
output reg [31:0] o_DIN;// read data to MIPS
input i_DIN_RE;		// we'll read data	
input i_DOUT_WE;	// we'll write to the DOUT register
inout [31:0] io_IO;	//

output BAM_output;
assign BAM_output = (i_ALT) ? i_ALT_IN : 1'bz;					// i'm sorry :'(

reg [31:0] DDIR;	// 1 - io_IO <=> i_DOUT, 0 - tri-state
reg [31:0] DOUT;	// write data to the DOUT register

genvar g_cnt;		// generateblock counter variable
generate 
	for(g_cnt = 0; g_cnt < 32; g_cnt = g_cnt + 1) begin: GPIO_z
		assign io_IO[g_cnt] = (DDIR[g_cnt]) ? DOUT[g_cnt] : 1'bz;	// tri-state buffers behaviour
/*
		if(i_ALT) begin
			assign io_IO[g_cnt] = i_ALT_IN[g_cnt];
		end else begin
			if(DDIR[g_cnt]) begin
				assign io_IO[g_cnt] = DOUT[g_cnt];
			end else begin
				assign io_IO[g_cnt] = 1'bz;
		end
	end
*/
end
endgenerate

always @(posedge i_clk, posedge i_arst) begin		// DDIR behaviour
	if(i_arst) begin
		DDIR <= 32'd0;
	end else begin
		if(i_DDIR_WE) begin
			DDIR <= i_DATA;
		end else begin
			DDIR <= DDIR;
		end
	end
end

/*
always @(posedge i_clk, posedge i_arst) begin		// DOUT behaviour
	if(i_arst) begin
		DOUT <= 32'd0;
	end else begin
		if(i_DOUT_WE) begin
			DOUT <= i_DATA;
		end else begin
			DOUT <= DOUT;
		end
	end
end

always @(posedge i_clk, posedge i_arst) begin		// DIN behaviour
	if(i_arst) begin
		o_DIN <= 32'd0;
	end else begin
		if(i_DIN_RE) begin
			o_DIN <= io_IO;
		end else begin
			o_DIN <= o_DIN;
		end
	end
end
endmodule 
*/


always @(posedge i_clk, posedge i_arst) begin		// DOUT behaviour
	if(i_arst) begin
		DOUT <= 32'd0;
	end else begin
		if(i_DOUT_WE) begin
			DOUT <= i_DATA;
		end else begin
			DOUT <= DOUT;
		end
	end
end

always @(posedge i_clk, posedge i_arst) begin		// DIN behaviour
	if(i_arst) begin
		o_DIN <= 32'd0;
	end else begin
		if(i_DIN_RE) begin
			o_DIN <= io_IO;
		end else begin
			o_DIN <= o_DIN;
		end
	end
end
endmodule 

/*
always @(posedge i_clk, posedge i_arst) begin		// DOUT behaviour
	if(i_arst) begin
		DOUT <= 32'd0;
	end else begin
		if(i_DOUT_WE) begin
			if(i_ALT) begin
				DOUT <= i_ALT_IN;	// alternative BAM signal output to IO[0]
			end else begin
				DOUT <= i_DATA;
			end
		end else begin
			DOUT <= DOUT;
		end
	end
end

always @(posedge i_clk, posedge i_arst) begin		// DIN behaviour
	if(i_arst) begin
		o_DIN <= 32'd0;
	end else begin
		if(i_DIN_RE) begin
			o_DIN <= io_IO;
		end else begin
			o_DIN <= o_DIN;
		end
	end
end
endmodule 
*/

/*	Last version:	*/
/*
always @(posedge i_clk, posedge i_arst) begin		// DOUT behaviour
	if(i_arst) begin
		DOUT <= 32'd0;
	end else begin
		if(i_ALT) begin
			DOUT <= i_ALT_IN;		// alternative BAM signal output to IO[0]s
		end else begin
			if(i_DOUT_WE) begin
				DOUT <= i_DATA;
			end else begin
				DOUT <= DOUT;
			end
		end
	end
end
*/

