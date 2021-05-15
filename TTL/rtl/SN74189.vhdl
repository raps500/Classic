-- 74189
-- 16x4 fast RAM with tri state outputs

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SN74189 is
    Port ( D    : in  STD_LOGIC_VECTOR (3 downto 0);
           A    : in  STD_LOGIC_VECTOR (3 downto 0);
           nCS  : in  STD_LOGIC;
           nWE  : in  STD_LOGIC;
           nQ   : out  STD_LOGIC_VECTOR (3 downto 0)
    );
end SN74189;

architecture logic of SN74189 is
    type regfile_t is array (natural range 0 to 15) of std_logic_vector(3 downto 0);
    signal regfile : regfile_t := ( X"X", X"X", X"X", X"X", 
                                    X"X", X"X", X"X", X"X",  
                                    X"X", X"X", X"X", X"X",  
                                    X"X", X"X", X"X", X"X" 
                                    );
    signal RMQ : std_logic_vector(3 downto 0);
    signal RPC : std_logic_vector(3 downto 0);

begin
    -- read
	nQ <= not regfile(to_integer(unsigned(RA))) when nWE = '1' and nCS = '0' else "ZZZZ";
	
    -- write
    process(A, D, nWE, nCS) is
    begin
        if nCS = '0' and nWE = '0' then
            regfile(to_integer(unsigned(A))) <= D;
        end if;
    end process;

end architecture logic;

