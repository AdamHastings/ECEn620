package CovPort_pkg;

	`include "opcodes_include.v"
	import Transaction_pkg::*;
	import Driver_pkg::*;

	//Transaction #(ADDRESS_WIDTH) drv_tr;

	covergroup CovPort (int ADDRESS_WIDTH);
		non_ctrl_opcodes : coverpoint $root.top.t0.drv_tr.opcode {
			option.comment = "All opcodes have been executed, except BR, BRZ, and HALT";
			bins nop_bin = {NOP};
			bins add_bin = {ADD};
			bins sub_bin = {SUB};
			bins and_bin = {AND};
			bins not_bin = {NOT};
			bins rd_bin  = {RD};
			bins wr_bin  = {WR};
			bins rdi_bin = {RDI};
			bins misc = default;
		}

		src_opcodes : coverpoint $root.top.t0.drv_tr.opcode {
			option.comment = "The source for every opcode that has a source has been R0, R1, R2, and R3";
			bins add_bin = {ADD};
			bins sub_bin = {SUB};
			bins and_bin = {AND};
			bins not_bin = {NOT};
			bins wr_bin  = {WR};
			bins misc = default;
	
		}

		dst_opcodes : coverpoint $root.top.t0.drv_tr.opcode {
			option.comment = "The destination for every opcode that has a source has been R0, R1, R2, and R3";
			bins add_bin = {ADD};
			bins sub_bin = {SUB};
			bins and_bin = {AND};
			bins not_bin = {NOT};
			bins rd_bin = {RD};
			bins rdi_bin  = {RDI};
			bins misc = default;		
		}

		transition_permutations : coverpoint $root.top.t0.drv_tr.opcode {
			option.comment = "Every opcode has been preceded and followed by every other instruction.";
			bins t1[] = (NOP, ADD, SUB, AND, NOT, RD, WR, RDI => NOP, ADD, SUB, AND, NOT, RD, WR, RDI);
			bins misc = default;
		}

		src_dst_opcodes : coverpoint $root.top.t0.drv_tr.opcode {
			option.comment = "For opcodes that have both a source and destination, all permutations of source and destination have been executed.";
			bins add_bin = {ADD};
			bins sub_bin = {SUB};
			bins and_bin = {AND};
			bins not_bin = {NOT};
			bins misc = default;
		}

		all_mem_written : coverpoint $root.top.t0.drv_tr.opcode {
			option.comment = "All memory locations have been written.";
			bins wr_bin = {WR};
			bins misc = default;
		}

		all_mem_read : coverpoint $root.top.t0.drv_tr.opcode {
			option.comment = "All memory locations have been read by a RD instruction.";
			bins rd_bin = {RD};
			bins misc = default;
		}

		address_cov : coverpoint $root.top.t0.drv_tr.address {
			option.auto_bin_max = 1 << (ADDRESS_WIDTH);
		}

		cross src_opcodes, $root.top.t0.drv_tr.src;
		cross dst_opcodes, $root.top.t0.drv_tr.dst;
		cross src_dst_opcodes, $root.top.t0.drv_tr.src, $root.top.t0.drv_tr.dst;
		cross all_mem_written, address_cov;
		cross all_mem_read, address_cov;

	endgroup


	class Driver_cbs_cov #(ADDRESS_WIDTH) extends Driver_cbs #(ADDRESS_WIDTH);
		CovPort ck;

		function new();
			ck = new(ADDRESS_WIDTH);
		endfunction

		virtual task pre_tx(ref Transaction #(ADDRESS_WIDTH) tr);
			$root.top.t0.drv_tr = tr;
			ck.sample();
			$display("%0d", $get_coverage());
			if ($get_coverage() == 100) $stop;
		endtask

	endclass
	
endpackage : CovPort_pkg