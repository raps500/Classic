--
-- synchronous up/down counter with down/up mode control
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity SN74191 is
    Port ( 
        P   : in  STD_LOGIC_VECTOR (3 downto 0);
        nPL : in  STD_LOGIC;  --! latches on the falling flank
        nUD : in  STD_LOGIC;  --! 0 = down, 1 = up
        nCE : in  STD_LOGIC;
        CP  : in  STD_LOGIC;
        Q   : out  STD_LOGIC_VECTOR (3 downto 0)
        );
end SN74191;

architecture logic of SN74191 is

    signal count : integer range 0 to 15 := 0;


begin
    process (CP, nPL)
    begin
        if (nPL = '0') then
            count <= to_integer(unsigned(P));
        elsif rising_edge(CP) then
            if nCE = '0' then -- inhibit count
                if (nUD = '1') then -- down/up
                    count <= (count - 1) mod 16;
                else
                    count <= (count + 1) mod 16;
                end if;
            end if;
        end if;
    end process;
                
    --! output
    Q <= std_logic_vector(to_unsigned(count, 4));

end architecture logic;

