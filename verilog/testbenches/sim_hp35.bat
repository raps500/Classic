@echo off
rem set path=c:\iverilog\bin;%PATH%
iverilog -o tb_hp35.out -D SIMULATOR=1 -I ..\rtl tb_hp35.v ..\rtl\nclassic_core.v ..\rtl\nclassic_disasm.v  ..\rtl\ssd1326.v
if errorlevel == 1 goto error
vvp tb_hp35.out
:error