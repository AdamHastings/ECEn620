interface arb_if(input bit clk);

	// Signals to be passed between test and arbiter
	logic [2:0] req=0, en=0, grant=0;
	bit rst=1;

	// Clocking block on positive edge 
	clocking pos @(posedge clk);
		output en, req, rst;
		input grant;
	endclocking : pos

	// Clocking block on negative edge
	clocking neg @(negedge clk);
		output en, req, rst;
		input grant;
	endclocking : neg

	// Test program modport
	modport TEST (input clk,
				  clocking pos, neg);

	// Golden model modport
	modport GOLDEN (input req, en, rst, clk,
				  	output grant);

endinterface