module golden_module(arb_if.GOLDEN arbif);

	// State enum used to determine priority
	enum {PORT0, PORT1, PORT2} state = PORT0;

	always_ff @(posedge arbif.clk or posedge arbif.rst) begin
		// At reset the priority is port0
		if (arbif.rst) begin
			state <= PORT0;
		end else if (arbif.grant[0] || arbif.grant[1] || arbif.grant[2]) begin
			// Priority	is maintained in a round robin format, i.e. port0->port1->port2->port0…			
			unique case (state)
				PORT0 : state <= PORT1;
				PORT1 : state <= PORT2;
				PORT2 : state <= PORT0;
			endcase // state
		end
	end

	// Grant is combinatorial
	always_comb begin
		arbif.grant[0] <= 1'b0;
		arbif.grant[1] <= 1'b0;
		arbif.grant[2] <= 1'b0;
		// If a port with priotity is not enavled or not currently requesting,
		// the next port will be given the grant given that port is enabled and
		// requesting the bus, and so on
		unique case (state)
			PORT0 : if (arbif.req[0] && arbif.en[0])
						arbif.grant[0] <= 1'b1;
					else if (arbif.req[1] && arbif.en[1])
						arbif.grant[1] <= 1'b1;
					else if (arbif.req[2] && arbif.en[2])
						arbif.grant[2] <= 1'b1;
			PORT1 : if (arbif.req[1] && arbif.en[1])
						arbif.grant[1] <= 1'b1;
					else if (arbif.req[2] && arbif.en[2])
						arbif.grant[2] <= 1'b1;
					else if (arbif.req[0] && arbif.en[0])
						arbif.grant[0] <= 1'b1;
			PORT2 : if (arbif.req[2] && arbif.en[2])
						arbif.grant[2] <= 1'b1;
					else if (arbif.req[0] && arbif.en[0])
						arbif.grant[0] <= 1'b1;
					else if (arbif.req[1] && arbif.en[1])
						arbif.grant[1] <= 1'b1;
		endcase
	end

endmodule
