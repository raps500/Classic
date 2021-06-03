library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SN74157 is
    Port ( 
        IA : in  STD_LOGIC_VECTOR (1 downto 0);
        IB : in  STD_LOGIC_VECTOR (1 downto 0);
        IC : in  STD_LOGIC_VECTOR (1 downto 0);
        ID : in  STD_LOGIC_VECTOR (1 downto 0);
         S : in  STD_LOGIC;
         E : in  STD_LOGIC;
         Z : out  STD_LOGIC_VECTOR (3 downto 0)
        );
end SN74153;

architecture logic of SN74153 is

    signal inta : std_logic;
    signal intb : std_logic;
    signal intc : std_logic;
    signal intd : std_logic;

begin

    inta <= IA(0) when S = '0' else IA(1);
    intb <= IA(0) when S = '0' else IA(1);
    intc <= IA(0) when S = '0' else IA(1);
    intd <= IA(0) when S = '0' else IA(1);
                 
    --output
    Z(0) <= inta when (E = '0') else '0';
    Z(1) <= intb when (E = '0') else '0';
    Z(2) <= intc when (E = '0') else '0';
    Z(3) <= intd when (E = '0') else '0';

end architecture logic;

