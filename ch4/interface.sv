

interface my_mem_if(input bit clk);
	logic write, read;
	logic [7:0] data_in;
	logic [8:0] data_out;
	logic [15:0] address;

	modport TEST (	output read, write, data_in, address,
					input clk, data_out);

	modport DUT (	output data_out,
					input clk, read, write, data_in, address);

endinterface : my_mem_if