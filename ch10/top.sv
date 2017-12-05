module top;

	// Use Clock_Unit for clock generation
	bit clk;
	Clock_Unit cu0(clk);

	// Create interface
	risc_spm_iface if0(clk);

	// Instantiate DUT
	RISC_SPM rspm0(
		.clk(clk),
		.rst(if0.rst),
		.data_out(if0.mem_word),
		.address(if0.address),
		.data_in(if0.Bus_1),
		.write(if0.write)
	);

	test t0(if0.TEST);

endmodule
