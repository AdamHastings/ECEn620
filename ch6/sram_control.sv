///////////////////////////////////////////////////////////////
// Purpose: DUT for Chap_6_Randomization/homework_solution
// Author: Greg Tumbush
//
// REVISION HISTORY:
// $Log: sram_control.sv,v $
// Revision 1.1  2011/05/29 19:10:04  tumbush.tumbush
// Check into cloud repository
//
// Revision 1.1  2011/03/20 19:09:52  Greg
// Initial check in
//
//////////////////////////////////////////////////////////////
`default_nettype none
  module sram_control(ahb_if ahb_bus, sram_if sram_bus, input wire reset);
  
  // Reg to assign data out values to
  reg [7:0] DQ_reg;
  
  parameter IDLE = 2'b00,
           WRITE = 2'b01,
           READ = 2'b10;
           
  parameter HTRANS_IDLE = 2'b00;
  parameter HTRANS_NONSEQ = 2'b10;        
  
  reg [1:0] current_state, next_state;
  
  assign sram_bus.DQ = DQ_reg;
  
   always @* begin
     // Defaults
     DQ_reg   = 8'hZ;
     sram_bus.CE_b = 1'b1; 
     sram_bus.WE_b = 1'b1; 
     sram_bus.OE_b = 1'b1;
     ahb_bus.HRDATA = 8'b0;
     case (current_state)
       IDLE: begin
         if (ahb_bus.HTRANS == HTRANS_NONSEQ) begin
           if (ahb_bus.HWRITE)
             next_state = WRITE;
           else
             next_state = READ;
         end
       else
         next_state = IDLE;
       end
       // Do the write on the SRAM
       WRITE: begin
         sram_bus.CE_b = 1'b0; 
         sram_bus.WE_b = 1'b0;
         DQ_reg = ahb_bus.HWDATA;
         if (ahb_bus.HTRANS == HTRANS_NONSEQ) begin
           if (ahb_bus.HWRITE)
             next_state = WRITE;
           else
             next_state = READ;
         end
       else
         next_state = IDLE;
       end
       // Do the read on the SRAM
       READ: begin
         sram_bus.CE_b = 1'b0; 
         sram_bus.OE_b = 1'b0;
         ahb_bus.HRDATA = sram_bus.DQ;
         if (ahb_bus.HTRANS == HTRANS_NONSEQ) begin
           if (ahb_bus.HWRITE)
             next_state = WRITE;
           else
             next_state = READ;
         end
       else
         next_state = IDLE;
       end
       default: next_state = IDLE;
     endcase
   end // always
   
   // Current_state = next state on the active edge of the clock
   always @(posedge ahb_bus.HCLK or posedge reset) begin
     if (reset)
       current_state <= IDLE;
     else
       current_state <= next_state;
   end
   
  // Delay the address by 1 clock cycle
  always @(posedge ahb_bus.HCLK or posedge reset) begin
     if (reset)
       sram_bus.A <= 21'b0;
     else
       sram_bus.A <= ahb_bus.HADDR;
  end
  
  //synopsys translate_off
  reg [95:0] ASCII_current_state;
  always @(current_state) begin
    case(current_state)
      IDLE: ASCII_current_state = "IDLE";
      WRITE: ASCII_current_state = "WRITE";
      READ: ASCII_current_state = "READ";
    endcase
  end 
  //synopsys translate_on
  
endmodule
  
  
  