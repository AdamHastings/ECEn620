`default_nettype none
`timescale 1 ns / 1 ps


module Testbench;
  
  //////////////////////////////////////////////////////
  
  /* Declare shared signals */
  bit clk = 0;
  bit reset = 0;
  bit signed [3:0] A, B;
  bit signed [4:0] C;
  bit [1:0] Opcode;  
  
  /* Instantiate the DUT */
  ALU_4_bit DUT_alu(.*);

  //////////////////////////////////////////////////////
  
  /* Generate a clock */
  integer clk_period = 10;
  integer clk_delay = clk_period/2;
  always 
  begin
    #clk_delay clk=~clk;
  end
  
  //////////////////////////////////////////////////////
  
  /* Signals used in tests */
  logic [4:0] functionrtn;
  integer err_cnt = 0;
  integer start_time = get_time();
  integer end_time;
  integer seconds;
  integer combinations = 0;
  
  /* Run the tests */
  initial
  begin
    // For all values of reset
    for (int r = 0; r <= 1'b1; r = r + 1) begin
      reset = r;
      // For all values of Opcode
      for (int o = 0; o <= 2'b11; o = o + 1) begin
        Opcode = o;
        // For all values of A
        for (int a = 0; a <= 4'b1111; a = a + 1) begin
          A = a;
          // For all values of B
          for (int b = 0; b <= 4'b1111; b = b + 1) begin
            B = b;
            
            //Compute expected value
            functionrtn = computeALUResult(A, B, Opcode, reset);
              
            // Uncomment to see a sample error message
            //if (r == 1 && o == 2 && A == 4 && B == 3) begin
            //  functionrtn = 2;
            //end
              
            // Increment number of combinations tested
            combinations = combinations + 1;
            
            // Wait for falling edge of clock and compare
            @ (negedge clk);
            assert (C === functionrtn) else begin
              // An error was found
              $error("At %0t ns: ", $time/1000);
              $display("          Opcode: %x", Opcode);
              $display("          A: %x", A);
              $display("          B: %x", B);
              $display("          From DUT: C = %x", C);
              $display("          Expected: C = %x", functionrtn);
              err_cnt = err_cnt + 1;
            end
          end
        end
      end
    end 
    
    // Compute total time taken
    end_time = get_time();
    seconds = end_time - start_time;
    
    // Print results
    $display("");
    $display("RESULTS:");
    $display("");
    $display("------------------------------------------------");
    $display("--   Elapsed time (s)           : %0d", seconds);
    $display("--   Simulation time (ns)       : %0d", $time/1000);
    $display("--   Input combinations tested  : %0d", combinations);
    $display("--   Errors found               : %0d", err_cnt);
    $display("------------------------------------------------");
    $display("");
    if (err_cnt == 0) begin
      $display("=== ALL TESTS PASSED ===");
    end else begin
      $display("=== TESTBENCH FAILED ===");
    end
    $display("");
    $stop;
        
  end
  
  //////////////////////////////////////////////////////
  
  
  typedef enum {Add=0, Sub=1, Not_A=2, ReductionOR_B=3, Reset}  CodeName;
  bit signed [4:0] result; 
  CodeName op;
  
  /* Software simulation of device specifications */
  function bit signed [4:0] computeALUResult(input bit signed [3:0] A, B, input bit [1:0] Opcode, input bit reset);
    
    // Assign op to correct value, according to ALU_4_bit specs
    if (reset) begin
      op = Reset;
    end else begin
      op = CodeName'(Opcode);
    end
    
    // Perform the desired operation
    unique case (op)
      Add           : result = A + B;
      Sub           : result = A - B;
      Not_A         : result = ~A;
      ReductionOR_B : result = |B;
      Reset         : result = 0;
      default       : $error("Unknown Opcode found");
    endcase  
    return result;
  endfunction
  
  //////////////////////////////////////////////////////
  
  /* Get the current wall-clock time in seconds */
  function integer get_time();
    int    file_pointer;
     
    //Stores time and date to file sys_time
    void'($system("date +%s > sys_time"));
    //Open the file sys_time with read access
    file_pointer = $fopen("sys_time","r");
    //assin the value from file to variable
    void'($fscanf(file_pointer,"%d",get_time));
    //close the file
    $fclose(file_pointer);
    void'($system("rm sys_time"));
  endfunction
  
  //////////////////////////////////////////////////////
   
endmodule