library verilog;
use verilog.vl_types.all;
entity risc_spm_iface is
    generic(
        ADDRESS_WIDTH   : integer := 8
    );
    port(
        clk             : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ADDRESS_WIDTH : constant is 1;
end risc_spm_iface;
