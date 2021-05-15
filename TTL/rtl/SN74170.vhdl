
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SN74170 is
    Port ( D : in  STD_LOGIC_VECTOR (3 downto 0);
           RA : in  STD_LOGIC_VECTOR (1 downto 0);
           WA : in  STD_LOGIC_VECTOR (1 downto 0);
           nGR : in  STD_LOGIC;
           nGW : in  STD_LOGIC;
           Q : out  STD_LOGIC_VECTOR (3 downto 0)
    );
end SN74170;

architecture logic of SN74170 is
    type regfile_t is array (natural range 3 downto 0) of std_logic_vector(3 downto 0);
    signal regfile : regfile_t := (X"X", X"X", X"X", X"X" );
    signal RAC : std_logic_vector(3 downto 0);
    signal RT  : std_logic_vector(3 downto 0);
    signal RMQ : std_logic_vector(3 downto 0);
    signal RPC : std_logic_vector(3 downto 0);

begin
    -- read
	Q <= regfile(to_integer(unsigned(RA))) when nGR = '0' else X"F";
	
	-- debug
	RAC <= regfile(0);
	RT  <= regfile(1);
	RMQ <= regfile(2);
	RPC <= regfile(3);

    -- write
    process(WA, D, nGW) is
    begin
        if nGW = '0' then
            regfile(to_integer(unsigned(WA))) <= D;
        end if;
    end process;

end architecture logic;

