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
        literal_in  : in STD_LOGIC_VECTOR (3 downto 0); --! number to load into C 
        addsub_in   : in STD_LOGIC;                     --! add = 0, sub = 1
        ex_in       : in STD_LOGIC;                     --! none = 0, exchang = 1
        tfr_in      : in STD_LOGIC;                     --! none = 0, tfr = 1
        set_carry_in: in STD_LOGIC;                     --! none = 0, carry set before start = 1
        sto_carry_in: in STD_LOGIC;                     --! none = 0, carry stored = 1
        latch_ops_in: in STD_LOGIC;                     --! latches OP1, OP2 and DST on the rising edge
        op1_in      : in STD_LOGIC_VECTOR (3 downto 0); --! operand 1 address
        op2_in      : in STD_LOGIC_VECTOR (3 downto 0); --! operand 2 address
        dst_in      : in STD_LOGIC_VECTOR (3 downto 0); --! destination address
        carry_o     : out STD_LOGIC                     --! carry ouput: 0 = not set, 1 = set
    );
end ALUREGS;

architecture logic of ALUREGS is

architecture logic of ALUREGS is
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
    component SN7474 is
        Port ( 
            D       : in  STD_LOGIC;
            C       : in  STD_LOGIC;
            nS      : in  STD_LOGIC;
            nR      : in  STD_LOGIC;
            Q       : out  STD_LOGIC;
            nQ      : out  STD_LOGIC
            );
    end component SN7474;
    component SN7486 is
        Port ( 
            A : in  STD_LOGIC;
            B : in  STD_LOGIC;
            Y : out  STD_LOGIC
            );
    end component SN7486; 
    component SN74138 is
        Port ( 
            A       : in  STD_LOGIC;
            B       : in  STD_LOGIC;
            C       : in  STD_LOGIC;
            G1      : in  STD_LOGIC;
            nG2A    : in  STD_LOGIC;
            nG2B    : in  STD_LOGIC;
            Y       : out  STD_LOGIC_VECTOR (7 downto 0)
            );
    end component SN74138;
    component SN74139 is
        Port ( 
            A       : in  STD_LOGIC;
            B       : in  STD_LOGIC;
            nG      : in  STD_LOGIC;
            Y       : out  STD_LOGIC_VECTOR (3 downto 0)
            );
    end component SN74139;
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
    component SN74157 is
        Port ( 
            IA : in  STD_LOGIC_VECTOR (1 downto 0);
            IB : in  STD_LOGIC_VECTOR (1 downto 0);
            IC : in  STD_LOGIC_VECTOR (1 downto 0);
            ID : in  STD_LOGIC_VECTOR (1 downto 0);
             S : in  STD_LOGIC;
             E : in  STD_LOGIC;
             Z : out  STD_LOGIC_VECTOR (3 downto 0)
            );
    end component SN74157;
    component SN74175 is
        Port ( 
            nCLR    : in  STD_LOGIC;
            CLK     : in  STD_LOGIC;
            D       : in  STD_LOGIC_VECTOR (3 downto 0);
            Q       : out STD_LOGIC_VECTOR (3 downto 0);
            nQ      : out STD_LOGIC_VECTOR (3 downto 0)
            );
    end component SN74175;
    component SN74189 is
        Port ( D    : in  STD_LOGIC_VECTOR (3 downto 0);
            A    : in  STD_LOGIC_VECTOR (3 downto 0);
            nCS  : in  STD_LOGIC;
            nWE  : in  STD_LOGIC;
            nQ   : out  STD_LOGIC_VECTOR (3 downto 0)
        );
    end component SN74189;
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
    component SN74283 is
        Port ( A    : in  STD_LOGIC_VECTOR (3 downto 0);
            B    : in  STD_LOGIC_VECTOR (3 downto 0);
            C4   : out  STD_LOGIC;
            C0   : in  STD_LOGIC;
            Q    : out  STD_LOGIC_VECTOR (3 downto 0)
        );
    end component SN74283;
    
    component SN74393 is
        Port ( 
            MR  : in  STD_LOGIC;
            CP  : in  STD_LOGIC;
            Q   : out  STD_LOGIC_VECTOR (3 downto 0)
            );
    end component SN74393;
    component REGS is
        Port ( 
            addr_in : in STD_LOGIC_LOGIC(7 downto 0);                     --! main clock for register latch
            data_in : in STD_LOGIC_LOGIC(3 downto 0);                     --! 
            data_o  : out STD_LOGIC_LOGIC(3 downto 0);                     --! 
            nwe_in  : in STD_LOGIC;                     --! 
            noe_in  : in STD_LOGIC                      --! 
        );
    end component REGS;
    signal op1_r            : std_logic_vector(3 downto 0); --! output of the OP1 register 
    signal op2_r            : std_logic_vector(3 downto 0); --! output of the OP2 register
    signal dst_r            : std_logic_vector(3 downto 0); --! output of the DST register
    signal sel_imux         : std_logic_vector(1 downto 0); --! input mux selector
    signal imux_q           : std_logic_vector(3 downto 0); --! output of the input mux and registersinout
    signal regs_a           : std_logic_vector(7 downto 0); --! register address
    signal add_left_pre     : std_logic_vector(3 downto 0); --! output of the OP1 latch
    signal add_left_pre_n   : std_logic_vector(3 downto 0); --! output of the OP1 latch negated
    signal add_left         : std_logic_vector(3 downto 0); --! output of the OP1 mux to the adder
    signal add_right_pre    : std_logic_vector(3 downto 0); --! output of the OP2 latch
    signal add_right_pre_n  : std_logic_vector(3 downto 0); --! output of the OP2 latch negated
    signal add_right        : std_logic_vector(3 downto 0); --! output of the OP2 mux to the adder
    signal binadd_q         : std_logic_vector(3 downto 0); --! output of the binary adder
    signal decadd_q         : std_logic_vector(3 downto 0); --! output of the decimal adder
    signal binadd_1_or_2    : std_logic;                    --! binary adder q 1 or 2 forms part of the decimal carry
    signal binadd_3_and_12  : std_logic;                    --! binary adder q 3 and 1 or 2 forms part of the decimal carry
    signal decimal_adjust   : std_logic;                    --! asserted when decimal or binary carry
    signal binadd_c         : std_logic;                    --! asserted when inary carry
    signal carry            : std_logic;                    --! asserted when decimal or binary carry
    signal latch_left       : std_logic;                    --! latches the left (OP1) operand on the rising edge
    signal latch_right      : std_logic;                    --! latches the right (OP2) operand on the rising edge
    signal latch_op1        : std_logic;                    --! latches the right (OP2) operand on the rising edge
    signal latch_op2 t      : std_logic;                    --! latches the right (OP2) operand on the rising edge
    signal latch_dst        : std_logic;                    --! latches the right (OP2) operand on the rising edge
    
    signal microstep_q      : std_logic_vector(3 downto 0); --! output of the microstep counter
    signal nibble_q         : std_logic_vector(3 downto 0); --! output of the nibble counter, low reg address
    
begin
    --! Operand registers
    U1: SN74175 port map(
        nCLR    => '1',
        CLK     => latch_ops_in,
        D       => op1_in,
        Q       => op1_r,
        nQ      => null
    );
    U2: SN74175 port map(
        nCLR    => '1',
        CLK     => latch_ops_in,
        D       => op2_in,
        Q       => op2_r,
        nQ      => null
    );
    U3: SN74175 port map(
        nCLR    => '1',
        CLK     => latch_ops_in,
        D       => dst_in,
        Q       => dst_r,
        nQ      => null
    );

    --! Input mux to the register file
    --! Truth table
    --! S(1) S(0)   Y
    --! ----------+--------------
    --!   0    0  | decadd_q       
    --!   0    1  | literal_in     
    --!   1    0  | add_left_pre   
    --!   1    1  | add_right_pre  for exchange and transfer
    --! Bits 3, 2
    U4 : SN74153 Port map ( 
        I0      => add_right_pre(3) & add_left_pre(3) & literal_in(3) & decadd_q(3),
        I1      => add_right_pre(2) & add_left_pre(2) & literal_in(2) & decadd_q(2),
         S      => sel_imux, 
        nE0     => '0', -- always active
        nE1     => '0', -- always active
        Y0      => imux_q(3),
        Y1      => imux_q(2)
        );

    --! Bits 1, 0
    U5 : SN74153 Port map ( 
        I0      => add_right_pre(1) & add_left_pre(1) & literal_in(1) & decadd_q(1),
        I1      => add_right_pre(0) & add_left_pre(0) & literal_in(0) & decadd_q(0),
         S      => sel_imux, 
        nE0     => '0', -- always active
        nE1     => '0', -- always active
        Y0      => imux_q(1),
        Y1      => imux_q(0)
        );
    --! Left register before the adder
    U6: SN74175 port map(
        nCLR    => '1', --clear_p,
        CLK     => latch_left,
        D       => imux_q,
        Q       => add_left_pre,
        nQ      => add_left_pre_nq
    );
    --! Left MUX before the binary adder
    U7: SN74157 Port map ( 
        IA      => add_left_pre_n(0) & add_left_pre(0),
        IB      => add_left_pre_n(1) & add_left_pre(1),
        IC      => add_left_pre_n(2) & add_left_pre(2),
        ID      => add_left_pre_n(3) & add_left_pre(3),
        S       => negate_left,
        E       => '0',
        Z       => add_left
    );

    --! Right register before the adder
    U8: SN74175 port map(
        nCLR    => '1', --clear_p,
        CLK     => latch_right,
        D       => imux_q,
        Q       => add_right_pre,
        nQ      => add_right_pre_n
    );

    --! Right MUX before the binary adder
    U9: SN74157 Port map ( 
        IA      => add_right_pre_n(0) & add_right_pre(0),
        IB      => add_right_pre_n(1) & add_right_pre(1),
        IC      => add_right_pre_n(2) & add_right_pre(2),
        ID      => add_right_pre_n(3) & add_right_pre(3),
        S       => negate_right,
        E       => '0',
        Z       => add_right
    );
    

    --! Binary adder
    --! 
    U10 : SN74283 Port map ( 
        A    => add_left,
        B    => add_right,
        C4   => binadd_c,
        C0   => '0',
        Q    => binadd_q
        );
    U11A: SN7432  port map(
        A       => binadd_q(1),
        B       => binadd_q(2),
        Y       => binadd_1_or_2
    );
    U12A: SN7408  port map(
        A       => binadd_1_or_2,
        B       => binadd_q(3),
        Y       => binadd_3_and_12
    );
    U11B: SN7432  port map(
        A       => binadd_3_and_12,
        B       => binadd_c,
        Y       => decimal_adjust
    );
    --! Decimal adjust
    --! adjusts if decimal carry
    U13 : SN74283 Port map ( 
        A    => binadd_q,
        B    => '0' & decimal_adjust & decimal_adjust & '0',
        C4   => None,
        C0   => '0',
        Q    => decadd_q
    );
    --! Sequencer
    --! The sequencer is tasked with controlling the diferent
    --! blocks to perforn any of the five operations
    --! add/sub, transfer, exchange, shift left or shift right
    --! Two nibble addresses are used start and end
    --! two counters are used one for micro steps
    --! one for nibbles
    --! there are 4 microsteps per nibble

    U14 : SN74393 port map
    (
        MR  => microstep_q(3), --! auto reset
        CP  => clk_in,  --! gated adder clock
        Q  => microstep_q,
    );

    U15 : SN74191 port map
    (
        P       => start_in,
        nPL     => latch_ops_in,
        nUD     => dir_in,
        nCE     => '0',         --! always active
        CP      => microstep_q(3),
        Q       => nibble_q
    );










    


end architecture;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity REGS is
    Port ( 
        addr_in : in STD_LOGIC_LOGIC(7 downto 0);                     --! main clock for register latch
        data_in : in STD_LOGIC_LOGIC(3 downto 0);                     --! 
        data_o  : out STD_LOGIC_LOGIC(3 downto 0);                     --! 
        nwe_in  : in STD_LOGIC;                     --! 
        noe_in  : in STD_LOGIC                      --! 
    );
end entity REGS;

architecture logic of REGS is
    type regfile_t is array (natural range 0 to 255) of std_logic_vector(3 downto 0);
    signal regfile : regfile_t := ( X"X", X"X", X"X", X"X", X"X", X"X", X"X", X"X",  X"X", X"X", X"X", X"X",  X"X", X"X", X"X", X"X", 
                                    X"X", X"X", X"X", X"X", X"X", X"X", X"X", X"X",  X"X", X"X", X"X", X"X",  X"X", X"X", X"X", X"X", 
                                    X"X", X"X", X"X", X"X", X"X", X"X", X"X", X"X",  X"X", X"X", X"X", X"X",  X"X", X"X", X"X", X"X", 
                                    X"X", X"X", X"X", X"X", X"X", X"X", X"X", X"X",  X"X", X"X", X"X", X"X",  X"X", X"X", X"X", X"X", 
                                    X"X", X"X", X"X", X"X", X"X", X"X", X"X", X"X",  X"X", X"X", X"X", X"X",  X"X", X"X", X"X", X"X", 
                                    X"X", X"X", X"X", X"X", X"X", X"X", X"X", X"X",  X"X", X"X", X"X", X"X",  X"X", X"X", X"X", X"X", 
                                    X"X", X"X", X"X", X"X", X"X", X"X", X"X", X"X",  X"X", X"X", X"X", X"X",  X"X", X"X", X"X", X"X", 
                                    X"X", X"X", X"X", X"X", X"X", X"X", X"X", X"X",  X"X", X"X", X"X", X"X",  X"X", X"X", X"X", X"X", 
                                    X"X", X"X", X"X", X"X", X"X", X"X", X"X", X"X",  X"X", X"X", X"X", X"X",  X"X", X"X", X"X", X"X", 
                                    X"X", X"X", X"X", X"X", X"X", X"X", X"X", X"X",  X"X", X"X", X"X", X"X",  X"X", X"X", X"X", X"X", 
                                    X"X", X"X", X"X", X"X", X"X", X"X", X"X", X"X",  X"X", X"X", X"X", X"X",  X"X", X"X", X"X", X"X", 
                                    X"X", X"X", X"X", X"X", X"X", X"X", X"X", X"X",  X"X", X"X", X"X", X"X",  X"X", X"X", X"X", X"X", 
                                    X"X", X"X", X"X", X"X", X"X", X"X", X"X", X"X",  X"X", X"X", X"X", X"X",  X"X", X"X", X"X", X"X", 
                                    X"X", X"X", X"X", X"X", X"X", X"X", X"X", X"X",  X"X", X"X", X"X", X"X",  X"X", X"X", X"X", X"X", 
                                    X"X", X"X", X"X", X"X", X"X", X"X", X"X", X"X",  X"X", X"X", X"X", X"X",  X"X", X"X", X"X", X"X", 
                                    X"X", X"X", X"X", X"X", X"X", X"X", X"X", X"X",  X"X", X"X", X"X", X"X",  X"X", X"X", X"X", X"X"  
                                    );

begin
    process (nwe_in)
        begin
            if falling_edge(nwe_in) then
                regfile(to_integer(unsigned(addr_in))) <= data_in;
            end if;
        end process;
    data_o <= regfile(to_integer(unsigned(addr_in))) when noe_in = '0' else X"Z";
        
end architecture logic;