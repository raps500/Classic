--
-- synchronous up counter with clear
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity SN74393 is
    Port ( 
        MR  : in  STD_LOGIC;
        CP  : in  STD_LOGIC;
        Q   : out  STD_LOGIC_VECTOR (3 downto 0)
        );
end SN74393;

architecture logic of SN74393 is
    signal count : integer range 0 to 15 := 0;
begin
    process (CP, MR)
    begin
        if (MR = '1') then
            count <= 0;
        elsif rising_edge(CP) then
            count <= (count + 1) mod 16;
        end if;
    end process;
                
    --! output
    Q <= std_logic_vector(to_unsigned(count, 4));

end architecture logic;

