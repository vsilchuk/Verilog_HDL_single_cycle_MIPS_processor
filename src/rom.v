// Module: rom.v
// Project: Single-cycle MIPS processor in Verilog HDL.	
// Description: Read-Only memory module.
// Author: github.com/thodnev | github.com/vsilchuk

`define ROM_FILE  "instr_test_mips_bam.bin"

`ifndef __ROM__
`define __ROM__
module rom(i_addr, o_data);
parameter DATA_WIDTH=32, ADDR_WIDTH=32;
parameter ROM_BLOCKS_NUM = 2**10;	// 2**5 by @thodnev
parameter [DATA_WIDTH-1:0] ROM_DEFLT_DATA = {DATA_WIDTH{1'b0}};
parameter [ADDR_WIDTH-1:0] ROM_END_ADDR = ROM_BLOCKS_NUM;	// ROM_BLOCKS_NUM*ADDR_WIDTH; by @thodnev

input [ADDR_WIDTH-1:0] i_addr;
output reg [DATA_WIDTH-1:0] o_data;

reg [DATA_WIDTH-1:0] rom_mem [ROM_BLOCKS_NUM-1:0];	// [0:ROM_BLOCKS_NUM-1]; by @thodnev

// load memory contents from file
initial begin : INIT
  integer i;
  for (i=0; i<ROM_BLOCKS_NUM; i=i+1) begin
    rom_mem[i] = ROM_DEFLT_DATA;
  end
  $readmemh(`ROM_FILE, rom_mem);			// $readmemh(`ROM_FILE, rom_mem);
end

// read logic
always @(i_addr) begin
  if (i_addr > ROM_END_ADDR) 
          o_data = ROM_DEFLT_DATA;
  else
          o_data = rom_mem[i_addr];
end

endmodule
`endif

