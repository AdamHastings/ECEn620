`timescale 1 ns / 1 ps

module top;

	bit clk;
	always #5 clk = ~clk;
	
	my_mem_if if0(clk);
	my_mem d0(if0);
	testbench t0(if0);

endmodule : top
