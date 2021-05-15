@echo off
rem set path=c:\tools\iverilog\bin;%PATH%
iverilog -o tb_hp45.out -D SIMULATOR=1 -I ..\rtl tb_hp45.v ..\rtl\nclassic_core.v ..\rtl\nclassic_disasm.v ..\rtl\ssd1326.v
if errorlevel == 1 goto error
vvp tb_hp45.out
:error