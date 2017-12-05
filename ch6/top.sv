`timescale 1 ns / 100 ps

module top;

	bit clk = 0;
	always #50 clk = ~clk;

	bit reset;
	
	ahb_if ahb_if0(clk);
	sram_if sram_if0(clk);

	test t0(ahb_if0, reset);
	sram_control sc0(ahb_if0, sram_if0, reset);
	async a0(
		.CE_b(sram_if0.CE_b),
		.WE_b(sram_if0.WE_b),
		.OE_b(sram_if0.OE_b),
		.A(sram_if0.A),
		.DQ(sram_if0.DQ)
	);

endmodule : top
