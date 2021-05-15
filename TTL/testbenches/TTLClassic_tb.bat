@echo off
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
set path=c:\tools\ghdl\bin;c:\tools\ghdl-0.35\bin;C:\tools\mingw-w64\x86_64-8.1.0-posix-seh-rt_v6-rev0\mingw64\bin;C:\tools\mingw-w64\msys2_64\usr\bin
echo IC7474_std_logic
ghdl -a --ieee=synopsys --std=08 ..\rtl\IC7474_std_logic.vhd
if errorlevel == 1 goto error
echo IC74153
ghdl -a --ieee=synopsys --std=08 ..\rtl\SN74153.vhdl
if errorlevel == 1 goto error
echo IC74181
ghdl -a --ieee=synopsys --std=08 ..\rtl\IC74181.vhd
if errorlevel == 1 goto error
echo IC74374
ghdl -a --ieee=synopsys --std=08 ..\rtl\IC74374.vhd
if errorlevel == 1 goto error
echo IC74170
ghdl -a --ieee=synopsys --std=08 ..\rtl\SN74170.vhdl
if errorlevel == 1 goto error
echo Analyze APDP8_reg_alu
ghdl -a --ieee=synopsys --std=08 ..\rtl\APDP8_reg_alu.vhdl
if errorlevel == 1 goto error
echo Analyze TB
ghdl -a --ieee=synopsys --std=08 APDP8_reg_alu_tb.vhdl
if errorlevel == 1 goto error
echo Elaborate phase
ghdl -e --ieee=synopsys --std=08 APDP8_reg_alu_tb
echo Run simulation
if errorlevel == 1 goto error
ghdl -r --ieee=synopsys --std=08 APDP8_reg_alu_tb --vcd=APDP8_reg_alu_tb.vcd --stop-time=40us
:error
