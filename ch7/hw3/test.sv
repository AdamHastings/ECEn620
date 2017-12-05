program automatic test();

	import env_pkg::*;
	Environment env;

	initial begin
		env = new();
		env.gen_cfg();
		env.build();
		env.run();
		env.wrap_up();
		$stop;
	end

endprogram 
