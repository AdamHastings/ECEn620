package env_pkg;

	`include "opcodes_include.v" 

	// Macro to check if randomization succeeded
	`define SV_RAND_CHECK(r)\
		do begin\
			if (!(r)) begin\
				$display("%s:%0d: Randomization failed \"%s\"",\
					`__FILE__, `__LINE__, `"r`");\
				$finish;\
			end\
		end while (0)


	//////////////////////////////////////////////////////////
	// Config class
	//////////////////////////////////////////////////////////

	class Config;
		int run_for_n_trans;

		function new(int count);
			this.run_for_n_trans = count;
		endfunction : new

	endclass : Config


	//////////////////////////////////////////////////////////
	// Transaction class
	//////////////////////////////////////////////////////////

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


	//////////////////////////////////////////////////////////
	// Generator class
	//////////////////////////////////////////////////////////

	class Generator;
		Transaction tr;
		mailbox #(Transaction) gen2agt;
		event gen_agt_handshake;

		function new(input mailbox #(Transaction) gen2agt, event gen_agt_handshake);
			this.gen2agt = gen2agt;
			this.gen_agt_handshake = gen_agt_handshake;
		endfunction : new

		task run();
			forever begin
				tr = new();
				`SV_RAND_CHECK(tr.randomize);
				gen2agt.put(tr);
				@gen_agt_handshake;
			end
		endtask : run

		task wrap_up();	// Empty for now
		endtask : wrap_up
		
	endclass : Generator


	//////////////////////////////////////////////////////////
	// Agent class
	//////////////////////////////////////////////////////////

	class Agent;

		mailbox #(Transaction) gen2agt, agt2drv;
		event gen_agt_handshake, agt_drv_handshake;
		Transaction tr;

		function new(input mailbox #(Transaction) gen2agt, agt2drv, event gen_agt_handshake, agt_drv_handshake);
			this.gen2agt = gen2agt;
			this.agt2drv = agt2drv;
			this.gen_agt_handshake = gen_agt_handshake;
			this.agt_drv_handshake = agt_drv_handshake;
		endfunction : new

		task run();
			forever begin
				gen2agt.get(tr);	// Get transaction from upstream block
				->gen_agt_handshake;
				// Do some processing
				// The Agent does nothing at this time except pass a transaction from the Generator to the Driver.
				agt2drv.put(tr);	// Send it to downstream block
				@agt_drv_handshake;
			end
		endtask : run

		task wrap_up();	// Empty for now
		endtask : wrap_up

	endclass : Agent


	//////////////////////////////////////////////////////////
	// Driver class
	//////////////////////////////////////////////////////////

	//enum bit [3:0] {NOP=4'b0000, ADD=4'b0001, SUB=4'b0010, AND=4'b0011, NOT=4'b0100, RD=4'b0101, WR=4'b0110, RDI=4'b1001}

	Transaction drv_tr;

	//Base callback class is an abstract class
	virtual class Driver_cbs;
		virtual task pre_tx(ref Transaction tr);
			// By default, callback does nothing
		endtask

		virtual task post_tx(ref Transaction tr);
			// By default, callback does nothing
		endtask
	endclass

	covergroup CovPort;
		non_ctrl_opcodes : coverpoint drv_tr.opcode {
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

		src_opcodes : coverpoint drv_tr.opcode {
			option.comment = "The source for every opcode that has a source has been R0, R1, R2, and R3";
			bins add_bin = {ADD};
			bins sub_bin = {SUB};
			bins and_bin = {AND};
			bins not_bin = {NOT};
			bins wr_bin  = {WR};
			bins misc = default;
	
		}

		dst_opcodes : coverpoint drv_tr.opcode {
			option.comment = "The destination for every opcode that has a source has been R0, R1, R2, and R3";
			bins add_bin = {ADD};
			bins sub_bin = {SUB};
			bins and_bin = {AND};
			bins not_bin = {NOT};
			bins rd_bin = {RD};
			bins rdi_bin  = {RDI};
			bins misc = default;		
		}

		transition_permutations : coverpoint drv_tr.opcode {
			option.comment = "Every opcode has been preceded and followed by every other instruction.";
			bins t1[] = (NOP, ADD, SUB, AND, NOT, RD, WR, RDI => NOP, ADD, SUB, AND, NOT, RD, WR, RDI);
			bins misc = default;
		}

		src_dst_opcodes : coverpoint drv_tr.opcode {
			option.comment = "For opcodes that have both a source and destination, all permutations of source and destination have been executed.";
			bins add_bin = {ADD};
			bins sub_bin = {SUB};
			bins and_bin = {AND};
			bins not_bin = {NOT};
			bins misc = default;
		}

		all_mem_written : coverpoint drv_tr.opcode {
			option.comment = "All memory locations have been written.";
			bins wr_bin = {WR};
			bins misc = default;
		}

		all_mem_read : coverpoint drv_tr.opcode {
			option.comment = "All memory locations have been read by a RD instruction.";
			bins rd_bin = {RD};
			bins misc = default;
		}

		address_cov : coverpoint drv_tr.address {
			option.auto_bin_max = 1 << (8);
		}

		cross src_opcodes, drv_tr.src;
		cross dst_opcodes, drv_tr.dst;
		cross src_dst_opcodes, drv_tr.src, drv_tr.dst;
		cross all_mem_written, address_cov;
		cross all_mem_read, address_cov;

	endgroup


	class Driver_cbs_cov extends Driver_cbs;
		CovPort ck;

		function new();
			ck = new();
		endfunction

		virtual task pre_tx(ref Transaction tr);
			drv_tr = tr;
			ck.sample();
			$display("%0d", $get_coverage());
			if ($get_coverage() == 100) $stop;
		endtask

		// virtual task post_tx(ref Transaction tr);
			
		// endtask

	endclass

	class Driver;
		Transaction tr;
		mailbox #(Transaction) agt2drv;
		event agt_drv_handshake;
		string ASCII_op = "";
		Driver_cbs cbs[$];


		function new(input mailbox #(Transaction) agt2drv, event agt_drv_handshake);
			this.agt2drv = agt2drv;
			this.agt_drv_handshake = agt_drv_handshake;
		endfunction : new

		task run();

			$root.top.if0.rst = 0;
			repeat (2) @$root.top.if0.cb; 	

			$root.top.if0.rst = 1;

			forever begin
				@$root.top.if0.cb;
				agt2drv.get(tr);	// Fetch next transaction
				foreach (cbs[i]) cbs[i].pre_tx(tr);

				// Drive transaction here
				$root.top.if0.cb.mem_word <= tr.instr;
				get_ascii(tr.instr[7:4]);

				if (tr.opcode == NOP || tr.opcode == NOT) begin // 3
					repeat (2) @$root.top.if0.cb;
				end else if (tr.opcode == ADD || tr.opcode == SUB || tr.opcode == AND) begin // 4
					repeat (3) @$root.top.if0.cb;
				end else if (tr.opcode == RD || tr.opcode == WR) begin // 5
					repeat (2) @$root.top.if0.cb;
					$root.top.if0.cb.mem_word <= tr.data;
					repeat (2) @$root.top.if0.cb;
				end else if (tr.opcode == RDI) begin
					repeat (2) @$root.top.if0.cb;
					$root.top.if0.cb.mem_word <= tr.data;
					repeat (1) @$root.top.if0.cb;
				end

				->agt_drv_handshake;
			end

			// Show the output of the final transaction
			@$root.top.if0.cb;
			$root.top.if0.cb.mem_word <= NOP;
			get_ascii(NOP);
			repeat (3) @$root.top.if0.cb;

		endtask : run

		task wrap_up();	// Empty for now
		endtask : wrap_up

		function void get_ascii(input bit [3:0] opcode);
			// $display("In Driver, at time %0t, in ascii function, opcode = %4b", $time, opcode);
			case (opcode)
				NOP : ASCII_op="NOP";
				ADD : ASCII_op="ADD";
				SUB : ASCII_op="SUB";
				AND : ASCII_op="AND";
				NOT : ASCII_op="NOT";
				RD  : ASCII_op="RD";
				WR  : ASCII_op="WR";
				BR  : ASCII_op="BR";
				BRZ : ASCII_op="BRZ";
				RDI : ASCII_op="RDI";
				HALT: ASCII_op="HALT";
				default : $display("Error: malformed opcode");
			endcase
		endfunction : get_ascii

	endclass : Driver


	//////////////////////////////////////////////////////////
	// Environment class
	//////////////////////////////////////////////////////////

	class Environment;
		Generator 	gen;
		Agent 		agt;
		Driver		drv;
		Config 		cfg;
		mailbox #(Transaction) gen2agt, agt2drv;
		event gen_agt_handshake, agt_drv_handshake;

		function new();
			cfg = new(10);
		endfunction

		function void gen_cfg();
			`SV_RAND_CHECK(cfg.randomize);
		endfunction

		function void build();
			// Initialize mailboxes
			gen2agt = new();
			agt2drv = new();

			// Initialize transactors
			gen = new(gen2agt, gen_agt_handshake);
			agt = new(gen2agt, agt2drv, gen_agt_handshake, agt_drv_handshake);
			drv = new(agt2drv, agt_drv_handshake);
		endfunction

		task run();
			$display("running at %0t", $time);
			fork
				gen.run();
				agt.run();
				drv.run();
			join
			$display("run done at %0t", $time);
		endtask

		task wrap_up();
			fork
				gen.wrap_up();
				agt.wrap_up();
				drv.wrap_up();
			join
		endtask
	endclass : Environment

endpackage : env_pkg
