
interface ahb_if(input bit clk);

	logic [7:0] HRDATA;
	logic [20:0] HADDR;
	logic HWRITE;
	logic [1:0] HTRANS;
	logic [7:0] HWDATA;
	logic HCLK;

endinterface : ahb_if