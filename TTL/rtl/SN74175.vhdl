--! 74175 quad D FlipFlop

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SN74175 is
    Port ( 
        nCLR    : in  STD_LOGIC;
        CLK     : in  STD_LOGIC;
        D       : in  STD_LOGIC_VECTOR (3 downto 0);
        Q       : out STD_LOGIC_VECTOR (3 downto 0);
        nQ      : out STD_LOGIC_VECTOR (3 downto 0)
        );
end SN74175;

architecture logic of SN74175 is

    signal id: std_logic_vector(3 downto 0) := "0000";
begin

    Q <= id;
    nQ <= not id;

    process (CLK, nCLR)
    begin
        if nCLR = '0' then
            id <= "0000";
        elsif rising_edge(CLK) then
            id <= D;
        end if;
    end process;

end architecture logic;

