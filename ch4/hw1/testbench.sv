`default_nettype none 
`timescale 1 ns / 1 ps

module testbench(my_mem_if.TEST if0);

	// Delay half a clock cycle
	integer clk_delay = 5;


	integer i = 0;
	integer j = 0;
	integer err_cnt = 0;
	integer rdwt_cnt = 6;
	integer start_time = get_time();
	integer end_time;
	integer seconds;


	// Data structures used by testbench
	logic [15:0] address_array [];
	logic [7:0] data_to_write_array[];
 	logic [8:0] data_read_expect_assoc [logic[15:0]];
 	logic[8:0] data_read_queue [$];

	initial begin
		string rw_test_status;
		address_array = new[6];
		data_to_write_array = new[6];

		i = 0; 
		do begin
			address_array[i] = $random;
			data_to_write_array[i] = $random;
			data_read_expect_assoc[address_array[i]] = {^data_to_write_array[i], data_to_write_array[i]};
			i++;
		end while (i < 6);
		
		// Run test
		test_traverse();

		#clk_delay;
		#clk_delay;

		// Print output
		$display("Data read Queue:");
		i = 0; 
		do begin
			$display("  -- data_read_queue[%0d]: %0h", i, data_read_queue[i]);
			i++;
		end while (i < 6);

		$display("");


		// Compare results
		i = 0; 
		do begin
			if (data_read_queue[i] != data_read_expect_assoc[address_array[i]]) begin
				$error("The following values are unequal:");
 				$display("  -- data_read_expect_assoc[%0h] = %0h", address_array[i], data_read_expect_assoc[address_array[i]]);
				$display("  -- data_read_queue[%0d] = %0h", i, data_read_queue[i]);
				err_cnt++;
 			end
 			i++;
		end while (i < 6);

		
		// Compute total time taken
		end_time = get_time();
		seconds = end_time - start_time;

		$display("");
		$display("RESULTS:");
		$display("");
		$display("------------------------------------------------");
		$display("--           Elapsed time : %0d s", seconds);
		$display("--        Simulation time : %0d ns", $time);
		$display("--  Read/Writes performed : %0d", rdwt_cnt);
		$display("-- Data read errors found : %0d", err_cnt);
		$display("--     R/W=1 errors found : %0d", if0.rw_err_cnt);
		$display("------------------------------------------------");
		$stop;

	end

	task test_traverse ();	  
		#3;
		// Put in values and read output
		i = 0;
	 	do begin
			if0.data_in = data_to_write_array[i];
			if0.address = address_array[i];
			// Uncomment to show how testbench handles DUT errors
			if (i == 3) begin
				if0.data_in = 0;
			end
			if0.write = 1;
			if0.read = 0;
			// Uncomment to show how testbench handles r/w=1 errors
			if (i < 4) begin
				if0.read = 1;
			end
			#clk_delay;
			#clk_delay;
			if0.write = 0;
			if0.read = 1;
			#clk_delay;
			data_read_queue.push_back(if0.data_out);
			#clk_delay;
			i++;
		end while (i < 6);
	endtask

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

endmodule
