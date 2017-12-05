////////////////////////////////////////////////
// Purpose: RISC_SPM top level
// Author: Mike Ciletti with heavy modification
//
// REVISION HISTORY:
// $Log: RISC_SPM.v,v $
// Revision 1.1  2011/05/31 16:32:52  tumbush.tumbush
// Check into cloud repository.
//
// Revision 1.1  2011/03/20 20:43:01  Greg
// Initial check in
//
////////////////////////////////////////////////
`default_nettype none
  module RISC_SPM #(parameter word_size = 8, parameter Sel1_size = 3, parameter Sel2_size = 2) 
                  (
		   input wire clk, 
		   input wire rst,  // Active low asynchronous reset
		   input wire [word_size-1: 0] data_out, // Read data from memory unit - input
  
		   output wire [word_size-1: 0] address,  // Address to read/write - output
		   output wire [word_size-1: 0] data_in,  // Write data to memory unit - output
		   output wire write     // Write flag to memory unit - output
		   );

   
  wire [Sel1_size-1: 0] Sel_Bus_1_Mux; // select for mux1
  wire [Sel2_size-1: 0] Sel_Bus_2_Mux; // select for mux2

  wire Zflag;                        // Zero flag
  wire [word_size-1: 0] instruction; // Contains {opcode, src, dest} or address
   wire [word_size-1: 0] Bus_1;       // Output of mux_1 
  wire [word_size-1: 0] mem_word;    // Data output of memory unit
   
  // Control Nets
  wire Load_R0, Load_R1, Load_R2, Load_R3, Load_PC, Inc_PC; // Load enables for registers
  wire Load_IR, Load_Add_R, Load_Reg_Y, Load_Reg_Z;         // Load enables for registers

   assign mem_word = data_out;
   assign data_in = Bus_1;
   
   // The CPU which is a datapath plus ALU
  Processing_Unit Processor (.instruction(instruction), .Zflag(Zflag), .address(address), .Bus_1(Bus_1), 
                             .mem_word(mem_word), .Load_R0(Load_R0), .Load_R1(Load_R1), .Load_R2(Load_R2), 
                             .Load_R3(Load_R3), .Load_PC(Load_PC), .Inc_PC(Inc_PC), .Sel_Bus_1_Mux(Sel_Bus_1_Mux), 
                             .Load_IR(Load_IR), .Load_Add_R(Load_Add_R), .Load_Reg_Y(Load_Reg_Y),
                             .Load_Reg_Z(Load_Reg_Z), .Sel_Bus_2_Mux(Sel_Bus_2_Mux), .clk(clk), .rst(rst));

  // State machine to control everything
   Control_Unit Controller (.Load_R0(Load_R0), .Load_R1(Load_R1), .Load_R2(Load_R2), .Load_R3(Load_R3), 
                            .Load_PC(Load_PC), .Inc_PC(Inc_PC), .Load_IR(Load_IR), .Load_Add_R(Load_Add_R), 
                            .Load_Reg_Y(Load_Reg_Y), .Load_Reg_Z(Load_Reg_Z), .write(write), 
                            .Sel_Bus_1_Mux(Sel_Bus_1_Mux), .Sel_Bus_2_Mux(Sel_Bus_2_Mux), 
                            .instruction(instruction), .Zflag(Zflag), .clk(clk), .rst(rst));

   /*
  // The memory unit where data and instructions are stored
  Memory_Unit SRAM (
    .data_out(mem_word), 
    .data_in(Bus_1), 
    .address(address), 
    .clk(clk),
    .write(write) );
    */
    
endmodule 


