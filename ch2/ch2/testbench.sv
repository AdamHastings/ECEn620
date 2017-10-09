`default_nettype none 
`timescale 1 ns / 1 ps

module testbench;

	integer clk_delay = 5;
	bit clk=0;
	bit write, read;
	logic [7:0] data_in;
	logic [15:0] address;
	logic [8:0] data_out;

	always
	begin
		#clk_delay clk = ~clk;
	end

	my_mem DUT_MY_MEM_0(.*);

	integer i = 0;
	integer j = 0;
	integer err_cnt = 0;
	integer rdwt_cnt = 6;
	integer start_time = get_time();
	integer end_time;
	integer seconds;

	logic [15:0] address_array [];
	logic [7:0] data_to_write_array[];
 	logic [8:0] data_read_expect_assoc [logic[15:0]];
 	logic[8:0] data_read_queue [$];
	logic [7:0] temp_data;

	initial begin

		address_array = new[6];
		data_to_write_array = new[6];

                
		for (i = 0; i < 6; i++) begin
			address_array[i] = $random;
			data_to_write_array[i] = $random;
			data_read_expect_assoc[address_array[i]] = {^data_to_write_array[i], data_to_write_array[i]};
		end
		
		test_traverse();

		$display("Data read Queue:");
		for (i = 0; i < 6; i++) begin
			$display("  -- data_read_queue[%0d]: %0h", i, data_read_queue[i]);
		end
		$display("");
		for (i = 0; i < 6; i++) begin
			if (data_read_queue[i] != data_read_expect_assoc[address_array[i]]) begin
				$error("The following values are unequal:");
 				$display("  -- data_read_expect_assoc[%0h] = %0h", address_array[i], data_read_expect_assoc[address_array[i]]);
				$display("  -- data_read_queue[%0d] = %0h", i, data_read_queue[i]);
				err_cnt++;
 			end
		end
		
		// Compute total time taken
		end_time = get_time();
		seconds = end_time - start_time;

		$display("");
		$display("RESULTS:");
		$display("");
		$display("------------------------------------------------");
		$display("-- Elapsed time (s) : %0d", seconds);
		$display("-- Simulation time (ns) : %0d", $time);
		$display("-- Read/Writes performed : %0d", rdwt_cnt);
		$display("-- Errors found : %0d", err_cnt);
		$display("------------------------------------------------");
	end

	task test_traverse ();
	  
	  #3;
	  // Put in values and read output
	  for (i = 0; i < 6; i++) begin
		data_in = data_to_write_array[i];
		address = address_array[i];
		// Uncomment to show how testbench handles DUT errors
		if (i == 3) begin
			data_in = 0;
		end
		write = 1;
		read = 0;
		#clk_delay;
		#clk_delay;
		write = 0;
		read = 1;
		#clk_delay;
		data_read_queue.push_back(data_out);
		#clk_delay;
	end

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
