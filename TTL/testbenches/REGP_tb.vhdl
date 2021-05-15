
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity REGP_tb is

end REGP_tb;

architecture logic of REGP_tb is
    component REGP is
        Port ( 
            clk_in      : in STD_LOGIC; -- main clock for inc/dec and s
            reset_in    : in STD_LOGIC; -- clears P
            data_in     : in STD_LOGIC_VECTOR (3 downto 0); --! number to load or to compare to
            load_in     : in STD_LOGIC; --! load strobe
            cmp_eq_in   : in STD_LOGIC; --! compare for equality
            inc_in      : in STD_LOGIC; --! increment strobe
            dec_in      : in STD_LOGIC; --! decrement strobe
            cmp_res_o   : out STD_LOGIC; --! compare ouput: 1 = not equal, 0 = equal
            p_o         : out STD_LOGIC_VECTOR (3 downto 0) --! actual value of P
        );
    end component REGP;
    signal clk_in      : STD_LOGIC; -- main clock for inc/dec and s
    signal reset_in    : STD_LOGIC; -- clears P
    signal data_in     : STD_LOGIC_VECTOR (3 downto 0); --! number to load or to compare to
    signal load_in     : STD_LOGIC; --! load strobe
    signal cmp_eq_in   : STD_LOGIC; --! compare for equality
    signal inc_in      : STD_LOGIC; --! increment strobe
    signal dec_in      : STD_LOGIC; --! decrement strobe
    signal cmp_res_o   : STD_LOGIC; --! compare ouput: 1 = not equal, 0 = equal
    signal p_o         : STD_LOGIC_VECTOR (3 downto 0); --! actual value of P         

    
begin

    
    REGPi : REGP port map(
        clk_in     => clk_in     ,
        reset_in   => reset_in   ,
        data_in    => data_in    ,
        load_in    => load_in    ,
        cmp_eq_in  => cmp_eq_in  ,
        inc_in     => inc_in     ,
        dec_in     => dec_in     ,
        cmp_res_o  => cmp_res_o  ,
        p_o        => p_o        
    );
    
    process 
        begin
            clk_in        <= '0';
            wait for 500 ns;
            clk_in        <= '1';
            wait for 500 ns;
        end process;
        
    process 
        begin
            reset_in <= '0';
            data_in    <= X"3";
            load_in    <= '0';
            cmp_eq_in  <= '0';
            inc_in     <= '0';
            dec_in     <= '0';
            wait for 2400 ns;
            load_in <= '1';
            wait for 500 ns;
            load_in <= '0';
            wait for 1500 ns;
            inc_in <= '1';
            wait for 500 ns;
            inc_in <= '0';
            wait for 1500 ns;
            inc_in <= '1';
            wait for 500 ns;
            inc_in <= '0';
            wait for 1500 ns;
            inc_in <= '1';
            wait for 500 ns;
            inc_in <= '0';
            wait for 1500 ns;
            inc_in <= '1';
            wait for 500 ns;
            inc_in <= '0';
            wait for 1500 ns;
            inc_in <= '1';
            wait for 500 ns;
            inc_in <= '0';
            wait for 1500 ns;
            inc_in <= '1';
            wait for 500 ns;
            inc_in <= '0';
            wait for 1500 ns;
            inc_in <= '1';
            wait for 500 ns;
            inc_in <= '0';
            wait for 1500 ns;
            inc_in <= '1';
            wait for 500 ns;
            inc_in <= '0';
            wait for 1500 ns;
            inc_in <= '1';
            wait for 500 ns;
            inc_in <= '0';
            wait for 1500 ns;
            inc_in <= '1';
            wait for 500 ns;
            inc_in <= '0';
            wait for 1500 ns;
            inc_in <= '1';
            wait for 500 ns;
            inc_in <= '0';
            wait for 1500 ns;
            inc_in <= '1';
            wait for 500 ns;
            inc_in <= '0';
            wait for 1500 ns;
            inc_in <= '1';
            wait for 500 ns;
            inc_in <= '0';
            wait for 1500 ns;
            inc_in <= '1';
            wait for 500 ns;
            inc_in <= '0';
            wait for 1500 ns;
            inc_in <= '1';
            wait for 500 ns;
            inc_in <= '0';
            wait for 1500 ns;
            inc_in <= '1';
            wait for 500 ns;
            inc_in <= '0';
            wait for 1500 ns;
            dec_in <= '1';
            wait for 500 ns;
            dec_in <= '0';
            wait for 1500 ns;
            dec_in <= '1';
            wait for 500 ns;
            dec_in <= '0';
            wait for 1500 ns;
            dec_in <= '1';
            wait for 500 ns;
            dec_in <= '0';
            wait for 1500 ns;
            dec_in <= '1';
            wait for 500 ns;
            dec_in <= '0';
            wait for 1500 ns;
            dec_in <= '1';
            wait for 500 ns;
            dec_in <= '0';
            wait for 1500 ns;
            dec_in <= '1';
            wait for 500 ns;
            dec_in <= '0';
            wait for 1500 ns;
            dec_in <= '1';
            wait for 500 ns;
            dec_in <= '0';
            wait for 1500 ns;
            dec_in <= '1';
            wait for 500 ns;
            dec_in <= '0';
            wait for 1500 ns;
            dec_in <= '1';
            wait for 500 ns;
            dec_in <= '0';
            wait for 1500 ns;

            wait;
        end process;
        
end architecture logic;




