library verilog;
use verilog.vl_types.all;
entity config_reg is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        write           : in     vl_logic;
        data_in         : in     vl_logic_vector(15 downto 0);
        address         : in     vl_logic_vector(2 downto 0);
        data_out        : out    vl_logic_vector(15 downto 0)
    );
end config_reg;
