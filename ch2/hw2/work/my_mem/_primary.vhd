library verilog;
use verilog.vl_types.all;
entity my_mem is
    port(
        clk             : in     vl_logic;
        write           : in     vl_logic;
        read            : in     vl_logic;
        data_in         : in     vl_logic_vector(7 downto 0);
        address         : in     vl_logic_vector(15 downto 0);
        data_out        : out    vl_logic_vector(8 downto 0)
    );
end my_mem;
