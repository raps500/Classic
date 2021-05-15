--
--! ALU/Register block implemented in discrete TTL
--! Supported Functions:
--! Add/Sub/Compare from up to 13 nibbles
--! 
--! 
--! 
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALUREGS is
    Port ( 
        clk_in      : in STD_LOGIC;                     --! main clock for register latch
        reset_in    : in STD_LOGIC;                     --! 
        start_in    : in STD_LOGIC_VECTOR (3 downto 0); --! starting nibble (left)
        end_in      : in STD_LOGIC_VECTOR (3 downto 0); --! end nibble (right)
        dir_in      : in STD_LOGIC;                     --! direction for start/end 
        data_in     : in STD_LOGIC_VECTOR (3 downto 0); --! number to load into C 
        addsub_in   : in STD_LOGIC;                     --! add = 0, sub = 1
        ex_in       : in STD_LOGIC;                     --! none = 0, exchang = 1
        tfr_in      : in STD_LOGIC;                     --! none = 0, tfr = 1
        set_carry_in: in STD_LOGIC;                     --! none = 0, carry set before start = 1
        sto_carry_in: in STD_LOGIC;                     --! none = 0, carry stored = 1
        op1_in      : in STD_LOGIC_VECTOR (3 downto 0); --! operand 1 address
        dst_in      : in STD_LOGIC_VECTOR (3 downto 0); --! operand 2/destination address
        carry_o     : out STD_LOGIC                     --! carry ouput: 0 = not set, 1 = set
    );
end ALUREGS;

architecture logic of ALUREGS is

architecture logic of ALUREGS is
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
    component SN74189 is
        Port ( D    : in  STD_LOGIC_VECTOR (3 downto 0);
            A    : in  STD_LOGIC_VECTOR (3 downto 0);
            nCS  : in  STD_LOGIC;
            nWE  : in  STD_LOGIC;
            nQ   : out  STD_LOGIC_VECTOR (3 downto 0)
        );
    end SN74189;
begin
    --! Input mux to the register file
    --! Bits 3, 2
    U1 : SN74153 Port map ( 
        I0      => "10" & data_in(3) & add_q(3), -- load, add/dec, 13
        I1      => "10" & data_in(2) & add_q(2), -- load, add/dec, 13 
         S      => sel_load_to_p, 
        nE0     => '0', -- always active
        nE1     => '0', -- always active
        Y0      => regs_imux(3),
        Y1      => regs_imux(2)
        );

    --! Bits 1, 0
    U2 : SN74153 Port map ( 
        I0      => "00" & data_in(1) & add_q(1), -- load, add/dec, 13
        I1      => "10" & data_in(0) & add_q(0), -- load, add/dec, 13 
         S      => sel_load_to_p, 
        nE0     => '0', -- always active
        nE1     => '0', -- always active
        Y0      => regs_imux(1),
        Y1      => regs_imux(0)
        );
    --! Left register before the adder
    U3: SN74175 port map(
        nCLR    => '1', --clear_p,
        CLK     => gated_clk,
        D       => regp_imux,
        Q       => left_q,
        nQ      => left_nq
    );
    --! Right register before the adder
    U3: SN74175 port map(
        nCLR    => '1', --clear_p,
        CLK     => gated_clk,
        D       => regp_imux,
        Q       => right_q,
        nQ      => right_nq
    );

    --! Binary adder
    --! 
    U7 : SN74283 Port map ( 
        A    => left_q,
        B    => right_q,
        C4   => binadd_c,
        C0   => '0',
        Q    => binadd_q
        );
    U4C: SN7432  port map(
        A       => binadd_q(2),
        B       => binadd_q(3),
        Y       => q2_or_q1
    );
    U6B: SN7408  port map(
        A       => binadd_q(3),
        B       => q2_or_q1,
        Y       => dec_carry
    );
    --! Decimal adjust
    --! adjusts if decimal carry
    U7 : SN74283 Port map ( 
        A    => binadd_q,
        B    => '0' & dec_carry & dec_carry & '0',
        C4   => add_c,
        C0   => '0',
        Q    => add_q
        );

end architecture;