library verilog;
use verilog.vl_types.all;
entity ALU_4_bit is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        Opcode          : in     vl_logic_vector(1 downto 0);
        A               : in     vl_logic_vector(3 downto 0);
        B               : in     vl_logic_vector(3 downto 0);
        C               : out    vl_logic_vector(4 downto 0)
    );
end ALU_4_bit;
