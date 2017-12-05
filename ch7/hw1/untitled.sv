module golden_module(arb_if.GOLDEN port0, arb_if.GOLDEN port1, arb_if.GOLDEN port2, clk, reset);

	// State enum used to determine priority
	enum {PORT0, PORT1, PORT2} state = PORT0;

	always_ff @(posedge clk or posedge reset) begin
		// At reset the priority is port0
		if (reset) begin
			state <= PORT0;
		end else if (port0.grant || port1.grant || port2.grant) begin
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
		port1.grant <= 1'b0;
		port2.grant <= 1'b0;
		port2.grant <= 1'b0;
		// If a port with priotity is not enavled or not currently requesting,
		// the next port will be given the grant given that port is enabled and
		// requesting the bus, and so on
		unique case (state)
			PORT0 : if (port0.req && port0.en)
						port0.grant <= 1'b1;
					else if (port1.req && port1.en)
						port1.grant <= 1'b1;
					else if (port2.req && port2.en)
						port2.grant <= 1'b1;
			PORT1 : if (port1.req && port1.en)
						port1.grant <= 1'b1;
					else if (port2.req && port2.en)
						port2.grant <= 1'b1;
					else if (port0.req && port0.en)
						port0.grant <= 1'b1;
			PORT2 : if (port2.req && port2.en)
						port2.grant <= 1'b1;
					else if (port0.req && port0.en)
						port0.grant <= 1'b1;
					else if (port1.req && port1.en)
						port1.grant <= 1'b1;
		endcase
	end

endmodule
