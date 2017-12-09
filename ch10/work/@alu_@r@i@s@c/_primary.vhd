library verilog;
use verilog.vl_types.all;
entity Alu_RISC is
    generic(
        word_size       : integer := 8;
        op_size         : integer := 4
    );
    port(
        alu_zero_flag   : out    vl_logic;
        alu_out         : out    vl_logic_vector;
        data_2          : in     vl_logic_vector;
        data_1          : in     vl_logic_vector;
        opcode          : in     vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of word_size : constant is 1;
    attribute mti_svvh_generic_type of op_size : constant is 1;
end Alu_RISC;
