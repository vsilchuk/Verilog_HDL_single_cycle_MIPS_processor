# Delete old compilation results
if { [file exists "work"] } {
    vdel -all
}

# Create new modelsim working library

vlib work

# Compile all the Verilog sources in current folder into working library

vlog  MIPS.v testbench.v ALU.v alu_decoder.v barrel_shifter.v data_memory.v main_decoder.v program_counter.v register_file.v rom.v sign_extender.v clk_prescaler.v bam.v gpio.v address_space.v address_decoder.v

# Open testbench module for simulation
# The newest Modelsim versions are sometimes optimizing too greedily and you won't necessarily see all the signals. In those cases, just disable optimizations:

vsim -novopt work.testbench

# Add all testbench signals to waveform diagram

add wave /testbench/*
add wave -position end /testbench/MIPS_inst/BAM
add wave -position end /testbench/MIPS_inst/address_space_inst/BAM_inst/clock_enable

onbreak resume
# Run simulation
run -all
wave zoom full

