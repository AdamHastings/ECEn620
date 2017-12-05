`timescale 1ns / 1ps
`default_nettype none

// Top module of testbench
module top;

	// Clock generation
	bit clk=1;
	always #50 clk = ~clk;
	bit run_checker = 0;

	// Error counter
	int err_cnt=0;

	// Output from encrypted DUT
	logic [2:0] grant_out;

	// Declare interface
	arb_if arbif(clk);

	// Give interface to test program
	test t0 (arbif.TEST);

	// Give interface to golden model
	golden_module gm0 (arbif.GOLDEN);

	// Instantiate encrypted arbiter
	arbiter a0(
		.clk(clk),
		.reset(arbif.rst),
		.req0(arbif.req[0]),
		.req1(arbif.req[1]),
		.req2(arbif.req[2]),
		.en0(arbif.en[0]),
		.en1(arbif.en[1]),
		.en2(arbif.en[2]),
		.grant0(grant_out[0]),
		.grant1(grant_out[1]),
		.grant2(grant_out[2])
	);

	// Uncomment to model an error in the DUT
	// assign grant_out[1] = 1'b1;

	// Checker code
	always @(negedge clk) begin
		grant0_err : assert (grant_out[0] == arbif.grant[0])
		else begin
			$error("grant_out[0] != arbif.grant[0]");
			err_cnt++;
		end

		grant1_err : assert (grant_out[1] == arbif.grant[1])
		else begin
			$error("grant_out[1] != arbif.grant[1]");
			err_cnt++;
		end

		grant2_err : assert (grant_out[2] == arbif.grant[2])
		else begin
			$error("grant_out[2] != arbif.grant[2]");
			err_cnt++;
		end
	end


endmodule // top