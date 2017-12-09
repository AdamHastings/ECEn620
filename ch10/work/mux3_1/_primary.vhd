library verilog;
use verilog.vl_types.all;
entity mux3_1 is
    generic(
        word_size       : integer := 8;
        sel_width       : integer := 2
    );
    port(
        data_in0        : in     vl_logic_vector;
        data_in1        : in     vl_logic_vector;
        data_in2        : in     vl_logic_vector;
        sel             : in     vl_logic_vector;
        data_out        : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of word_size : constant is 1;
    attribute mti_svvh_generic_type of sel_width : constant is 1;
end mux3_1;
