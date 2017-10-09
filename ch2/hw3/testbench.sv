`default_nettype none 
`timescale 1 ns / 1 ps

module testbench;

	integer clk_delay = 5;

	// Values to give DUT
	bit clk=0;
	bit write, read;
	logic [7:0] data_in;
	logic [15:0] address;
	logic [8:0] data_out;

	// Generate clock
	always
	begin
		#clk_delay clk = ~clk;
	end

	// Instantiate module
	my_mem DUT_MY_MEM_0(.*);

	// Variables used by testbench
	integer i = 0;
	integer j = 0;
	integer err_cnt = 0;
	integer rdwt_cnt = 6;
	integer start_time = get_time();
	integer end_time;
	integer seconds;

	// Struct containing read/write objects
	typedef struct {
		bit [15:0] address;
		bit [7:0]  data;
		bit [8:0]  read_data;
		bit [8:0]  expected_data;
	} read_write_s;

	// Array of structus
	read_write_s read_write_array [];

	bit [15:0] address_i;
	bit [7:0]  data_i;
	bit [8:0]  expected_data_i;

	initial begin
		
		// Allocate memory
		read_write_array = new[rdwt_cnt];

		for (i = 0; i < rdwt_cnt; i++) begin
			address_i = $random;
			data_i = $random;
			expected_data_i = {^data_i, data_i};

			read_write_array[i] = '{address_i,
									data_i,
									0,
									expected_data_i};
		end
		
		test_traverse();

		$display("Data read Queue before shuffle:");
		for (i = 0; i < 6; i++) begin
			$display("  -- read_write_array[%0d].read_data: %0h", i, read_write_array[i].read_data);
		end
		$display("");
		
		// Shuffle array for readback
		read_write_array.shuffle();

		$display("Data read Queue after shuffle:");
		for (i = 0; i < 6; i++) begin
			$display("  -- read_write_array[%0d].read_data: %0h", i, read_write_array[i].read_data);
		end
		$display("");
		for (i = 0; i < 6; i++) begin
			if (read_write_array[i].read_data != read_write_array[i].expected_data) begin
				$error("The following values are unequal at address x%0h:", read_write_array[i].address);
 				$display("  -- read_write_array[%0h].read_data = %0h", i, read_write_array[i].read_data);
				$display("  -- data_read_queue[%0d].expected_data = %0h", i, read_write_array[i].expected_data);
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
	  for (i = 0; i < rdwt_cnt; i++) begin
	  	address = read_write_array[i].address;
		data_in = read_write_array[i].data;
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
		read_write_array[i].read_data = data_out;
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
