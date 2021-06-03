
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SN74191_tb is

end SN74191_tb;

architecture logic of SN74191_tb is
    component SN74191 is
        Port ( 
            P   : in  STD_LOGIC_VECTOR (3 downto 0);
            nPL : in  STD_LOGIC;  --! latches on the falling flank
            nUD : in  STD_LOGIC;  --! 0 = down, 1 = up
            nCE : in  STD_LOGIC;
            CP  : in  STD_LOGIC;
            Q   : out  STD_LOGIC_VECTOR (3 downto 0)
            );
    end component SN74191;
         
    signal  P   : STD_LOGIC_VECTOR (3 downto 0);
    signal  nPL : STD_LOGIC;
    signal  nUD : STD_LOGIC;
    signal  nCE : STD_LOGIC;
    signal  CP  : STD_LOGIC;
    signal  Q   : STD_LOGIC_VECTOR (3 downto 0);
    
begin

    
    SN74191i : SN74191 port map(
        P   => P  ,
        nPL => nPL,
        nUD => nUD,
        nCE => nCE,
        CP  => CP ,
        Q   => Q    
    );
    
    process 
        begin
            CP        <= '0';
            wait for 500 ns;
            CP        <= '1';
            wait for 500 ns;
        end process;
        
    process 
        begin
            nPL <= '1';
            nCE <= '1';
            nUD <= '0'; --! count up
            P <= "1010";
            wait for 250 ns;
            nPL <= '0';
            wait for 500 ns;
            nPL <= '1';
            wait for 2500 ns;
            nCE <= '0';
            wait for 2500 ns;
            P <= "1111";
            nPL <= '0';
            nUD <= '1'; --! count down
            wait for 500 ns;
            nPL <= '1';
            wait for 5000 ns;
            wait;
        end process;
        
end architecture logic;




