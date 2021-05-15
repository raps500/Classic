--! 74283
--! 4-bit adder with carry

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SN74283 is
    Port ( A    : in  STD_LOGIC_VECTOR (3 downto 0);
           B    : in  STD_LOGIC_VECTOR (3 downto 0);
           C4   : out  STD_LOGIC;
           C0   : in  STD_LOGIC;
           Q    : out  STD_LOGIC_VECTOR (3 downto 0)
    );
end SN74283;

architecture logic of SN74283 is
    signal a4b4_nor   : std_logic;
    signal a4b4_nand  : std_logic;
    signal a3b3_nor   : std_logic;
    signal a3b3_nand  : std_logic;
    signal a2b2_nor   : std_logic;
    signal a2b2_nand  : std_logic;
    signal a1b1_nor   : std_logic;
    signal a1b1_nand  : std_logic;
    signal q4_itop    : std_logic;
    signal q4_ibottom : std_logic;
    signal q3_itop    : std_logic;
    signal q3_ibottom : std_logic;
    signal q2_itop    : std_logic;
    signal q2_ibottom : std_logic;
    signal q1_itop    : std_logic;
    signal q1_ibottom : std_logic;
    
begin
    a4b4_nand <= not (A(3) and B(3));
    a3b3_nand <= not (A(2) and B(2));
    a2b2_nand <= not (A(1) and B(1));
    a1b1_nand <= not (A(0) and B(0));

    a4b4_nor  <= not (A(3) or  B(3));
    a3b3_nor  <= not (A(2) or  B(2));
    a2b2_nor  <= not (A(1) or  B(1));
    a1b1_nor  <= not (A(0) or  B(0));

    C4 <= not ( a4b4_nor or 
                (a3b3_nor and a4b4_nand) or
                (a2b2_nor and a3b3_nand and a4b4_nand) or
                (a1b1_nor and a2b2_nand and a3b3_nand and a4b4_nand) or
                (a1b1_nand and a2b2_nand and a3b3_nand and a4b4_nand and not C0)
                );

    q4_itop <= a4b4_nand and not a4b4_nor;
    q4_ibottom <= not   ( a3b3_nor or 
                          (a2b2_nor and a3b3_nand) or
                          (a1b1_nor and a2b2_nand and a2b2_nand) or
                          (a3b3_nand and a2b2_nand and a1b1_nand and not C0)
                        );
    Q(3) <= q4_itop xor q4_ibottom;

    q3_itop <= a3b3_nand and not a3b3_nor;
    q3_ibottom <= not   ( a2b2_nor or 
                          (a1b1_nor and a2b2_nand) or
                          (a2b2_nand and a1b1_nand and not C0)
                        );
    Q(2) <= q3_itop xor q3_ibottom;

    q2_itop <= a2b2_nand and not a2b2_nor;
    q2_ibottom <= not   ( a1b1_nor or 
                          (a1b1_nand and not C0)
                        );
    Q(1) <= q2_itop xor q2_ibottom;

    q1_itop <= a1b1_nand and not a1b1_nor;
    q1_ibottom <= C0;
    Q(0) <= q1_itop xor q1_ibottom;

end architecture logic;

