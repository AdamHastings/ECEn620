package env_pkg;
	// Macro to check if randomization succeeded
	`define SV_RAND_CHECK(r)\
		do begin\
			if (!(r)) begin\
				$display("%s:%0d: Randomization failed \"%s\"",\
					`__FILE__, `__LINE__, `"r`");\
				$finish;\
			end\
		end while (0)


	// Class to model a randomized transaction between test and DUT
	class Transaction;
		int port_number;
		rand bit en, req; // Randomized enable and request

	endclass : Transaction


	// Generate a Transaction and place it in the mailbox
	class Generator;
		Transaction tr0, tr1, tr2;
		mailbox #(Transaction) mbx;
		
		function new(input mailbox #(Transaction) mbx);
			this.mbx = mbx;
		endfunction : new

		task run(input int count);
			repeat(count) begin
				tr0 = new();
				tr1 = new();
				tr2 = new();
				tr0.port_number = 0;
				tr1.port_number = 1;
				tr2.port_number = 2;
				`SV_RAND_CHECK(tr0.randomize());
				`SV_RAND_CHECK(tr1.randomize());
				`SV_RAND_CHECK(tr2.randomize());
				mbx.put(tr0);
				mbx.put(tr1);
				mbx.put(tr2);
			end
		endtask
	endclass 


	// Get a Transaction from the mailbox and drive it to the DUT
	class Driver;
		Transaction tr0, tr1, tr2;
		mailbox #(Transaction) mbx;
		
		function new(input mailbox #(Transaction) mbx);
			this.mbx = mbx;
		endfunction : new

		task run(input int count);
			repeat (count) begin
				// Drive transaction here
				@$root.top.arbif.pos;

				if(mbx.try_get(tr0)) begin // Fetch next instruction
					$root.top.arbif.pos.en[tr0.port_number] <= tr0.en;
					$root.top.arbif.pos.req[tr0.port_number] <= tr0.req;
				end else begin
					// Disable if there is no object in the mailbox
					$root.top.arbif.pos.en[0] <= 1'b0;
				end

				if(mbx.try_get(tr1)) begin // Fetch next instruction
					$root.top.arbif.pos.en[tr1.port_number] <= tr1.en;
					$root.top.arbif.pos.req[tr1.port_number] <= tr1.req;
				end else begin
					// Disable if there is no object in the mailbox
					$root.top.arbif.pos.en[1] <= 1'b0;
				end

				if(mbx.try_get(tr2)) begin // Fetch next instruction
					$root.top.arbif.pos.en[tr2.port_number] <= tr2.en;
					$root.top.arbif.pos.req[tr2.port_number] <= tr2.req;
				end else begin
					// Disable if there is no object in the mailbox
					$root.top.arbif.pos.en[2] <= 1'b0;
				end

			end // repeat (count)
		endtask 
	endclass

endpackage : env_pkg