////////////////////////////////////////////////////////////////////////////////
// Purpose: Opcode definition for RISC_SPM design
// Author: Mike Ciletti with heavy modification
//
// REVISION HISTORY:
// $Log: opcodes_include.v,v $
// Revision 1.1  2011/05/31 16:32:52  tumbush.tumbush
// Check into cloud repository.
//
// Revision 1.1  2011/03/20 20:43:01  Greg
// Initial check in
//
////////////////////////////////////////////////////////////////////////////////
  // Define the Opcodes
  parameter NOP 	= 4'b0000;
  parameter ADD 	= 4'b0001;
  parameter SUB 	= 4'b0010;
  parameter AND 	= 4'b0011;
  parameter NOT 	= 4'b0100;
  parameter RD  	= 4'b0101;
  parameter WR		= 4'b0110;
  parameter BR		= 4'b0111;
  parameter BRZ 	= 4'b1000;
  parameter RDI = 4'b1001;
