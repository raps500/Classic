--! NAND gate
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SN7400 is
    Port ( 
        A : in  STD_LOGIC;
        B : in  STD_LOGIC;
        Y : out  STD_LOGIC
        );
end SN7400;

architecture logic of SN7400 is
begin
    Y <= not (A and B);
end architecture logic;

--! NOR gate
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SN7402 is
    Port ( 
        A : in  STD_LOGIC;
        B : in  STD_LOGIC;
        Y : out  STD_LOGIC
        );
end SN7402;

architecture logic of SN7402 is
begin
    Y <= not (A or B);
end architecture logic;

--! OR gate
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SN7432 is
    Port ( 
        A : in  STD_LOGIC;
        B : in  STD_LOGIC;
        Y : out  STD_LOGIC
        );
end SN7432;

architecture logic of SN7432 is
begin
    Y <= A or B;
end architecture logic;


--! AND gate
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SN7408 is
    Port ( 
        A : in  STD_LOGIC;
        B : in  STD_LOGIC;
        Y : out  STD_LOGIC
        );
end SN7408;

architecture logic of SN7408 is
begin
    Y <= A and B;
end architecture logic;


--! 3 input AND gate
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SN7411 is
    Port ( 
        A : in  STD_LOGIC;
        B : in  STD_LOGIC;
        C : in  STD_LOGIC;
        Y : out  STD_LOGIC
        );
end SN7411;

architecture logic of SN7411 is
begin
    Y <= A and B and C;
end architecture logic;


--! 4 input NAND gate
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SN7420 is
    Port ( 
        A : in  STD_LOGIC;
        B : in  STD_LOGIC;
        C : in  STD_LOGIC;
        D : in  STD_LOGIC;
        Y : out  STD_LOGIC
        );
end SN7420;

architecture logic of SN7420 is
begin
    Y <= not (A and B and C and D);
end architecture logic;

--! XOR gate
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SN7486 is
    Port ( 
        A : in  STD_LOGIC;
        B : in  STD_LOGIC;
        Y : out  STD_LOGIC
        );
end SN7486;

architecture logic of SN7486 is
begin
    Y <= A xor B;
end architecture logic;
