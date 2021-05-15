library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SN74153 is
    Port ( 
        I0 : in  STD_LOGIC_VECTOR (3 downto 0);
        I1 : in  STD_LOGIC_VECTOR (3 downto 0);
         S : in  STD_LOGIC_VECTOR (1 downto 0);
        nE0 : in  STD_LOGIC;
        nE1 : in  STD_LOGIC;
        Y0 : out  STD_LOGIC;
        Y1 : out  STD_LOGIC
        );
end SN74153;

architecture logic of SN74153 is

    signal intern0 : std_logic;
    signal intern1 : std_logic;

begin

    with S select
    intern0 <=  I0(0) when "00",
                I0(1) when "01",
                I0(2) when "10",
                I0(3) when "11",
                 'X'  when others;
    with S select
    intern1 <=  I1(0) when "00",
                I1(1) when "01",
                I1(2) when "10",
                I1(3) when "11",
                 'X'  when others;
                            
    --output
    Y0 <= intern0 when (nE0 = '0') else '0';
    Y1 <= intern1 when (nE1 = '0') else '0';

end architecture logic;

