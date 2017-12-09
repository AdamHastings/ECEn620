package Driver_pkg;	

	`include "opcodes_include.v"
	import Transaction_pkg::*;

	//Base callback class is an abstract class
	virtual class Driver_cbs;
		virtual task pre_tx(ref Transaction tr);
			// By default, callback does nothing
		endtask

		virtual task post_tx(ref Transaction tr);
			// By default, callback does nothing
		endtask
	endclass


	class Driver;
		Transaction tr;
		mailbox #(Transaction) agt2drv;
		event agt_drv_handshake;
		string ASCII_op = "";
		Driver_cbs cbs[$];
		virtual risc_spm_iface.TEST vif0;


		function new(input mailbox #(Transaction) agt2drv, event agt_drv_handshake, input virtual risc_spm_iface.TEST vif0);
			this.agt2drv = agt2drv;
			this.agt_drv_handshake = agt_drv_handshake;
			this.vif0 = vif0;
		endfunction : new

		task run();

			$root.top.if0.rst = 0;
			repeat (2) @vif0.cb; 	

			$root.top.if0.rst = 1;

			forever begin
				@vif0.cb;
				agt2drv.get(tr);	// Fetch next transaction
				foreach (cbs[i]) cbs[i].pre_tx(tr);

				// Drive transaction here
				vif0.cb.mem_word <= tr.instr;
				get_ascii(tr.instr[7:4]);

				if (tr.opcode == NOP || tr.opcode == NOT) begin // 3
					repeat (2) @vif0.cb;
				end else if (tr.opcode == ADD || tr.opcode == SUB || tr.opcode == AND) begin // 4
					repeat (3) @vif0.cb;
				end else if (tr.opcode == RD || tr.opcode == WR) begin // 5
					repeat (2) @vif0.cb;
					vif0.cb.mem_word <= tr.data;
					repeat (2) @vif0.cb;
				end else if (tr.opcode == RDI) begin
					repeat (2) @vif0.cb;
					vif0.cb.mem_word <= tr.data;
					repeat (1) @vif0.cb;
				end

				->agt_drv_handshake;
			end

			// Show the output of the final transaction
			@vif0.cb;
			vif0.cb.mem_word <= NOP;
			get_ascii(NOP);
			repeat (3) @vif0.cb;

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

endpackage : Driver_pkg