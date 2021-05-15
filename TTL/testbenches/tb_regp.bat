@echo off
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
rem set path=c:\tools\ghdl\bin;c:\tools\ghdl-0.35\bin;C:\tools\mingw-w64\x86_64-8.1.0-posix-seh-rt_v6-rev0\mingw64\bin;C:\tools\mingw-w64\msys2_64\usr\bin
echo TTL Gates
ghdl --version
ghdl -a --ieee=standard --std=08 ..\rtl\TTLGates.vhdl
if errorlevel == 1 goto error
echo 74153
ghdl -a --ieee=standard --std=08 ..\rtl\SN74153.vhdl
if errorlevel == 1 goto error
echo 74175
ghdl -a --ieee=standard --std=08 ..\rtl\SN74175.vhdl
if errorlevel == 1 goto error
echo 74283
ghdl -a --ieee=standard --std=08 ..\rtl\SN74283.vhdl
if errorlevel == 1 goto error
echo RegP
ghdl -a --ieee=standard --std=08 ..\rtl\RegP.vhdl
if errorlevel == 1 goto error
echo Analyze TB
ghdl -a --ieee=standard --std=08 REGP_tb.vhdl
if errorlevel == 1 goto error
echo Elaborate phase
ghdl -e --ieee=standard --std=08 REGP_tb
echo Run simulation
if errorlevel == 1 goto error
ghdl -r --ieee=standard --std=08 REGP_tb --vcd=REGP_tb.vcd --stop-time=60us
:error
