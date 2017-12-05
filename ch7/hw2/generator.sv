// Macro to check if randomization succeeded
`define SV_RAND_CHECK(r)\
	do begin\
		if (!(r)) begin\
			$display("%s:%0d: Randomization failed \"%s\"",\
				`__FILE__, `__LINE__, `"r`");\
			$finish;\
		end\
	end while (0)

task generator(	input int n,
				input mailbox #(Transaction) mbx);
	
	Transaction tr;
	repeat (n) begin
		tr = new();
		`SV_RAND_CHECK(tr.randomization());
		mbx.put(tr);
	end // repeat (n)
endtask : generator
