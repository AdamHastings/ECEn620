library verilog;
use verilog.vl_types.all;
entity arbiter is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        req0            : in     vl_logic;
        req1            : in     vl_logic;
        req2            : in     vl_logic;
        en0             : in     vl_logic;
        en1             : in     vl_logic;
        en2             : in     vl_logic;
        grant0          : out    vl_logic;
        grant1          : out    vl_logic;
        grant2          : out    vl_logic
    );
end arbiter;
