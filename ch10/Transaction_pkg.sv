package Transaction_pkg;

	`include "opcodes_include.v"

	class Transaction;

		rand bit [3:0] opcode;
		rand bit [1:0] src, dst;
		rand bit [7:0] address;

		// bit [7:0] instr = {opcode, src, dst};
		bit [7:0] instr;

		bit [7:0] data = 8'hFF;

		constraint allowed_opcode_values {
			(opcode == NOP) ||
			(opcode == ADD) ||
			(opcode == SUB) ||
			(opcode == AND) ||
			(opcode == NOT) ||
			(opcode == RD) ||
			(opcode == WR) ||
			(opcode == RDI);
		}

		function void post_randomize();
			instr = {this.opcode, this.src, this.dst};
		endfunction : post_randomize

	endclass : Transaction

endpackage : Transaction_pkg