

interface my_mem_if(input bit clk);
	logic write, read;
	logic [7:0] data_in;
	logic [8:0] data_out;
	logic [15:0] address;
	logic parity;

	integer rw_err_cnt = 0;


	// Block that generates errors whenever read == 1 and write == 1 at the same time
	always @ (posedge read or posedge write)
	begin
		if (read == 1 && write == 1) begin
				$error("read == 1 && write == 1");
				rw_err_cnt++;
		end
	end


	modport TEST (	output read, write, data_in, address,
					input clk, data_out, rw_err_cnt);

	modport DUT (	output data_out,
					input clk, read, write, data_in, address, parity);

	function bit getParity(input logic [7:0] d_in);
		return ^d_in;
	endfunction : getParity


endinterface : my_mem_if