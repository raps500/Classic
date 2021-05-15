
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SN74163_tb is

end SN74163_tb;

architecture logic of SN74163_tb is
    component SN74163 is 
        port ( 
            D    : in  STD_LOGIC_VECTOR (3 downto 0);
            LOAD : in  STD_LOGIC;
            nCLR : in  STD_LOGIC;
            CLK  : in  STD_LOGIC;
            ENP  : in  STD_LOGIC;
            ENT  : in  STD_LOGIC;
            RCO  : out STD_LOGIC;
            Q    : out STD_LOGIC_VECTOR (3 downto 0)
    );
    end component SN74163;
         
    signal  D    : STD_LOGIC_VECTOR (3 downto 0);
    signal  LOAD : STD_LOGIC;
    signal  nCLR : STD_LOGIC;
    signal  CLK  : STD_LOGIC;
    signal  ENP  : STD_LOGIC;
    signal  ENT  : STD_LOGIC;
    signal  RCO  : STD_LOGIC;
    signal  Q   : STD_LOGIC_VECTOR (3 downto 0);
    
begin

    
    SN74163i : SN74163 port map(
        D    => D   ,
        LOAD => LOAD,
        nCLR => nCLR,
        CLK  => CLK ,
        ENP  => ENP ,
        ENT  => ENT ,
        RCO  => RCO ,
        Q    => Q   
    );
    
    process 
        begin
            CLK        <= '0';
            wait for 500 ns;
            CLK        <= '1';
            wait for 500 ns;
        end process;
        
    process 
        begin
            nCLR <= '1';
            LOAD <= '0';
            ENP <= '0';
            ENT <= '0';
            D <= "1010";
            wait for 2222 ns;
            nCLR <= '0';
            wait for 222 ns;
            nCLR <= '1';
            wait for 2222 ns;
            ENP <= '1';
            wait for 333 ns;
            ENT <= '1';
            wait for 2222 ns;
            LOAD <= '1';
            wait for 521 ns;
            LOAD <= '0';
            wait for 7335 ns;
            ENT <= '0';
            wait;
        end process;
        
end architecture logic;




