`define SV_RAND_CHECK(r) \
	do begin \
		if (!(r)) begin \
			$display("%s:%0d: Randomization failed \"%s\"", \
				`__FILE__, `__LINE__, `"r`"); \
			$finish; \
		end \
	end while (0)



program automatic test(ahb_if ahb_bus, output bit reset);
	import my_package::*;

	Transaction t;
	logic old_HWRITE;
	initial begin

		$urandom(230);

		reset = 1;
		@ahb_bus.cb;
		reset = 0;
		@ahb_bus.cb;

		t = new();

		// 10 back to back random writes with the following constraints:
		for(int i=0; i<10; i++) begin
			
			`SV_RAND_CHECK(
				t.randomize() with {HTRANS==HTRANS_NONSEQ; HWRITE==1; HADDR >= 0; HADDR <= 4; reset==0;}
			);

			ahb_bus.cb.HADDR <= t.HADDR;
			ahb_bus.cb.HTRANS <= t.HTRANS;
			reset <= t.reset;

			@ahb_bus.cb;

			ahb_bus.cb.HWRITE <= t.HWRITE;
			ahb_bus.cb.HWDATA <= t.HWDATA;
		end

		Transaction::dumpHistogram();

		// Display locations 0 to 4 of the memory array after the writes complete.
		reset <= 0;
		ahb_bus.cb.HTRANS <= 2'b10;
		ahb_bus.cb.HWRITE <= 0;
		@ahb_bus.cb;
		for(int i=0; i<=4; i++) begin
			ahb_bus.cb.HADDR <= i;
			@ahb_bus.cb;
			t.HRDATA = ahb_bus.cb.HRDATA;
			$display("At time %0t, a read at address %0d = %0h", $time, i, ahb_bus.cb.HRDATA);
		end


		// 10 back to back random reads with the same constraints
		for(int i=0; i<10; i++) begin
			
			`SV_RAND_CHECK(
				t.randomize() with {HTRANS==HTRANS_NONSEQ; HWRITE==0; HADDR >= 0; HADDR <= 4; reset==0;}
			);

			ahb_bus.cb.HADDR <= t.HADDR;
			ahb_bus.cb.HTRANS <= t.HTRANS;
			reset <= t.reset;

			@ahb_bus.cb;

			t.HRDATA = ahb_bus.cb.HRDATA;
		end

		Transaction::dumpHistogram();

		// 10 random transactions with only the constraints specified in 1. 
		// Random variables HWDATA and HWRITE are unconstrained
		old_HWRITE <= ahb_bus.cb.HWRITE;

		@ahb_bus.cb;

		for(int i=0; i<10; i++) begin
			`SV_RAND_CHECK(t.randomize());

			ahb_bus.cb.HADDR <= t.HADDR;
			ahb_bus.cb.HTRANS <= t.HTRANS;
			ahb_bus.cb.HWRITE <= t.HWRITE;
			reset <= t.reset;

			@ahb_bus.cb;

			ahb_bus.cb.HWDATA <= t.HWDATA;
			t.HRDATA = ahb_bus.cb.HRDATA;

			if (t.HWRITE != old_HWRITE) begin
				@ahb_bus.cb;
			end
			old_HWRITE <= ahb_bus.cb.HWRITE;
		end

		repeat (2) @ahb_bus.cb;

		Transaction::dumpHistogram();

		$stop;
	end


endprogram : test