
interface sram_if(input bit clk);

	logic CE_b, WE_b, OE_b;
	logic [7:0] DQ;
	logic [20:0] A;

endinterface : sram_if