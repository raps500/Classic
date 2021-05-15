
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TTLClassic_tb is

end TTLClassic_tb;

architecture logic of TTLClassic_tb is
    component TTLClassic_reg_alu is
        port (
            clk_in          : in  std_logic;
            -- Address, data bus
            data_in         : in  std_logic_vector(11 downto 0);
            data_o          : out  std_logic_vector(11 downto 0);
            addr_o          : out  std_logic_vector(11 downto 0);
            -- register file
            rd_addr_in      : in  std_logic_vector(1 downto 0);
            wr_addr_in      : in  std_logic_vector(1 downto 0);
            load_rf_n_in    : in  std_logic;
            -- input output regs control
            load_idr_in     : in  std_logic;
            load_odr_in     : in  std_logic;
            load_oar_in     : in  std_logic;
            -- alu control
            alu_s_in        : in  std_logic_vector(4 downto 0); -- bit 4 is M
            alu_mux_s_in    : in  std_logic_vector(1 downto 0);
            alu_mux_en_n_in : in  std_logic;
            -- carry
            load_l_in       : in  std_logic;
            set_carry_n_in  : in  std_logic;
            clr_carry_n_in  : in  std_logic;
            feed_carry_in   : in  std_logic;   -- feeds the carry to the ALU
            shift_in        : in  std_logic_vector(1 downto 0)  -- 000 : no shift, 001 : rar, 010 : lsr, 011 : asr, 100 : shl, 101 : ral
        );
    end component TTLClassic_reg_alu;
         
        signal clk_10MHz        : std_logic := '0';
        signal clk_12MHz        : std_logic := '0';
        signal clk_50MHz        : std_logic := '0';
        signal clk_1MHz         : std_logic := '0';
        signal resetn           : std_logic := '0'; -- pll locked used as reset signal, reset active low
        signal data_to_alu      : std_logic_vector(11 downto 0) := X"123";
        signal data_to_mem      : std_logic_vector(11 downto 0);
        signal addr             : std_logic_vector(11 downto 0);

        signal rd_addr          : std_logic_vector(1 downto 0) := "00";
        signal wr_addr          : std_logic_vector(1 downto 0) := "00";
        signal load_rf_n        : std_logic := '1';
        -- input output regs control
        signal load_idr         : std_logic := '0';
        signal load_odr         : std_logic := '0';
        signal load_oar         : std_logic := '0';
        -- alu control
        signal alu_s            : std_logic_vector(4 downto 0) := "00000"; -- bit 4 is M
        signal alu_mux_s        : std_logic_vector(1 downto 0) := "00";
		signal alu_mux_en_n     : std_logic := '1';
        -- carry
        signal load_l           : std_logic := '0';
        signal set_carry_n      : std_logic := '1';
        signal clr_carry_n      : std_logic := '1';
        signal feed_carry       : std_logic := '0';   -- feeds the carry to the ALU
        signal shift            : std_logic_vector(1 downto 0) := "00"; -- 00 : no shift, 01 : rar, 10 : asr, 11 : ral
 
begin
    alur : APDP8_reg_alu port map(

        clk_in          => clk_10MHz,
        -- Address, data bus
        data_in         => data_to_alu,
        data_o          => data_to_mem,
        addr_o          => addr,
        -- register file
        rd_addr_in      => rd_addr,
        wr_addr_in      => wr_addr,
        load_rf_n_in    => load_rf_n,
        -- input output regs control
        load_idr_in     => load_idr,
        load_odr_in     => load_odr,
        load_oar_in     => load_oar,
        -- alu control
        alu_s_in        => alu_s,
        alu_mux_s_in    => alu_mux_s,
        alu_mux_en_n_in => alu_mux_en_n,
        -- carry
        load_l_in       => load_l,
        set_carry_n_in  => set_carry_n,
        clr_carry_n_in  => clr_carry_n,
        feed_carry_in   => feed_carry,
        shift_in        => shift
    );

    
    process -- clk 10 MHz
        begin
            clk_10MHz        <= '0';
            wait for 50 ns;
            clk_10MHz        <= '1';
            wait for 50 ns;
        end process;
    -- Control
    process 
        begin
            wait for 111 ns;
            wr_addr <= "11"; -- PC
            alu_mux_en_n <= '1'; -- when the mux is off force 0 on the bus
            load_rf_n <= '0'; -- load PC
            wait for 111 ns;
            load_rf_n <= '1'; -- PC
            wait;
        end process;

        
end architecture logic;




