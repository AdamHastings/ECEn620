library verilog;
use verilog.vl_types.all;
entity sram_control is
    generic(
        IDLE            : vl_logic_vector(0 to 1) := (Hi0, Hi0);
        WRITE           : vl_logic_vector(0 to 1) := (Hi0, Hi1);
        READ            : vl_logic_vector(0 to 1) := (Hi1, Hi0);
        HTRANS_IDLE     : vl_logic_vector(0 to 1) := (Hi0, Hi0);
        HTRANS_NONSEQ   : vl_logic_vector(0 to 1) := (Hi1, Hi0)
    );
    port(
        reset           : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of IDLE : constant is 1;
    attribute mti_svvh_generic_type of WRITE : constant is 1;
    attribute mti_svvh_generic_type of READ : constant is 1;
    attribute mti_svvh_generic_type of HTRANS_IDLE : constant is 1;
    attribute mti_svvh_generic_type of HTRANS_NONSEQ : constant is 1;
end sram_control;
