package transaction_pkg;

	// Class to model a randomized transaction between test and DUT
	class Transaction;
		int port_number; // Port number should not be randomized
		rand bit en, req; // Randomized enable and request
	endclass : Transaction

endpackage : transaction_pkg