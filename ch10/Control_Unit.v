////////////////////////////////////////////////
// Purpose: Control unit for RISC_SPM
// Author: Mike Ciletti with heavy modification
//
// REVISION HISTORY:
// $Log: Control_Unit.v,v $
// Revision 1.1  2011/05/31 16:32:52  tumbush.tumbush
// Check into cloud repository.
//
// Revision 1.1  2011/03/20 20:43:01  Greg
// Initial check in
//
////////////////////////////////////////////////
`default_nettype none
  module Control_Unit #(parameter Sel1_size = 3, Sel2_size = 2, word_size = 8)
		      (
		       // Load enables for the registers
                       output reg Load_R0, Load_R1, Load_R2, Load_R3, Load_PC, 
                       output reg Inc_PC, Load_IR, Load_Add_R, Load_Reg_Y, 
                       output reg Load_Reg_Z,
		       
                       output reg write,                           // Flag indicating to write the memory unit
		       output wire [Sel1_size-1:0] Sel_Bus_1_Mux,  // select for mux1
		       output wire [Sel2_size-1: 0] Sel_Bus_2_Mux, // select for mux2
		       input wire [word_size-1: 0] instruction,    // Contains {opcode, src, dest}
                       input wire Zflag,                           // Zero flag 
                       input wire clk,
                       input wire rst                              // Active low asynchronous reset
                      );
   
   parameter op_size = 4;    // Need 4-Bits for opcode 
   parameter state_size = 4; // Need 4-bits for current state and next_state
   parameter src_size = 2, dest_size = 2; // Need 2-bits for the src and destination fields of the instruction
    
   // State Codes
   parameter S_idle = 0, S_fet1 = 1, S_fet2 = 2, S_dec = 3;
   parameter  S_ex1 = 4, S_rd1 = 5, S_rd2 = 6;  
   parameter S_wr1 = 7, S_wr2 = 8, S_br1 = 9, S_br2 = 10, S_halt = 11;
 
   // Source and Destination Codes  
   parameter R0 = 0, R1 = 1, R2 = 2, R3 = 3;  

   `include "opcodes_include.v" 

   reg [state_size-1: 0]   state, next_state;
   reg 			   Sel_ALU;   // Select ALU for Mux_2 
   reg                     Sel_Mem;   // Select Memory for Mux_2
   reg                     Sel_Bus_1; // Select Bus_1 for Mux_2 
   reg 			   Sel_R0, Sel_R1, Sel_R2, Sel_R3, Sel_PC;
   reg 			   err_flag;

   wire [op_size-1:0] 	   opcode = instruction [word_size-1: word_size - op_size];
   wire [src_size-1: 0]    src = instruction [src_size + dest_size -1: dest_size];
   wire [dest_size-1:0]    dest = instruction [dest_size -1:0];
   
   // Mux selectors
   assign  Sel_Bus_1_Mux[Sel1_size-1:0] = Sel_R0 ? 0:
					  Sel_R1 ? 1:
					  Sel_R2 ? 2:
					  Sel_R3 ? 3:
					  Sel_PC ? 4: 0;

   assign  Sel_Bus_2_Mux[Sel2_size-1:0] = Sel_ALU ? 0:
					  Sel_Bus_1 ? 1:
					  Sel_Mem ? 2: 0;

   always @ (posedge clk or negedge rst) begin
      if (rst == 0) 
	      state <= S_idle; 
      else 
	      state <= next_state; 
   end

   // Next state and output combinatorial logic
   always @* begin
   //always @ (state or opcode or Zflag) begin: Output_and_next_state 
      Sel_R0 = 0; 	Sel_R1 = 0;     	Sel_R2 = 0;    	Sel_R3 = 0;     	Sel_PC = 0;
      Load_R0 = 0; 	Load_R1 = 0; 	Load_R2 = 0; 	Load_R3 = 0;	Load_PC = 0;
      Load_IR = 0;	Load_Add_R = 0;	Load_Reg_Y = 0;	Load_Reg_Z = 0;
      Inc_PC = 0; 
      Sel_Bus_1 = 0; 
      Sel_ALU = 0; 
      Sel_Mem = 0; 
      write = 0; 
      err_flag = 0;	// Used for de-bug in simulation		
      next_state = state;

      case  (state)	
	       S_idle:		next_state = S_fet1;

        // Load address register with PC       
       	S_fet1:		begin       	  	  	
	        next_state = S_fet2; 
      	   Sel_PC = 1;
      	   Sel_Bus_1 = 1;
      	   Load_Add_R = 1; 
	     end
	
	// Read instruction from memory into IR, increment PC
	     S_fet2:		begin 		
	       next_state = S_dec; 
	       Sel_Mem = 1;
      	  Load_IR = 1; 
    	    Inc_PC = 1;
	    end

    	// Decode State
	   // Return to idle for NOP
     // Load  Reg_Y with src register for ADD/SUB/AND
     // Load Address Register with PC for RD/WR/BR/BRZ
	   S_dec:   case  (opcode) 
 		    NOP: next_state = S_fet1;
		   
		    ADD, SUB, AND: begin
 		      next_state = S_ex1;
		      Sel_Bus_1 = 1;
		      Load_Reg_Y = 1;
		      do_select(src, Sel_R0, Sel_R1, Sel_R2, Sel_R3, err_flag);
		   end // ADD, SUB, AND

		   NOT: begin
		      next_state = S_fet1;
		      Load_Reg_Z = 1;
		      Sel_ALU = 1;
          do_select(src, Sel_R0, Sel_R1, Sel_R2, Sel_R3, err_flag);
		      do_select(dest, Load_R0, Load_R1, Load_R2, Load_R3, err_flag);
		   end // NOT
  		   
		   RD, RDI: begin // New code for RDI
		      next_state = S_rd1;
		      Sel_PC = 1; Sel_Bus_1 = 1; Load_Add_R = 1; 
		   end // RD

		   WR: begin
		      next_state = S_wr1;
		      Sel_PC = 1; Sel_Bus_1 = 1; Load_Add_R = 1; 
		   end  // WR

		   BR: begin 
		      next_state = S_br1;  
		      Sel_PC = 1; Sel_Bus_1 = 1; Load_Add_R = 1; 
		   end  // BR
		   
  		   BRZ: begin
         if (Zflag == 1) begin
			     next_state = S_br1; 
			     Sel_PC = 1; Sel_Bus_1 = 1; Load_Add_R = 1; 
		     end
		     else begin 
			     next_state = S_fet1; 
			     Inc_PC = 1; 
		     end
		   end // BRZ
		   
  	    default : next_state = S_halt;
		 endcase  // (opcode)

	// Execute state for ADD, SUB, AND
    	S_ex1:		begin 
  	    next_state = S_fet1;
	     Load_Reg_Z = 1;
	     Sel_ALU = 1;
	     do_select(dest, Sel_R0, Sel_R1, Sel_R2, Sel_R3, err_flag);
       do_select(dest, Load_R0, Load_R1, Load_R2, Load_R3, err_flag);
	   end 

	// Load address register with memory output for RD
	// Load Register with memory output for RDI
    	S_rd1:		begin 
    	  if (opcode == RD) begin
         next_state = S_rd2;
	       Sel_Mem = 1;
	       Load_Add_R = 1; 
	       Inc_PC = 1;
	     end
	     else begin // RDI instruction - New code for RDI
	        next_state = S_fet1;
	        Inc_PC = 1;
	        Sel_Mem = 1;
	        do_select(dest, Load_R0, Load_R1, Load_R2, Load_R3, err_flag);
	     end
	   end

	// Load address register with memory output
    	S_wr1: 		begin
	     next_state = S_wr2;
	     Sel_Mem = 1;
	     Load_Add_R = 1; 
	     Inc_PC = 1;
	   end 

	// Do read and steer memory output to correct register
   	S_rd2:		begin 
  	   next_state = S_fet1;
	    Sel_Mem = 1;
	    do_select(dest, Load_R0, Load_R1, Load_R2, Load_R3, err_flag);
	  end

	// Do write to memory of correct register
    	S_wr2:		begin 
     next_state = S_fet1;
	   write = 1;
	   do_select(src, Sel_R0, Sel_R1, Sel_R2, Sel_R3, err_flag);
	end

	// Load address register with address containing branch location
    	S_br1:		begin 
	     next_state = S_br2; 
	     Sel_Mem = 1; 
	     Load_Add_R = 1; 
    end // S_br1

	// Load PC with memory output
    	S_br2:		begin 
	     next_state = S_fet1; 
	     Sel_Mem = 1; 
	     Load_PC = 1; 
	   end // S_br2
	
    	S_halt:  		next_state = S_halt;
	   default:		next_state = S_idle;
   endcase    
end // always

   // Build a decoder task
   task do_select(input [src_size-1: 0] sel,
		  output reg set_R0, set_R1, set_R2, set_R3, err_flag
		  );
		  begin
	      {set_R0, set_R1, set_R2, set_R3} = 0; 
	      err_flag = 0; 
	      case  (sel)
	        R0: 	set_R0 = 1; 
	        R1: 	set_R1 = 1; 
	        R2: 	set_R2 = 1;
	        R3: 	set_R3 = 1; 
	        default : 	err_flag = 1;
	      endcase  
	   end
   endtask
   
endmodule
