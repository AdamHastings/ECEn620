
module my_mem(my_mem_if.DUT if0);

  // Declare a 9-bit associative array using the logic data type
  logic [8:0] mem_array [logic [15:0]];

  always @(posedge if0.clk) begin
    if (if0.write)
      mem_array[if0.address] = {getParity(if0.data_in), if0.data_in};
    else if (rif0.ead)
      if0.data_out =  mem_array[if0.address];
  end

  function bit getParity(input logic [7:0] d_in);
    return ^d_in;
  endfunction : getParity


endmodule
