
`default_nettype none

module my_mem(
    input  wire clk,
    input  wire  write,
    input  wire read,
    input  wire [7:0] data_in,
    input  wire [15:0] address,
    output logic [8:0] data_out
);

  // Declare a 9-bit associative array using the logic data type
  logic [8:0] mem_array [logic [15:0]];

  always @(posedge clk) begin
    if (write)
      mem_array[address] = {getParity(data_in), data_in};
    else if (read)
      data_out =  mem_array[address];
  end

  function bit getParity(input logic [7:0] d_in);
    return ^d_in;
  endfunction : getParity


endmodule
