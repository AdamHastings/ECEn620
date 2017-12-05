////////////////////////////////////////////////
// Purpose: Clock_Unit for RISC_SPM
// Author: Mike Ciletti with heavy modification
//
// REVISION HISTORY:
// $Log: Clock_Unit.v,v $
// Revision 1.1  2011/05/31 16:32:52  tumbush.tumbush
// Check into cloud repository.
//
// Revision 1.1  2011/03/20 20:43:01  Greg
// Initial check in
//
////////////////////////////////////////////////
`default_nettype none
module Clock_Unit (output reg clock);
   parameter delay = 0;
   parameter half_cycle = 10;
   initial begin
      #delay clock = 0;
      forever #half_cycle clock = ~clock;
   end
endmodule
