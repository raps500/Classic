
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SN74283_tb is

end SN74283_tb;

architecture logic of SN74283_tb is
    component SN74283 is 
        port ( 
            A    : in  STD_LOGIC_VECTOR (3 downto 0);
           B    : in  STD_LOGIC_VECTOR (3 downto 0);
           C4   : out  STD_LOGIC;
           C0   : out  STD_LOGIC;
           Q    : out  STD_LOGIC_VECTOR (3 downto 0)
    );
    end component SN74283;
         
    signal  A    : STD_LOGIC_VECTOR (3 downto 0);
    signal  B    : STD_LOGIC_VECTOR (3 downto 0);
    signal  C0   : STD_LOGIC;
    signal  C4   : STD_LOGIC;
    signal  Q   : STD_LOGIC_VECTOR (3 downto 0);
    
begin

    
    SN74283i : SN74283 port map(
        A    => A   ,
        B    => B   ,
        C0    => C0   ,
        C4    => C4   ,
        Q    => Q   
    );
        
    process 
        begin
            A <= "0000";
            B <= "0000";
            C0 <= '0';
            wait for 2222 ns;
            A <= "0000";
            B <= "0000";
            C0 <= '1';
            wait for 222 ns;
            A <= "0001";
            B <= "0010";
            C0 <= '0';
            wait for 222 ns;
            A <= "0001";
            B <= "1110";
            C0 <= '1';
            wait for 222 ns;
            A <= "1111";
            B <= "1111";
            C0 <= '1';
            wait for 2222 ns;
            wait;
        end process;
        
end architecture logic;




