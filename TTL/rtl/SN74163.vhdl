-- 74163
-- 4 synchronous up/down counter

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SN74163 is
    Port ( D    : in  STD_LOGIC_VECTOR (3 downto 0);
           LOAD : in  STD_LOGIC;
           nCLR : in  STD_LOGIC;
           CLK  : in  STD_LOGIC;
           ENP  : in  STD_LOGIC;
           ENT  : in  STD_LOGIC;
           RCO  : out STD_LOGIC;
           Q    : out STD_LOGIC_VECTOR (3 downto 0)
    );
end SN74163;

architecture logic of SN74163 is
    signal FF : std_logic_vector(3 downto 0) := X"X";
    

begin
    -- read
	Q <= FF;
    RCO <= FF(3) and FF(2) and FF(1) and FF(0) and ENT;
	
    -- write
    process(CLK, nCLR) is
    begin
        if (nCLR = '0') then
            FF <= "0000";
        elsif rising_edge(CLK) then
            if (ENT = '1' and ENP = '1') then
                if LOAD = '1' then
                    FF <= D;
                else
                    FF <= std_logic_vector((unsigned(FF) + 1) mod 16);
                end if;
            end if;
        end if;
    end process;

end architecture logic;

