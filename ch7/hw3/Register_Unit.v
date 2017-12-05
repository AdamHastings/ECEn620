////////////////////////////////////////////////
// Purpose: Register unit for RISC_SPM
// Author: Mike Ciletti with heavy modification
//
// REVISION HISTORY:
// $Log: Register_Unit.v,v $
// Revision 1.1  2011/05/31 16:32:52  tumbush.tumbush
// Check into cloud repository.
//
// Revision 1.1  2011/03/20 20:43:01  Greg
// Initial check in
//
////////////////////////////////////////////////
`default_nettype none
  module Register_Unit #(parameter word_size = 8)
   	      (output reg[word_size-1: 0]   data_out,
   	       input  wire [word_size-1: 0] data_in,
   	       input  wire		    load, clk,
           input  wire rst  // Active low asynchronous reset
   	       );        
   
   // if load is asserted register data_in
   always @ (posedge clk or negedge rst) begin
      if (rst == 0) 
	       data_out <= 0; 
      else if (load) 
	       data_out <= data_in;
   end

endmodule

