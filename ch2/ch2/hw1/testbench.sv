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
	integer err_cnt = 0;

  logic [15:0] address_array [];
  logic [7:0] data_to_write_array[];
  logic [8:0] data_read_expect_assoc [logic[15:0]];
  logic[8:0] data_read_queue [$];

	initial begin
 

		address_array = new[6];
		data_to_write_array = new[6];

                
		for (i = 0; i < 6; i++) begin
			address_array[i] = $random;
			data_to_write_array[i] = $random;
			data_read_expect_assoc[address_array[i]] = data_to_write_array[i]; 
		end
		
		test_traverse();

		$display("Data read Queue:");
		for (i = 0; i < 6; i++) begin
			$display("  -- data_read_queue[%0d]: %0h", i, data_read_queue[i]);
		end

		$display("\nError count: %0d", err_cnt);
	end

	task test_traverse ();
	  
	  logic [8:0] assoc_arr_element;
	  logic [8:0] data_rd_q_element;
	  
	  // Put in values and read output
	  for (i = 0; i < 6; i++) begin
      data_in = data_to_write_array[i];
      address = address_array[i];
      #clk_delay;
      data_read_queue.push_back(data_out);   
    end
    
    
    // Compare data_read_queue to data_read_expect_assoc
    //for (i = 0; i < 6; i++) begin
    //  $display("%d", data_read_queue.next())
    
    //assoc_arr_element = data_read_expect_assoc.first();
    //data_rd_q_element = data_read_queue.first();
    
    //if (data_read_expect_assoc.first(address_array[0]) && data_read_queue.first()) begin

	endtask

endmodule
