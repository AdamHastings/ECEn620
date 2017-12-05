program automatic test (arb_if.TEST arbif);
	// Import transaction class
	import env_pkg::*;

	mailbox #(Transaction) mbx;
	Generator gen;
	Driver drv;
	int count;
	
	initial begin
		automatic int start_time = get_time(); // Variable to measure time 

		directedTest();

		// Create environment
		mbx = new();
		gen = new(mbx);
		drv = new(mbx);
		count = 100; // Run 100 random transactions

		// Run constrained random test
		gen.run(count);
		drv.run(count);

		// Print results
		printResults(start_time);
	end

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

	task printResults(input int start_time);
		// Compute total time taken
		int end_time = get_time();

		// Display the results table
		$display("\nRESULTS:\n");
		$display("------------------------------------------------");
		$display("--     Elapsed time : %0d s", end_time - start_time);
		$display("--  Simulation time : %0d ns", $time);
		$display("--     Errors found : %0d", $root.top.err_cnt);
		$display("------------------------------------------------");
		$stop;
	endtask : printResults


	// Get the current wall-clock time in seconds
	function integer get_time();
		int file_pointer;		
		void'($system("date +%s > sys_time")); 		// Stores time and date to file sys_time		
		file_pointer = $fopen("sys_time","r"); 		// Open the file sys_time with read access		
		void'($fscanf(file_pointer,"%d",get_time));	// Assign the value from file to variable		
		$fclose(file_pointer); 						//close the file
		void'($system("rm sys_time"));
	endfunction

endprogram: test
