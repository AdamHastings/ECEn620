`default_nettype none 
`timescale 1 ns / 1 ps

module testbench(my_mem_if.TEST if0);

	// Delay half a clock cycle
	integer clk_delay = 5;

	// // Signals to be passed to DUT
	// bit clk=0;
	// bit write=0, read=0;
	// logic [7:0] data_in;
	// logic [15:0] address;
	// logic [8:0] data_out;

	// Flag used to tell testbench if rw_test is running
	// bit rw_test_running = 0;

	// always
	// begin
	// 	#clk_delay clk = ~clk;
	// end

	integer i = 0;
	integer j = 0;
	integer err_cnt = 0, rw_err_cnt = 0, pre_test_rw_err_cnt = 0;
	integer rdwt_cnt = 6;
	integer start_time = get_time();
	integer end_time;
	integer seconds;

	// // Block that generates errors whenever read == 1 and write == 1 at the same time
	// always @ (posedge read or posedge write)
	// begin
	// 	if (read == 1 && write == 1) begin
	// 		if (!rw_test_running) begin
	// 			// // Uncomment to see r/w=1 error
	// 			// if (0)
	// 				$error("read == 1 && write == 1");
	// 		end
	// 		// // Uncomment to see r/w=1 error
	// 		// if (0)
	// 			rw_err_cnt++;
	// 	end
	// end


	// my_mem DUT_MY_MEM_0(.*);


	// Data structures used by testbench
	logic [15:0] address_array [];
	logic [7:0] data_to_write_array[];
 	logic [8:0] data_read_expect_assoc [logic[15:0]];
 	logic[8:0] data_read_queue [$];
	logic [7:0] temp_data;

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

		// Test new added feature
		// rw_err_checker_test(rw_test_status);
		
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
		// $display("--      R/W=1 test status : %0s", rw_test_status);
		$display("------------------------------------------------");

	end

	// bit test_read=0, test_write=0;
	// integer expected_rw_err_cnt=0;
	// integer rw_test_delay = 1000;
	// integer random_delay1, random_delay2;


	// always
	// begin
	// 	random_delay1 = $urandom_range(10,0);
	// 	#random_delay1 test_read = ~test_read;
	// end

	// always
	// begin
	// 	random_delay2 = $urandom_range(10,0);
	// 	#random_delay2 test_write = ~test_write;
	// end

	// always @ (posedge test_read or posedge test_write)
	// begin
	// 	if (test_read && test_write) begin
	// 		if (rw_test_running) begin
	// 			expected_rw_err_cnt++;
	// 		end
	// 	end
	// end


	// // Run this task to check the functionality of the read
	// task rw_err_checker_test(output string status);


	// 	rw_test_running = 1;
	// 	pre_test_rw_err_cnt = rw_err_cnt;
	// 	rw_err_cnt = 0;
	// 	expected_rw_err_cnt = 0;

	// 	// Make this assignment for this task only
	// 	assign if0.read = test_read;
	// 	assign if0.write = test_write;

	// 	// Run for specified amount of time
	// 	#rw_test_delay;

	// 	status = "PASS";
	// 	if (expected_rw_err_cnt != rw_err_cnt) begin
	// 		$error("rw_err_checker_test failed!");
	// 		$display("expected error count: %0d", expected_rw_err_cnt);
	// 		$display("observed error count : %0d", rw_err_cnt);
	// 		status = "FAIL";
	// 	end

	// 	// Unassign read and write, since the test is over
	// 	assign if0.read = 0;
	// 	assign if0.write = 0;
	// 	rw_test_running = 0;
	// endtask

	task test_traverse ();	  
		#3;
		// Put in values and read output
		i = 0;
	 	do begin
			if0.data_in = data_to_write_array[i];
			if0.address = address_array[i];
			// // Uncomment to show how testbench handles DUT errors
			// if (i == 3) begin
			// 	data_in = 0;
			// end
			if0.write = 1;
			if0.read = 0;
			// Uncomment to show how testbench handles r/w=1 errors
			// if (i < 4) begin
			// 	read = 1;
			// end
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
