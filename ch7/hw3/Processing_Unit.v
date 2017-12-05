////////////////////////////////////////////////
// Purpose: Processing unit for RISC_SPM
// Author: Mike Ciletti with heavy modification
//
// REVISION HISTORY:
// $Log: Processing_Unit.v,v $
// Revision 1.1  2011/05/31 16:32:52  tumbush.tumbush
// Check into cloud repository.
//
// Revision 1.1  2011/03/20 20:43:01  Greg
// Initial check in
//
////////////////////////////////////////////////
`default_nettype none
module Processing_Unit #(parameter Sel1_size = 3, Sel2_size = 2, word_size = 8)
                        (output wire [word_size-1: 0]  Bus_1,            // Output of Mux_1
			                   output wire [word_size-1: 0] address,          // The location in memory to access  
			                   output wire [word_size-1: 0] instruction,      // Contains {opcode, src, dest} or address
			                   output wire Zflag,                              // Zero flag
			                   input wire [word_size-1: 0] mem_word,          // Data output of memory unit

			                   // Load enables for registers
                         input wire Load_R0, Load_R1, Load_R2, Load_R3, 
			                   input wire Load_IR, Load_Add_R, Load_Reg_Y,
			                   input wire Load_PC, Inc_PC, Load_Reg_Z,
			 
			                   input wire [Sel1_size-1: 0] Sel_Bus_1_Mux,     // select for mux1
                         input wire [Sel2_size-1: 0] Sel_Bus_2_Mux,     // select for mux2
			                   input wire clk, 
                         input wire rst                                 // Active low asynchronous reset
                         );
 

  parameter op_size = 4; // The size of an op-code

   // Internal signals
  wire [word_size-1: 0] R0_out, R1_out, R2_out, R3_out; // Register outputs
  wire [word_size-1: 0] Y_value, alu_out, Bus_2;
  reg  [word_size-1: 0] PC_count;
  wire 			alu_zero_flag;
  wire [op_size-1 : 0] 	opcode = instruction [word_size-1: word_size-op_size];

  // Instantiate any (word_size-1)-bit registers with 1 load condition
  Register_Unit R0 	  (.data_out(R0_out),  	   .data_in(Bus_2), .load(Load_R0),    .clk(clk), .rst(rst));
  Register_Unit R1 	  (.data_out(R1_out),  	   .data_in(Bus_2), .load(Load_R1),    .clk(clk), .rst(rst));
  Register_Unit R2 	  (.data_out(R2_out),  	   .data_in(Bus_2), .load(Load_R2),    .clk(clk), .rst(rst));
  Register_Unit R3 	  (.data_out(R3_out),  	   .data_in(Bus_2), .load(Load_R3),    .clk(clk), .rst(rst));
  Register_Unit Reg_Y 	  (.data_out(Y_value), 	   .data_in(Bus_2), .load(Load_Reg_Y), .clk(clk), .rst(rst));
  Register_Unit Reg_Add_R (.data_out(address),     .data_in(Bus_2), .load(Load_Add_R), .clk(clk), .rst(rst));
  Register_Unit Reg_instr (.data_out(instruction), .data_in(Bus_2), .load(Load_IR),    .clk(clk), .rst(rst));
  Register_Unit #(.word_size(1)) Reg_Zflag  (.data_out(Zflag), .data_in(alu_zero_flag), .load(Load_Reg_Z), .clk(clk), .rst(rst));
   
  Alu_RISC  ALU	(.alu_zero_flag(alu_zero_flag), .alu_out(alu_out), .data_2(Bus_1), .data_1(Y_value), .opcode(opcode));

   mux5_1 Mux_1(.data_in0(R0_out), .data_in1(R1_out), .data_in2(R2_out), .data_in3(R3_out), .data_in4(PC_count),
                .sel(Sel_Bus_1_Mux), .data_out(Bus_1));

   mux3_1 Mux_2(.data_in0(alu_out), .data_in1(Bus_1), .data_in2(mem_word), .sel(Sel_Bus_2_Mux), .data_out(Bus_2));

   // Load or increment Program_Counter (signal PC_Count)
   always @ (posedge clk or negedge rst) begin
      if (rst == 0) 
	       PC_count <= 0; 
      else if (Load_PC)
	       PC_count <= Bus_2; 
      else if  (Inc_PC)
        	PC_count <= PC_count +1;
   end

endmodule 

