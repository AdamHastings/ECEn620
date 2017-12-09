package env_pkg;

	import CovPort_pkg::*;
	import Transaction_pkg::*;
	import Generator_pkg::*;
	import Agent_pkg::*;
	import Driver_pkg::*;


	//////////////////////////////////////////////////////////
	// Environment class
	//////////////////////////////////////////////////////////

	class Environment;
		Generator 	gen;
		Agent 		agt;
		Driver		drv;
		mailbox #(Transaction) gen2agt, agt2drv;
		event gen_agt_handshake, agt_drv_handshake;
		virtual risc_spm_iface vif0 = $root.top.if0;


		function void build();
			// Initialize mailboxes
			gen2agt = new();
			agt2drv = new();

			// Initialize transactors
			gen = new(gen2agt, gen_agt_handshake);
			agt = new(gen2agt, agt2drv, gen_agt_handshake, agt_drv_handshake);
			drv = new(agt2drv, agt_drv_handshake, vif0);
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
