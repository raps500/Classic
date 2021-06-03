--!
--! 3-line to 8-line decoders multiplexers
--!

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SN74138 is
    Port ( 
        A       : in  STD_LOGIC;
        B       : in  STD_LOGIC;
        C       : in  STD_LOGIC;
        G1      : in  STD_LOGIC;
        nG2A    : in  STD_LOGIC;
        nG2B    : in  STD_LOGIC;
        Y       : out  STD_LOGIC_VECTOR (7 downto 0)
        );
end SN74138;

architecture logic of SN74138 is
    signal en : std_logic;
begin
    en <= '1' when G1 = '1' and nG2A = '0' and nG2B = '1' else '0';
                 
    --output
    Y(0) <= '0' when (A = '0') and (B = '0') and (C = '0') and en = '1' else '1';
    Y(1) <= '0' when (A = '1') and (B = '0') and (C = '0') and en = '1' else '1';
    Y(2) <= '0' when (A = '0') and (B = '1') and (C = '0') and en = '1' else '1';
    Y(3) <= '0' when (A = '1') and (B = '1') and (C = '0') and en = '1' else '1';
    Y(4) <= '0' when (A = '0') and (B = '0') and (C = '1') and en = '1' else '1';
    Y(5) <= '0' when (A = '1') and (B = '0') and (C = '1') and en = '1' else '1';
    Y(6) <= '0' when (A = '0') and (B = '1') and (C = '1') and en = '1' else '1';
    Y(7) <= '0' when (A = '1') and (B = '1') and (C = '1') and en = '1' else '1';

end architecture logic;

