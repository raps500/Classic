--!
--! 2-line to 4-line decoders multiplexers
--!

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SN74139 is
    Port ( 
        A       : in  STD_LOGIC;
        B       : in  STD_LOGIC;
        nG      : in  STD_LOGIC;
        Y       : out  STD_LOGIC_VECTOR (3 downto 0)
        );
end SN74139;

architecture logic of SN74139 is
    begin
    --output
    Y(0) <= '0' when (A = '0') and (B = '0') and (nG = '0') else '1';
    Y(1) <= '0' when (A = '1') and (B = '0') and (nG = '0') else '1';
    Y(2) <= '0' when (A = '0') and (B = '1') and (nG = '0') else '1';
    Y(3) <= '0' when (A = '1') and (B = '1') and (nG = '0') else '1';
    
end architecture logic;

