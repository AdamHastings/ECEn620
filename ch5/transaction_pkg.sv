package transaction_pkg;

	class Transaction;
		logic [7:0] data_in;
		logic [8:0] data_out, expected_data;
		logic [15:0] address;

		// A static class variable error
		static int error_cnt = 0;

		// Custom constructor to assign a random value to class variables address and data_in
		function new();
			this.address = $random;
			this.data_in = $random;
		endfunction

		// Function print_data_out to print out the time and class variable data_out
		function void print_data_out();
			$display("At time %0t ns, data_out = %0h", $time/1000, data_out);
		endfunction : print_data_out

		// A static function to print out the time and static class variable error
		static function void print_err_cnt();
			$display("At time %0t ns, error_cnt = %0d", $time/1000, error_cnt);
		endfunction : print_err_cnt

		// Function to check class variable expected_data with class variable data_out and increment static class variable error if they don’t match.
		function void check_data_out();
			if (data_out != expected_data) begin
				error_cnt++;
				$error("data_out != expected_data");
				$display("At time %0t ns, expected_data = %0h", $time/1000, expected_data);
				print_data_out();
				print_err_cnt();
			end
		endfunction : check_data_out

		// A deep copy function for class Transaction. Note that you do not have to call this function, but at least create it.
		function Transaction copy();
			copy = new();
			copy.data_in = data_in;
			copy.data_out = data_out;
			copy.expected_data = expected_data;
			copy.address = address;
			copy.error_cnt = error_cnt;
		endfunction : copy


	endclass : Transaction

endpackage : transaction_pkg
	