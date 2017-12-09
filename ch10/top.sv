module top;

	// Use Clock_Unit for clock generation
	bit clk;
	Clock_Unit cu0(clk);

	parameter ADDRESS_WIDTH = 8;

	// Create interface
	risc_spm_iface #(ADDRESS_WIDTH) if0(clk);

	// Instantiate DUT
	RISC_SPM rspm0(
		.clk(clk),
		.rst(if0.rst),
		.data_out(if0.mem_word),
		.address(if0.address),
		.data_in(if0.Bus_1),
		.write(if0.write)
	);

	test #(.ADDRES_WIDTH(ADDRESS_WIDTH)) t0();

endmodule
