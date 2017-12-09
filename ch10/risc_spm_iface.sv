interface risc_spm_iface #(ADDRESS_WIDTH=8) (input bit clk);

	logic [7:0] Bus_1, address;
	logic write;
	bit [7:0] mem_word;
	bit rst;

	clocking cb @(posedge clk);
		output mem_word;
		input Bus_1, address, write;
	endclocking

	modport TEST (input clk, clocking cb);

endinterface
