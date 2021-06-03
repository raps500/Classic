# ALUREGS

This block contains the registers, the adders and the alu sequencer.

# Register file and muxes

The registers are realized using a SRAM (256kBit 32kByte). For the moment only 8 address lines and 4 bits are used. A simpler SRAM like the 2104 could also be used. To latch the registers a pair of 74LS175 are used. These latches provide complementary outputs. Using a MUX one can select which value enters the ADDER normal or the negated.
The negated value is used to implement subtraction.

# Decimal adder

The decimal adder is realized using two 74LS283 4 bit full adders cascaded to perform binary add and decimal adjust adding 6 in case binary or decimal carry occur. A set of or and and gates generate a decimal_adjust signal when this situation occurs.

## Decimal carry generation

The adder/subtracter is a binary adder and uses a second adder to perform decimal adjust. Additions above 9 and binary carry should lead to decimal adjust and carry:

Addition
<table>
    <tr>
        <td><center>Input Left</center></td>
        <td><center>Input Right</center></td>
        <td><center>Output binary</center></td>
        <td><center>Output bin carry</center></td>
        <td><center>Output decimal</center></td>
        <td><center>Output decimal carry</center></td>
    </tr>
    <tr>
        <td><center>0100</center></td>
        <td><center>0101</center></td>
        <td><center>1001</center></td>
        <td><center>0</center></td>
        <td><center>1001</center></td>
        <td><center>0</center></td>
    </tr>
    <tr>
        <td><center>0101</center></td>
        <td><center>0101</center></td>
        <td><center>1010</center></td>
        <td><center>0</center></td>
        <td><center>0000</center></td>
        <td><center>1</center></td>
    </tr>
    <tr>
        <td><center>1001</center></td>
        <td><center>1001</center></td>
        <td><center>0010</center></td>
        <td><center>1</center></td>
        <td><center>1000</center></td>
        <td><center>1</center></td>
    </tr>
</table>

Subtraction
<table>
    <tr>
        <td><center>Input Left</center></td>
        <td><center>Input Right</center></td>
        <td><center>Output binary</center></td>
        <td><center>Output bin carry</center></td>
        <td><center>Output decimal</center></td>
        <td><center>Output decimal carry</center></td>
    </tr>
    <tr>
        <td><center>0101</center></td>
        <td><center>0100</center></td>
        <td><center>1111</center></td>
        <td><center>1</center></td>
        <td><center>1001</center></td>
        <td><center>1</center></td>
    </tr>
    <tr>
        <td><center>0000</center></td>
        <td><center>1001</center></td>
        <td><center>0111</center></td>
        <td><center>1</center></td>
        <td><center>0001</center></td>
        <td><center>1</center></td>
    </tr>
    <tr>
        <td><center>1001</center></td>
        <td><center>1001</center></td>
        <td><center>0010</center></td>
        <td><center>1</center></td>
        <td><center>1000</center></td>
        <td><center>1</center></td>
    </tr>
</table>


# ALU sequencer

The sequencer is tasked with controlling all the gates needed for data flow and storage. This module supports 5 different opcodes: add/sub, transfer, exchange, shift left and shift right.

The sequencer is divided in two sub blocks, the microstepper and the nibble counter. Every nibble processed needs a number of microsteps to perform read from the register file, latch of arguments, add or sub if needed and write back. Add, sub, transfer, exchange and shift right are implemented using an up counter while left shift uses a down counter.

The microstepper counts 8 microsteps per nibble, the last micro step together with the comparison between the current nibble and the end nibble to decide if more nibbles are needed or not.
Following diagrams illustrate how the microstepping is
used for controlling the different blocks.

![Adder/subtracter sequence](ALU_sequencer_add.png)
![Transfer sequence](ALU_sequencer_tfr.png)
![Exchange sequence](ALU_sequencer_ex.png)

Shifts require special treatment: 

* left shifts store a 0 in the first nibble and the last nibble is lost.

![Shift left](ALU_shift_left.png)

* Shift right proceeds from left to right, greater addresses to lower addresses and store a 0 in the first nibble and the last nibble is lost.

![Right shift](ALU_shift_right.png)

