`timescale 1 ns / 1 ps

module my_mem(my_mem_if.DUT if0);

	// Declare a 9-bit associative array using the logic data type
	logic [8:0] mem_array [logic [15:0]];
	bit first_write = 1;

 	always @(posedge if0.clk) begin
		if (if0.write) begin
			mem_array[if0.address] = {if0.getParity(if0.data_in), if0.data_in};
			// // Uncomment to model an error in the DUT
			// if (first_write) begin
			// 	mem_array[if0.address] = 0;
			// 	first_write = 0;
			// end
		end else if (if0.read) begin
			// Uncomment to show that testbench stil works with slow-to-respond DUT
			// #75;
			if0.data_out =  mem_array[if0.address];
		end
	end

endmodule


