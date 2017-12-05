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

		task run(input int count);
			repeat (count) begin
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

		task run(input int count);
			repeat (count) begin
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

	class Driver;
		Transaction tr;
		mailbox #(Transaction) agt2drv;
		event agt_drv_handshake;
		string ASCII_op = "";

		function new(input mailbox #(Transaction) agt2drv, event agt_drv_handshake);
			this.agt2drv = agt2drv;
			this.agt_drv_handshake = agt_drv_handshake;
		endfunction : new

		task run(input int count);

			$root.top.if0.rst = 0;
			repeat (2) @$root.top.if0.cb; 	

			$root.top.if0.rst = 1;

			repeat (count) begin
				@$root.top.if0.cb;
				agt2drv.get(tr);	// Fetch next transaction
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
			$display("In Driver, at time %0t, in ascii function, opcode = %4b", $time, opcode);
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
				gen.run(cfg.run_for_n_trans);
				agt.run(cfg.run_for_n_trans);
				drv.run(cfg.run_for_n_trans);
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
