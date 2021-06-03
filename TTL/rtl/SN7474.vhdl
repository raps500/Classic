--!
--! D flip flop with preset and clear
--!

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SN7474 is
    Port ( 
        D       : in  STD_LOGIC;
        C       : in  STD_LOGIC;
        nS      : in  STD_LOGIC;
        nR      : in  STD_LOGIC;
        Q       : out  STD_LOGIC;
        nQ      : out  STD_LOGIC
        );
end SN7474;

architecture logic of SN7474 is
    signal bit : std_logic := '0';
begin
    process (C, nS, nR)
    begin
        if nS = '0' then
            bit <= '1';
        elsif nR = '0' then
            bit <= '0';
        elsif rising_edge(C) then
            bit <= D;
        end if;
    end process;

    Q <= bit;
    nQ <= not bit;
end architecture logic;

