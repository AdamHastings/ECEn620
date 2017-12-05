package my_package;

	parameter HTRANS_IDLE = 2'b00;
	parameter HTRANS_NONSEQ = 2'b10; 

	// Create a class to encapsulate the AHB transactions.	
	class Transaction;

		rand bit [20:0] HADDR;
		rand bit HWRITE;
		rand bit [1:0] HTRANS;
		rand bit [7:0] HWDATA;
		bit	[7:0] HRDATA;

		rand bit reset;

		// The address (HADDR) to be in the lower 5 addresses and upper 5 addresses each 
		// with probability 40% and the other addresses with probability 20%.
		constraint haddr_dist {
			HADDR dist {[0:4] :/ 40, [5:2097146] :/ 20, [2097147:2097151] :/ 40};
		}

		// HTRANS to NONSEQ (HTRANS = 2’b10) and IDLE (HTRANS = 2’b00)
		constraint htrans_const {
			(HTRANS == HTRANS_IDLE) || (HTRANS == HTRANS_NONSEQ);
		}

		// The reset to assert 10% of the time.
		constraint reset_dist {
			reset dist {0 := 90, 1 := 10};
		}

		// static associative array to be used as a histogram
		static int addr_hist [bit[20:0]];
		static int hwrite_hist [bit];
		static int htrans_hist [bit[1:0]];
		static int hwdata_hist [bit[7:0]];
		static int reset_hit [bit];

		function void post_randomize();
			addr_hist[HADDR]++;
			hwrite_hist[HWRITE]++;
			htrans_hist[HTRANS]++;
			hwdata_hist[HWDATA]++;
			reset_hit[reset]++;
		endfunction : post_randomize

		static function void dumpHistogram();

			int a=0, b=0, c=0, d=0;
			foreach(addr_hist[i]) begin
				if (i <= 4) begin
					a += addr_hist[i];
				end else if (i >= 2097147) begin
					c += addr_hist[i];
				end else begin
					b += addr_hist[i];
				end
			end

			$display("\nHADDR distribution:");
			$display("	Between 0 and 4 (inclusive) %0d%% of the time", a*10);
			$display("	Between 5 and 2097146 (inclusive) %0d%% of the time", b*10);
			$display("	Between 2097147 and 2097151 (inclusive) %0d%% of the time", c*10);

			$display("\nHWRITE distribution:");
			$display("	Equal to 0 %0d%% of the time", hwrite_hist[0]*10);
			$display("	Equal to 1 %0d%% of the time", hwrite_hist[1]*10);

			$display("\nHTRANS distribution:");
			$display("	Equal to IDLE %0d%% of the time", htrans_hist[0]*10);
			$display("	Equal to NONSEQ %0d%% of the time", htrans_hist[2]*10);

			a=0;
			b=0;
			c=0;
			d=0;
			foreach(hwdata_hist[i]) begin
				if (i < 64) begin
					a += hwdata_hist[i];
				end else if (i < 128) begin
					b += hwdata_hist[i];
				end else if (i < 192) begin
					c += hwdata_hist[i];
				end else begin
					d += hwdata_hist[i];
				end
			end

			$display("\nHWDATA distribution:");
			$display("	Between 0 and 63 (inclusive) %0d%% of the time", a*10);
			$display("	Between 64 and 127 (inclusive) %0d%% of the time", b*10);
			$display("	Between 128 and 191 (inclusive) %0d%% of the time", c*10);
			$display("	Between 192 and 255 (inclusive) %0d%% of the time", d*10);

			$display("\nreset distribution:");
			$display("	Equal to 0 %0d%% of the time", reset_hit[0]*10);
			$display("	Equal to 1 %0d%% of the time", reset_hit[1]*10);

			$display("");


			addr_hist.delete();
			hwrite_hist.delete();
			htrans_hist.delete();
			hwdata_hist.delete();
			reset_hit.delete();
		endfunction : dumpHistogram

	endclass : Transaction

endpackage : my_package