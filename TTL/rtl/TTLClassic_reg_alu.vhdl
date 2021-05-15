---
-- Ale's HP-35/HP-45 TTL implementation
-- Register/ALU
--
-- Uses models of discrete components '74, '153, '189, '283, 
--


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity TTLClassic_reg_alu is
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
        shift_in        : in  std_logic_vector(1 downto 0)  -- 00 : no shift, 01 : rar, 10 : asr, 11 : ral
	);
end entity TTLClassic_reg_alu;

architecture logic of TTLClassic_reg_alu is

    component IC7474_std_logic is
        Port ( D : in  STD_LOGIC;
                  CP : in  STD_LOGIC;
               Q : out  STD_LOGIC;
               nQ : out  STD_LOGIC;
               nSet : in  STD_LOGIC;
               nRes : in  STD_LOGIC);
    end component IC7474_std_logic;

    component SN74153 is
        Port ( 
            I0 : in  STD_LOGIC_VECTOR (3 downto 0);
            I1 : in  STD_LOGIC_VECTOR (3 downto 0);
             S : in  STD_LOGIC_VECTOR (1 downto 0);
            nE0 : in  STD_LOGIC;
            nE1 : in  STD_LOGIC;
            Y0 : out  STD_LOGIC;
            Y1 : out  STD_LOGIC
            );
    end component SN74153;

    component IC74181 is
        Port(
            --Modusbits
            S : in std_logic_vector (3 downto 0);
            --Modebit arith/logic
            M : in std_logic;
            --inputs
            A : in std_logic_vector (3 downto 0);
            B : in std_logic_vector (3 downto 0);
            C : in std_logic;
            --group CLA out
            G : out std_logic;
            P : out std_logic;
            --stats out
            C_4 : out std_logic;
            A_equ_B : out std_logic; --noch kein tristate!!!
            --outputs
            F : out std_logic_vector(3 downto 0)
        );
    end component IC74181;

    component SN74170 is
        Port ( D : in  STD_LOGIC_VECTOR (3 downto 0);
               RA : in  STD_LOGIC_VECTOR (1 downto 0);
               WA : in  STD_LOGIC_VECTOR (1 downto 0);
               nGR : in  STD_LOGIC;
               nGW : in  STD_LOGIC;
               Q : out  STD_LOGIC_VECTOR (3 downto 0)
        );
    end component SN74170;

    component IC74374 is
       generic ( width : integer := 8 );
       Port ( CP : in  STD_LOGIC;
              nOE : in  STD_LOGIC;
              D : in  STD_LOGIC_VECTOR (width-1 downto 0);
              O : out  STD_LOGIC_VECTOR (width-1 downto 0));
    end component IC74374;

    signal data_r_i         : std_logic_vector (11 downto 0);
    signal alu_mux_q        : std_logic_vector (11 downto 0);
    signal alu_q            : std_logic_vector (11 downto 0);
    signal alu_a            : std_logic_vector (11 downto 0);
    signal alu_b            : std_logic_vector (11 downto 0);
    signal rf_i             : std_logic_vector (11 downto 0);

    signal load_idr         : std_logic;
    signal load_odr         : std_logic;
    signal load_oar         : std_logic;
    signal alu_carry_q      : std_logic;
    
    signal alu_carry_0      : std_logic;
    signal alu_carry_1      : std_logic;
    signal alu_carry_i      : std_logic;
    signal load_l           : std_logic;
    signal L                : std_logic;
    signal bit_r            : std_logic; -- bit added on the right when shifting left (L, 0)
    signal bit_l            : std_logic; -- bit added on the left when shifting right (L, ALU_Q(11), 0)
    signal regl_i           : std_logic; -- input bit to L
    


begin

    -- input/output register
    
    idr0 : IC74374 port map(
        D => data_in(11 downto 4),
        O => data_r_i(11 downto 4),
        nOE => '0',
        CP => load_idr
    );
    idr1 : IC74374 generic map(width => 4)
    port map(
        D => data_in(3 downto 0),
        O => data_r_i(3 downto 0),
        nOE => '0',
        CP => load_idr
    );

    odr0 : IC74374 port map(
        D => alu_mux_q(11 downto 4),
        O => data_o(11 downto 4),
        nOE => '0',
        CP => load_odr
    );

    odr1 : IC74374 generic map(width => 4)
    port map(
        D => alu_mux_q(3 downto 0),
        O => data_o(3 downto 0),
        nOE => '0',
        CP => load_odr
    );

    oar0 : IC74374 port map(
        D => alu_mux_q(11 downto 4),
        O => addr_o(11 downto 4),
        nOE => '0',
        CP => load_oar
    );

    oar1 : IC74374 generic map(width => 4)
    port map(
        D => alu_mux_q(3 downto 0),
        O => addr_o(3 downto 0),
        nOE => '0',
        CP => load_oar
    );
    -- use the clock and the enables
    load_idr <= clk_in and load_idr_in;
    load_odr <= clk_in and load_odr_in;
    load_oar <= clk_in and load_oar_in;
    
    -- Register file
    rf0 : SN74170 port map
        (   
            D   => alu_mux_q(3 downto 0),
            RA  => rd_addr_in,
            WA  => wr_addr_in,
            nGR => '0',
            nGW => load_rf_n_in,
            Q   => alu_a(3 downto 0)
        );
    rf1 : SN74170 port map
        (   
            D   => alu_mux_q(7 downto 4),
            RA  => rd_addr_in,
            WA  => wr_addr_in,
            nGR => '0',
            nGW => load_rf_n_in,
            Q   => alu_a(7 downto 4)
        );
    rf2 : SN74170 port map
        (   
            D   => alu_mux_q(11 downto 8),
            RA  => rd_addr_in,
            WA  => wr_addr_in,
            nGR => '0',
            nGW => load_rf_n_in,
            Q   => alu_a(11 downto 8)
        );

    -- Carry
    load_l <= load_l_in and clk_in;
    regl : IC7474_std_logic 
        Port map 
        ( 
            D => regl_i,
            CP => load_l,
            Q   => L,
            nQ  => open,
            nSet => set_carry_n_in,
            nRes => clr_carry_n_in
        );
    -- L input mux
    -- FIXME: complement L is still missing
    lmux : SN74153 port map
    ( 
        I0  => alu_carry_q & alu_q(11) & alu_q(0) & alu_carry_q,
        I1  => "0000",
        S   => alu_mux_s_in,
        nE0 => '0',
        nE1 => '0',
        Y0  => regl_i,
        Y1  => open
    );

    --regl_i <= alu_q(0) when alu_mux_s_in = "10" else alu_q(11) when alu_mux_s_in = "01" else alu_carry_q;

    alu_carry_i <= feed_carry_in and L;

    -- ALU

    alu_a <= data_r_i;
    alu_b <= data_r_i;

    alu0 : IC74181 port map
        (
            --Modusbits
            S   => alu_s_in(3 downto 0),
            --Modebit arith/logic
            M   => alu_s_in(4),
            --inputs
            A   => alu_a(3 downto 0),
            B   => alu_b(3 downto 0),
            C   => alu_carry_i,
            --group CLA out
            G   => open,
            P   => open,
            --stats out
            C_4   => alu_carry_0,
            A_equ_B => open,
            --outputs
            F   => alu_q(3 downto 0)
        );

    alu1 : IC74181 port map
        (
            --Modusbits
            S   => alu_s_in(3 downto 0),
            --Modebit arith/logic
            M   => alu_s_in(4),
            --inputs
            A   => alu_a(7 downto 4),
            B   => alu_b(7 downto 4),
            C   => alu_carry_0,
            --group CLA out
            G   => open,
            P   => open,
            --stats out
            C_4   => alu_carry_1,
            A_equ_B => open,
            --outputs
            F   => alu_q(7 downto 4)
        );
    alu2 : IC74181 port map
        (
            --Modusbits
            S   => alu_s_in(3 downto 0),
            --Modebit arith/logic
            M   => alu_s_in(4),
            --inputs
            A   => alu_a(11 downto 8),
            B   => alu_b(11 downto 8),
            C   => alu_carry_1,
            --group CLA out
            G   => open,
            P   => open,
            --stats out
            C_4   => alu_carry_q,
            A_equ_B => open,
            --outputs
            F   => alu_q(11 downto 8)
        );
    -- ALU output MUX
    -- bits 0 and 1 (lsbs)
    -- shift_in encoding: 
    -- 00 : no shift, 01 : rar, 10 : asr, 11 : ral
    -- bit from right:
    --         0 when LSR, SHL (00)
    --         0 when RAR (01)
    --         0 when ASR (10)
    --         L when RAL (11)
    -- bit from the left:
    --         0 when LSR, SHL (00)
    --         L when RAR (01)
    -- alu_q(11) when ASR (10)
    --         0 when RAL (11)

    muxbits : SN74153 port map
    ( 
        I0  => L & "000", -- RAL gets L, the others 0
        I1  => '0' & alu_q(11) & L & '0',
        S   => shift_in,
        nE0 => '0',
        nE1 => '0',
        Y0  => bit_r,
        Y1  => bit_l
    );   
    
    amux0 : SN74153 port map
        ( 
            I0  => alu_q(6) & alu_q(1) &    bit_r & alu_q(0),
            I1  => alu_q(7) & alu_q(2) & alu_q(0) & alu_q(1),
            S   => alu_mux_s_in,
            nE0 => alu_mux_en_n_in,
            nE1 => alu_mux_en_n_in,
            Y0  => alu_mux_q(0),
            Y1  => alu_mux_q(1)
        );
    -- bits 0 and 1 (lsbs)
    amux1 : SN74153 port map
        ( 
            I0  => alu_q(8) & alu_q(3) & alu_q(1) & alu_q(2),
            I1  => alu_q(9) & alu_q(4) & alu_q(2) & alu_q(3),
            S   => alu_mux_s_in,
            nE0 => alu_mux_en_n_in,
            nE1 => alu_mux_en_n_in,
            Y0  => alu_mux_q(2),
            Y1  => alu_mux_q(3)
        );
    -- bits 0 and 1 (lsbs)
    amux2 : SN74153 port map
        ( 
            I0  => alu_q(10) & alu_q(5) & alu_q(3) & alu_q(4),
            I1  => alu_q(11) & alu_q(6) & alu_q(4) & alu_q(5),
            S   => alu_mux_s_in,
            nE0 => alu_mux_en_n_in,
            nE1 => alu_mux_en_n_in,
            Y0  => alu_mux_q(4),
            Y1  => alu_mux_q(5)
        );
    -- bits 0 and 1 (lsbs)
    amux3 : SN74153 port map
        ( 
            I0  => alu_q(0) & alu_q(7) & alu_q(5) & alu_q(6),
            I1  => alu_q(1) & alu_q(8) & alu_q(6) & alu_q(7),
            S   => alu_mux_s_in,
            nE0 => alu_mux_en_n_in,
            nE1 => alu_mux_en_n_in,
            Y0  => alu_mux_q(6),
            Y1  => alu_mux_q(7)
        );
    -- bits 0 and 1 (lsbs)
    amux4 : SN74153 port map
        ( 
            I0  => alu_q(2) & alu_q(9) & alu_q(7) & alu_q(8),
            I1  => alu_q(3) & alu_q(10) & alu_q(8) & alu_q(9),
            S   => alu_mux_s_in,
            nE0 => alu_mux_en_n_in,
            nE1 => alu_mux_en_n_in,
            Y0  => alu_mux_q(8),
            Y1  => alu_mux_q(9)
        );
    -- bits 10 and 11 (lsbs)
    amux5 : SN74153 port map
        ( 
            I0  => alu_q(4) & alu_q(11) & alu_q(9) & alu_q(10),
            I1  => alu_q(5) &     bit_l & alu_q(10) & alu_q(11),
            S   => alu_mux_s_in,
            nE0 => alu_mux_en_n_in,
            nE1 => alu_mux_en_n_in,
            Y0  => alu_mux_q(10),
            Y1  => alu_mux_q(11)
        );


end architecture logic;
