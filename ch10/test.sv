program automatic test();

	parameter ADDRESS_WIDTH = 8;
	import env_pkg::*;
	import CovPort_pkg::*;
	Environment #(ADDRESS_WIDTH) env;
	Driver_cbs_cov #(ADDRESS_WIDTH) dcc;

	initial begin
		env = new();
		env.build();
		dcc = new();
		env.drv.cbs.push_back(dcc);
		env.run();
		env.wrap_up();
		$stop;
	end

endprogram 
