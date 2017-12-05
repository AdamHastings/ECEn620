////////////////////////////////////////////////
// Purpose: ALU for RISC_SPM
// Author: Mike Ciletti with heavy modification
//
// REVISION HISTORY:
// $Log: Alu_RISC.v,v $
// Revision 1.1  2011/05/31 16:32:52  tumbush.tumbush
// Check into cloud repository.
//
// Revision 1.1  2011/03/20 20:43:01  Greg
// Initial check in
//
////////////////////////////////////////////////
/*ALU Instruction		Action
ADD			Adds the datapaths to form data_1 + data_2.
SUB			Subtracts the datapaths to form data_1 - data_2.
AND			Takes the bitwise-and of the datapaths, data_1 & data_2.
NOT			Takes the bitwise Boolean complement of data_2.
*/
// Note: the carries are ignored in this model.
 
  module Alu_RISC #(parameter word_size = 8, op_size = 4)
                  (output wire               	     alu_zero_flag, // ALU=0
                   output reg  [word_size-1: 0] alu_out,          // Output of ALU
                   input  wire [word_size-1: 0] data_2, data_1,         // Input data
                   input  wire [op_size-1: 0]     opcode            // Opcode to execute
		   );
  `include "opcodes_include.v" 

  assign  alu_zero_flag = ~|alu_out;
  always @ (opcode or data_1 or data_2)  
     case  (opcode)
      NOP:	alu_out = 0;
      ADD:	alu_out = data_1 + data_2;  // Reg_Y + Bus_1
      SUB:	alu_out = data_2 - data_1;
      AND:	alu_out = data_1 & data_2;
      NOT:	alu_out = ~ data_2;	 // Gets data from Bus_1
      default: 	alu_out = 0;
    endcase 
endmodule
