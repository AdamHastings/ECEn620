package env_pkg;

	import CovPort_pkg::*;
	import Transaction_pkg::*;
	import Generator_pkg::*;
	import Agent_pkg::*;
	import Driver_pkg::*;
	

	class Environment #(ADDRESS_WIDTH);
		Generator 	#(ADDRESS_WIDTH) gen;
		Agent 		#(ADDRESS_WIDTH) agt;
		Driver		#(ADDRESS_WIDTH) drv;
		mailbox #(Transaction #(ADDRESS_WIDTH)) gen2agt, agt2drv;
		event gen_agt_handshake, agt_drv_handshake;
		virtual risc_spm_iface #(ADDRESS_WIDTH) vif0 = $root.top.if0;


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
