/*
 * Test bench for the HP classic series top entity (Uses the HP35 ROM)
 *
 * (c) Copyright 2018-2019 R.A. Paz S.
 * 
 * This software is provided "as-is" without any warranty
 * as described by the GPL v2
 *
 */
`timescale 1ns/1ns
 
module tb_nclassic();

reg clk;

reg [7:0] simkbd_keycode_in;
reg simkbd_activate_key_pending_in;
defparam ncl.HW_TRACE = 1;

NClassic_core ncl(
	.clk_in(clk)
`ifdef SIMULATOR
    ,
    .simkey_activate_key_pending_in(simkbd_activate_key_pending_in),
    .simkey_keycode_in(simkbd_keycode_in)
`endif
	);

always 
	#240.38 clk = ~clk; // 2.08 MHz clock
	
initial
	begin
    $dumpfile("tb_hp35.vcd");
	$dumpvars;
`ifdef SIMULATOR
    $display("Using simulated keyboard input");
`endif
	clk = 0;
    simkbd_keycode_in = 0;
    simkbd_activate_key_pending_in = 0;
    #1600000
    simkbd_activate_key_pending_in = 1'b1;
    simkbd_keycode_in = 8'h90;// simulate P/R
	#5000000
    simkbd_activate_key_pending_in = 0;
	#4000000
    $finish;


    simkbd_activate_key_pending_in = 1'b1;
    simkbd_keycode_in = 8'h41;// simulate f
	#500
    simkbd_activate_key_pending_in = 0;
	#7000000
    simkbd_activate_key_pending_in = 1'b1;
    simkbd_keycode_in = 8'h09;// SST
	#500
    simkbd_activate_key_pending_in = 0;
	#7000000 //00
    simkbd_activate_key_pending_in = 1'b1;
    simkbd_keycode_in = 8'h4A;// A
	#500
    simkbd_activate_key_pending_in = 0;
	#12000000 //00
    simkbd_activate_key_pending_in = 1'b1;
    simkbd_keycode_in = 8'h39;// GTO
	#500
    simkbd_activate_key_pending_in = 0;
	#12000000 //00
    simkbd_activate_key_pending_in = 1'b1;
    simkbd_keycode_in = 8'h4A;// A
	#500
    simkbd_activate_key_pending_in = 0;
	#12000000 //00
    simkbd_activate_key_pending_in = 1'b1;
    simkbd_keycode_in = 8'h38;// P/R
	#500
    simkbd_activate_key_pending_in = 0;
	#12000000 //00
    simkbd_activate_key_pending_in = 1'b1;
    simkbd_keycode_in = 8'h4A;// A
	#500
    simkbd_activate_key_pending_in = 0;
	#12000000 //00
    simkbd_activate_key_pending_in = 1'b1;
    simkbd_keycode_in = 8'h07;// R/S
	#500
    simkbd_activate_key_pending_in = 0;
	#2000
    $finish;
	end
	
	
endmodule

// 2048 10 bit words synchronous ROM
module sync_rom(
    input wire          clk_in,
    
    input wire [10:0]   addr_in,
    output reg [9:0]    data_o
    );

reg [9:0] mem[2047:0];

always @(posedge clk_in)
    begin
        data_o <= #5 mem[addr_in];
    end
    

initial
    begin
        $readmemb("../rtl/hp35.bin", mem);
    end
    
endmodule