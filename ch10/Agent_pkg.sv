package Agent_pkg;

	import Transaction_pkg::*;

	class Agent #(ADDRESS_WIDTH);

		mailbox #(Transaction #(ADDRESS_WIDTH)) gen2agt, agt2drv;
		event gen_agt_handshake, agt_drv_handshake;
		Transaction #(ADDRESS_WIDTH) tr;

		function new(input mailbox #(Transaction #(ADDRESS_WIDTH)) gen2agt, agt2drv, event gen_agt_handshake, agt_drv_handshake);
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

endpackage : Agent_pkg