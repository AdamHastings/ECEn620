library verilog;
use verilog.vl_types.all;
entity Control_Unit is
    generic(
        Sel1_size       : integer := 3;
        Sel2_size       : integer := 2;
        word_size       : integer := 8
    );
    port(
        Load_R0         : out    vl_logic;
        Load_R1         : out    vl_logic;
        Load_R2         : out    vl_logic;
        Load_R3         : out    vl_logic;
        Load_PC         : out    vl_logic;
        Inc_PC          : out    vl_logic;
        Load_IR         : out    vl_logic;
        Load_Add_R      : out    vl_logic;
        Load_Reg_Y      : out    vl_logic;
        Load_Reg_Z      : out    vl_logic;
        write           : out    vl_logic;
        Sel_Bus_1_Mux   : out    vl_logic_vector;
        Sel_Bus_2_Mux   : out    vl_logic_vector;
        instruction     : in     vl_logic_vector;
        Zflag           : in     vl_logic;
        clk             : in     vl_logic;
        rst             : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of Sel1_size : constant is 1;
    attribute mti_svvh_generic_type of Sel2_size : constant is 1;
    attribute mti_svvh_generic_type of word_size : constant is 1;
end Control_Unit;
