## Single-cycle MIPS processor in Verilog HDL.

###### NTUU KPI, The Faculty of Electronics, The Department of Design of Electronic Digital Equipment (DEDEC/KEOA).

My implementation of a single-cycle [MIPS processor][1] in Verilog HDL, created according to the general principles described in the book **"Digital Design and Computer Architecture"** by David Harris and Sarah Harris.

Refer to this book for a better understanding of how this code works.

I used the **ModelSim** simulation environment to simulate the operation of the designed device.
In my case, the simulation could be started by executing the `vsim -do sim.do` command using the terminal. You can also directly transfer the script to be executed by the simulator using the graphical interface of the program.

#### Supported instructions:

+ ADD
+ SUB
+ AND
+ OR
+ SLT
+ XOR
+ NOR
+ SLL
+ SLR
+ SRA
+ ROR
+ ROL
+ LW
+ SW
+ BEQ
+ BNE
+ ADDI
+ SLTI
+ ANDI
+ ORI
+ XORI
+ J

#### Instructions and their conversion:

You can use the [MARS simulator][2] to test the operation of code written in the MIPS assembler language.

After that, you can manually convert the assembler listing instructions to 32-bit machine code instructions, and then add them to the binary file — `instr_test_mips_bam.bin` — that will be read by the processor instruction memory module.

For such conversions as “instruction-code” and “code-instruction”, you can use [this site][3].

#### An example of converting an assembler instruction into machine code:

+ The symbolic names of the processor registers:

	| Name | Number | Purpose | 
	|------|--------|---------|
	| $0 | 0 | constant 0 (read only) |
	| $at | 1 | assembler temporary variable | 
	| $v0-$v1 | 2-3 | procedure return values | 
	| $a0-$a3 | 4-7 | procedure arguments | 
	| $t0-$t7 | 8-15 | temporary variables | 
	| $s0-$s7 | 16-23 | stored variables | 
	| $t8-$t9 | 24-25 | temporary variables | 
	| $k0-$k1 | 26-27 | temporary values of the operating system | 
	| $gp | 28 | global pointer | 
	| $sp | 29 | stack pointer | 
	| $fp | 30 | stack frame pointer | 
	| $ra | 31 | procedure return address | 

+ The structure of machine codes for processor instructions — [MIPS instructions formats][5]:

	![MIPS instructions formats](https://github.com/vsilchuk/Verilog_HDL_single_cycle_MIPS_processor/blob/master/img/mips_instructions_formats.png "MIPS instructions formats")

---

+ An example of an instruction in the form that is suitable for simulation in the MARS simulator:

	|`addi $3, $0, 12`|# initialize $3 = 12|
	|-----------------|--------------------|


+ The same instruction with symbolic register names, in the form that is suitable for the [converter][3]:

	|`addi $v1 $zero 0xC`|# initialize $3 = 12|
	|--------------------|--------------------|

+ ADDI intstruction format: 

	`ADDI rt, rs, immediate [I-type]`

+ The machine code structure for this instruction:

	**I-type instruction:**

	|31...26|25...21|20...16|15...0|
	|-------|-------|-------|------|
	|op|rs|rt|immediate|
	|6 bits|5 bits|5 bits|16 bits|

	OP — opcode — operation code. The opcode for the ADDI I-type instruction is `001000` in binary. See the Opcodes table [here][4].

	|31...26|25...21|20...16|15...0|
	|-------|-------|-------|------|
	|`ADDI op`|`zero`|`$v1`|`immediate`|
	|`001000`|`00000`|`00011`|`0000000000001100`|
	|6 bits|5 bits|5 bits|16 bits|

+ The same instruction in machine code — result:

	Binary: `00100000000000110000000000001100`
	
	Hexadecimal: `0x2003000C`
	
+ [MIPS instruction converter][3] usage example:

	![MIPS converter](https://github.com/vsilchuk/Verilog_HDL_single_cycle_MIPS_processor/blob/master/img/mips_converter.PNG "MIPS converter")

---

+ Processor structure:

	![Processor structure](https://github.com/vsilchuk/Verilog_HDL_single_cycle_MIPS_processor/blob/master/img/proc_structure_wb.png "Processor structure")

	**Note** that in this implementation, the **data memory** module is implemented as part of the **address space** module, and that there is a BAM module here.

	"Pure" single-cycle MIPS as in this photo is [here][6].


[1]: https://en.wikipedia.org/wiki/MIPS_architecture
[2]: http://courses.missouristate.edu/kenvollmar/mars/
[3]: https://www.eg.bucknell.edu/~csci320/mips_web/
[4]: https://opencores.org/projects/plasma/opcodes
[5]: http://db.cs.duke.edu/courses/cps104/fall98/lectures/week8-l1/sld005.htm
[6]: https://github.com/vsilchuk/Verilog_HDL_university_tasks/tree/master/LW8
