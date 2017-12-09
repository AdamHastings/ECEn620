package Generator_pkg;

	import Transaction_pkg::*;

	// Macro to check if randomization succeeded
	`define SV_RAND_CHECK(r)\
		do begin\
			if (!(r)) begin\
				$display("%s:%0d: Randomization failed \"%s\"",\
					`__FILE__, `__LINE__, `"r`");\
				$finish;\
			end\
		end while (0)

	class Generator #(ADDRESS_WIDTH);
		Transaction #(ADDRESS_WIDTH) tr;
		mailbox #(Transaction #(ADDRESS_WIDTH)) gen2agt;
		event gen_agt_handshake;

		function new(input mailbox #(Transaction #(ADDRESS_WIDTH)) gen2agt, event gen_agt_handshake);
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

endpackage : Generator_pkg