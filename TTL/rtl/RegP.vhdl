--
--! Register P implemented in discrete TTL
--! Supported Functions:
--! Increment with 13 crossing: when at 13 an increment loads 0
--! Decrement with 0 crossing: when at 0 a decrement loads 13
--! Test for equality
--! Load
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity REGP is
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
end REGP;

architecture logic of RegP is
    component SN74283 is
        Port ( A    : in  STD_LOGIC_VECTOR (3 downto 0);
               B    : in  STD_LOGIC_VECTOR (3 downto 0);
               C4   : out  STD_LOGIC;
               C0   : in  STD_LOGIC;
               Q    : out  STD_LOGIC_VECTOR (3 downto 0)
        );
    end component SN74283;
    component SN74175 is
        Port ( 
            nCLR    : in  STD_LOGIC;
            CLK     : in  STD_LOGIC;
            D       : in  STD_LOGIC_VECTOR (3 downto 0);
            Q       : out STD_LOGIC_VECTOR (3 downto 0);
            nQ      : out STD_LOGIC_VECTOR (3 downto 0)
            );
    end component SN74175;
    component SN74153 is
        Port ( 
            I0      : in  STD_LOGIC_VECTOR (3 downto 0);
            I1      : in  STD_LOGIC_VECTOR (3 downto 0);
             S      : in  STD_LOGIC_VECTOR (1 downto 0);
            nE0     : in  STD_LOGIC;
            nE1     : in  STD_LOGIC;
            Y0      : out  STD_LOGIC;
            Y1      : out  STD_LOGIC
            );
    end component SN74153;
    component SN7400 is
        Port ( 
            A : in  STD_LOGIC;
            B : in  STD_LOGIC;
            Y : out  STD_LOGIC
            );
    end component SN7400;
    component SN7402 is
        Port ( 
            A : in  STD_LOGIC;
            B : in  STD_LOGIC;
            Y : out  STD_LOGIC
            );
    end component SN7402;
    component SN7408 is
        Port ( 
            A : in  STD_LOGIC;
            B : in  STD_LOGIC;
            Y : out  STD_LOGIC
            );
    end component SN7408;
    component SN7432 is
        Port ( 
            A : in  STD_LOGIC;
            B : in  STD_LOGIC;
            Y : out  STD_LOGIC
            );
    end component SN7432; 
    component SN7486 is
        Port ( 
            A : in  STD_LOGIC;
            B : in  STD_LOGIC;
            Y : out  STD_LOGIC
            );
    end component SN7486; 
    signal add_q        : std_logic_vector(3 downto 0); --! output of the adder
    signal add_c        : std_logic; --! output of the adder carry
    signal regp_imux    : std_logic_vector(3 downto 0); --! output of the input mux
    signal regp_q       : std_logic_vector(3 downto 0); --! output of the register P
    signal regp_nq      : std_logic_vector(3 downto 0); --! output of the register P negated
    signal sel_load_to_p: std_logic_vector(1 downto 0); --! selects what is loaded to P
    signal inc_or_dec   : std_logic; --! increment or decrement, used to gate the clock
    signal load_or_inc_or_dec   : std_logic; --! load, inc or dec, used to gate the clock
    signal gated_clk    : std_logic; --! gated clock
    signal clear_p      : std_logic; --! clear P signal inc and is_13
    signal p_is_13_a    : std_logic; --! P is 13, next inc must clear P
    signal p_is_13_b    : std_logic; --! P is 13, next inc must clear P
    signal p_is_13      : std_logic; --! P is 13, next inc must clear P
    signal p_is_0_a     : std_logic; --! P is zero next dec must set P to 13
    signal p_is_0_b     : std_logic; --! P is zero next dec must set P to 13
    signal p_is_0       : std_logic; --! P is zero next dec must set P to 13
    signal cmp_3        : std_logic; --! compare output of bit 3
    signal cmp_2        : std_logic; --! compare output of bit 2
    signal cmp_1        : std_logic; --! compare output of bit 1
    signal cmp_0        : std_logic; --! compare output of bit 0
    signal cmp_a        : std_logic; --! compare output of bits 3,2
    signal cmp_b        : std_logic; --! compare output of bits 1,2
    signal dec_p_0      : std_logic; --! decremnt selected and P is 0, loads 13 on next dec
    signal inc_p_13     : std_logic; --! increment selected and P is 13, loads 0 on next inc
begin
    --! The input mux for load and inc, dec
    --! input mux selector
    U6C: SN7408  port map(
        A       => dec_in,
        B       => p_is_0,
        Y       => dec_p_0 --! forces "0" to load into P
    );
    U10A: SN7432  port map(
        A       => load_in,
        B       => dec_p_0,
        Y       => sel_load_to_p(0) --! forces "D" to load into P
    );
    --! part of the mux selector
    U6D: SN7408  port map(
        A       => inc_in,
        B       => p_is_13,
        Y       => inc_p_13 --! forces "D" to load into P
    );
    U10B: SN7432  port map(
        A       => dec_p_0,
        B       => inc_p_13,
        Y       => sel_load_to_p(1) --! forces "D" or "0" to load into P
    );
    --! Bits 3, 2
    U1 : SN74153 Port map ( 
        I0      => "10" & data_in(3) & add_q(3), -- load, add/dec, 13
        I1      => "10" & data_in(2) & add_q(2), -- load, add/dec, 13 
         S      => sel_load_to_p, 
        nE0     => '0', -- always active
        nE1     => '0', -- always active
        Y0      => regp_imux(3),
        Y1      => regp_imux(2)
        );

    --! Bits 1, 0
    U2 : SN74153 Port map ( 
        I0      => "00" & data_in(1) & add_q(1), -- load, add/dec, 13
        I1      => "10" & data_in(0) & add_q(0), -- load, add/dec, 13 
         S      => sel_load_to_p, 
        nE0     => '0', -- always active
        nE1     => '0', -- always active
        Y0      => regp_imux(1),
        Y1      => regp_imux(0)
        );

    --! Register P
    --! gate for the clock
    U4A: SN7432 port map(
        A       => inc_in,
        B       => dec_in,
        Y       => inc_or_dec
    );
    U4B: SN7432 port map(
        A       => inc_or_dec,
        B       => load_in,
        Y       => load_or_inc_or_dec
    );
    U5A: SN7408  port map(
        A       => load_or_inc_or_dec,
        B       => clk_in,
        Y       => gated_clk
    );
    U3: SN74175 port map(
        nCLR    => '1', --clear_p,
        CLK     => gated_clk,
        D       => regp_imux,
        Q       => regp_q,
        nQ      => regp_nq
    );
    p_o <= regp_q;

    --! detect that P is zero
    U5B: SN7408  port map(
        A       => regp_nq(3),
        B       => regp_nq(2),
        Y       => p_is_0_a
    );
    U5C: SN7408  port map(
        A       => regp_nq(1),
        B       => regp_nq(0),
        Y       => p_is_0_b
    );
    U5D: SN7408  port map(
        A       => p_is_0_a,
        B       => p_is_0_b,
        Y       => p_is_0
    );
    --! detect that P is 13, 14 or 15
    U6A: SN7408  port map(
        A       => regp_q(3),
        B       => regp_q(2),
        Y       => p_is_13_a
    );
    U4C: SN7432  port map(
        A       => regp_q(1),
        B       => regp_q(0),
        Y       => p_is_13_b
    );
    U6B: SN7408  port map(
        A       => p_is_13_a,
        B       => p_is_13_b,
        Y       => p_is_13
    );
    --! clear is used when incrementing and P is already 13
    --U12A: SN7400  port map(
    --    A       => inc_in,
    --    B       => p_is_13,
    --    Y       => clear_p
    --);

    --! Incrementer, decrementer
    --! Uses dec_in to select between adding 'F' to decrement and 1 for increment
    U7 : SN74283 Port map ( 
        A    => regp_q,
        B    => dec_in & dec_in & dec_in & '1',
        C4   => add_c,
        C0   => '0',
        Q    => add_q
        );
    --! Compare
    U8A : SN7486 port map (
        A   => data_in(3),
        B   => regp_q(3),
        Y   => cmp_3
    );
    U8B : SN7486 port map (
        A   => data_in(2),
        B   => regp_q(2),
        Y   => cmp_2
    );
    U8C : SN7486 port map (
        A   => data_in(1),
        B   => regp_q(1),
        Y   => cmp_1
    );
    U8D : SN7486 port map (
        A   => data_in(0),
        B   => regp_q(0),
        Y   => cmp_0
    );
    U9A: SN7432  port map(
        A       => cmp_3,
        B       => cmp_2,
        Y       => cmp_a
    );
    U9B: SN7432  port map(
        A       => cmp_1,
        B       => cmp_0,
        Y       => cmp_b
    );
    U9C: SN7432  port map(
        A       => cmp_a,
        B       => cmp_b,
        Y       => cmp_res_o
    );
end architecture;

