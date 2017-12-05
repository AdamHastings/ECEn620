// Macro to check if randomization succeeded
`define SV_RAND_CHECK(r)\
	do begin\
		if (!(r)) begin\
			$display("%s:%0d: Randomization failed \"%s\"",\
				`__FILE__, `__LINE__, `"r`");\
			$finish;\
		end\
	end while (0)

program automatic test (arb_if.TEST arbif);
	// Import transaction class
	import transaction_pkg::*;

	// Variables to measure time 
	integer start_time = get_time();
	integer end_time;

	
	initial begin

		// Run directed test
		directedTest();
		repeat (3) @arbif.pos;
		// Run constrained random test
		CRT_with_threads();

		// Compute total time taken
		end_time = get_time();

		// Display the results table
		$display("");
		$display("RESULTS:");
		$display("");
		$display("------------------------------------------------");
		$display("--     Elapsed time : %0d s", end_time - start_time);
		$display("--  Simulation time : %0d ns", $time);
		$display("--     Errors found : %0d", $root.top.err_cnt);
		$display("------------------------------------------------");
		$stop;

	end

	Transaction t0, t1, t2;

	// Constrained Random Test
	task CRT_with_threads();

		// Create a thread for each port
		fork	
			begin // Port 0
				t0 = new();
				t0.port_number = 0;

				for (int i=0; i<100; i++) begin
					@arbif.pos;
					`SV_RAND_CHECK(t0.randomize());
					arbif.pos.req[t0.port_number] <= t0.req;
					arbif.pos.en[t0.port_number] <= t0.en;
				end
			end		
			begin // Port 1
				t1 = new();
				t1.port_number = 1;

				for (int i=0; i<100; i++) begin
					@arbif.pos;
					`SV_RAND_CHECK(t1.randomize());
					arbif.pos.req[t1.port_number] <= t1.req;
					arbif.pos.en[t1.port_number] <= t1.en;
				end
			end		
			begin // Port 2
				t2 = new();
				t2.port_number = 2;

				for (int i=0; i<100; i++) begin
					@arbif.pos;
					`SV_RAND_CHECK(t2.randomize());
					arbif.pos.req[t2.port_number] <= t2.req;
					arbif.pos.en[t2.port_number] <= t2.en;
				end
			end
		join

	endtask : CRT_with_threads

	// This directed test follows from Figure 1 in the Chapter 7, Homework 1 assignment
	task directedTest();
		@arbif.pos;
		arbif.pos.rst <= 1;

		repeat (2) @arbif.neg;
		arbif.neg.rst <= 0;

		@arbif.pos;
		arbif.pos.req <= 3'b111;
		arbif.pos.en <= 3'b111;

		repeat (3) @arbif.pos;
		arbif.pos.req <= 3'b110;

		repeat (3) @arbif.pos;
		arbif.pos.req <= 3'b000;

		repeat (2) @arbif.pos;

	endtask : directedTest

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

endprogram: test
