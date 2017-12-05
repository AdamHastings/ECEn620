program automatic test();

	import env_pkg::*;
	Environment env;
	Driver_cbs_cov dcc;

	initial begin
		env = new();
		env.gen_cfg();
		env.build();
		dcc = new();
		env.drv.cbs.push_back(dcc);
		env.run();
		env.wrap_up();
		$stop;
	end

endprogram 
