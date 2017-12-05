`default_nettype none 
`timescale 1 ns / 1 ps

program automatic testbench(my_mem_if.TEST if0);
	import transaction_pkg::*;
	
	// Number of read/writes to perform
	integer rw_cnt = 6;
	integer start_time = get_time();
	integer end_time;

	// Array to contain Transactions
	Transaction tarray [6];

	initial begin

		// Create new objects; Write to DUTs
		for (int i=0; i<rw_cnt; i++) begin
			
			@if0.cb;
			tarray[i] = new();
			if0.data_in <= tarray[i].data_in;
			if0.address <= tarray[i].address;
			if0.write <= 1;
			if0.read <= 0;
			tarray[i].expected_data <= {^tarray[i].data_in, tarray[i].data_in};

			// // Uncomment to show how testbench handles r/w=1 errors
			// if (i > 3) begin
			// 	if0.read <= 1;
			// end

		end

		// Read from DUT in reverse order
		for (int i = rw_cnt-1; i>=0; i--) begin

			@if0.cb;
			if0.write <= 0;
			if0.read <= 1;
			if0.address <= tarray[i].address;

			@if0.cb;
			tarray[i].data_out <= if0.data_out;

			@if0.cb;
			tarray[i].check_data_out();
		end

		// Compute total time taken
		end_time = get_time();

		// Display the results table
		$display("");
		$display("RESULTS:");
		$display("");
		$display("------------------------------------------------");
		$display("--           Elapsed time : %0d s", end_time - start_time);
		$display("--        Simulation time : %0d ns", $time);
		$display("--  Read/Writes performed : %0d", rw_cnt);
		$display("-- Data read errors found : %0d", Transaction::error_cnt);
		$display("--     R/W=1 errors found : %0d", if0.rw_err_cnt);
		$display("------------------------------------------------");
		$stop;
	end

	/* Get the current wall-clock time in seconds */
	function integer get_time();
		int file_pointer;
		//Stores time and date to file sys_time
		void'($system("date +%s > sys_time"));
		//Open the file sys_time with read access
		file_pointer = $fopen("sys_time","r");
		//assin the value from file to variable
		void'($fscanf(file_pointer,"%d",get_time));
		//close the file
		$fclose(file_pointer);
		void'($system("rm sys_time"));
	endfunction

endprogram : testbench