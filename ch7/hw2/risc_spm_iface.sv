interface risc_spm_iface (input bit clk);

	logic [7:0] Bus_1, address;
	bit	[7:0] mem_word;
	logic write;

	clocking cb @(posedge clk);
		output mem_word;
		input Bus_1, address, write;
	endclocking

	modport TEST (input clk, clocking cb);

endinterface