

module NClassic(
    output wire			disp_cs_n_o,
	output wire			disp_addr_o,
	output wire			disp_sck_o,
	output wire			disp_data_o,
	output wire			disp_res_n_o,
	input wire          prog_in,		// Progam mode, asserted HIGH normal pull-down
	inout wire [4:0]    columns_o,
	input wire [7:0]	rows_in,
	output wire			txd_o,
	
	output wire [3:0]   ra_o,
	
    output wire         fetch_op0_o

);
wire [23:0] debug;
wire osc_clk;
wire clk_d1, clk_4, clk_d4b, clk_d16, clk_d16b, clk_d32, ALIGNWD;

wire [4:0] kbd_columns;
wire dummy;
defparam ws.MXO2 = 1;
defparam ws.MAX10 = 0;
defparam ws.HP67 = 1;
defparam ws.HW_TRACE = 1;
defparam ws.HW_TRACE_MINI = 0;
defparam ws.DISP_DOGM132 = 1;
defparam ws.DISP_SSD1603 = 0;   
wire pur;
// divider for the 2.08 MHz clock		
//PUR PUR_INST (pur);
//GSR GSR_INST (.GSR (gbl_reset));
//   Internal Oscillator 
//   defparam OSCH_inst.NOM_FREQ = "2.08";
//   This is the default frequency     

    defparam OSCH_inst.NOM_FREQ = "2.08";//"3.69"; 
    OSCH OSCH_inst( .STDBY(1'b0), //  0=Enabled, 1=Disabled //  also Disabled with Bandgap=OFF                
                    .OSC(osc_clk),                
                    .SEDSTDBY()); //  this signal is not required if not //  using SED 
// divide by 4 520000 Hz
defparam I1.DIV = "2.0"; 
defparam I1.GSR = "DISABLED"; 
CLKDIVC I1 ( .RST (1'b0), .CLKI(osc_clk), .ALIGNWD (ALIGNWD), .CDIV1 (clk_d1), .CDIVX (clk_d4));
/*
defparam I2.DIV = "4.0"; 
defparam I2.GSR = "DISABLED"; 
CLKDIVC I2 ( .RST (1'b0), .CLKI(clk_d4), .ALIGNWD (ALIGNWD), .CDIV1 (clk_d4b), .CDIVX (clk_d16));

defparam I3.DIV = "2.0"; 
defparam I3.GSR = "DISABLED"; 
CLKDIVC I3 ( .RST (1'b0), .CLKI(clk_d16), .ALIGNWD (ALIGNWD), .CDIV1 (clk_d16b), .CDIVX (clk_d32));
*/

assign columns_o[0] = kbd_columns[0] == 1'b1 ? 1'b1:1'bz;
assign columns_o[1] = kbd_columns[1] == 1'b1 ? 1'b1:1'bz;
assign columns_o[2] = kbd_columns[2] == 1'b1 ? 1'b1:1'bz;
assign columns_o[3] = kbd_columns[3] == 1'b1 ? 1'b1:1'bz;
assign columns_o[4] = kbd_columns[4] == 1'b1 ? 1'b1:1'bz;
assign fetch_op0_o = clk_d4;
assign ra_o = debug[3:0];
//assign disp_sck_o =  clk_div[1];
NClassic_core  ncl(
	.clk_in(clk_d4),     // only used in Simulation or Max 10 variant
    .disp_cs_n_o(disp_cs_n_o),
	.disp_addr_o(disp_addr_o),
	.disp_sck_o(disp_sck_o),
	.disp_data_o(disp_data_o),
	.disp_res_n_o(disp_res_n_o),
	
	.pgm_in(prog_in),
	.kbd_columns_o(kbd_columns),
	
	.rows_in(rows_in),
	.txd_o(txd_o),	
	.debug_o(debug)
	);
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
        $readmemb("hp45.bin", mem);
    end
    
endmodule

// Sync ROM for MachXO2
`ifdef ROMS2
module sync_rom(
    input wire          clk_in,
    
    input wire [12:0]   addr_in,
    output wire [9:0]    data_o
    );

wire [12:0] new_addr;
wire [0:0] data1;
wire [8:0] data9_1k, data9_4k;

assign new_addr = addr_in[12:10] == 3'b000 ? { 1'b0, addr_in[11:0] }:
                  addr_in[12:10] == 3'b001 ? { 1'b0, addr_in[11:0] }:
                  addr_in[12:10] == 3'b010 ? { 1'b0, addr_in[11:0] }:
                  addr_in[12:10] == 3'b011 ? { 1'b0, addr_in[11:0] }:
                  addr_in[12:10] == 3'b100 ? { 1'b0, addr_in[11:0] }:
                  addr_in[12:10] == 3'b101 ? { 3'b100, addr_in[9:0] }: // bank 1 is located in the 4096..5119 area
                  addr_in[12:10] == 3'b110 ? { 1'b0, addr_in[11:0] }:
                                             { 1'b0, addr_in[11:0] };
assign data_o = { data1, addr_in[12] ? data9_1k:data9_4k };
`ifdef SIMULATOR
sync_rom9_4k r9_4k(
	.clk_in(clk_in),
	.addr_in(addr_in[11:0]),
	.data_o(data9_4k)
	);
// banked page:
sync_rom9_1k r9_1k(
	.clk_in(clk_in),
	.addr_in(addr_in[9:0]),
	.data_o(data9_1k)
	);
sync_rom1 r1(
	.clk_in(clk_in),
	.addr_in(new_addr),
	.data_o(data1)
	);  
`else
rom_4kx9 r9_4k(
	.OutClock(clk_in),
	.OutClockEn(1'b1),
	.Reset(1'b0),
	.Address(addr_in[11:0]),
	.Q(data9_4k)
	);  
rom_1kx9 r9_1k(
	.OutClock(clk_in),
	.OutClockEn(1'b1),
	.Reset(1'b0),
	.Address(addr_in[9:0]),
	.Q(data9_1k)
	);  
rom_8kx1 r1(
	.OutClock(clk_in),
	.OutClockEn(1'b1),
	.Reset(1'b0),
	.Address(new_addr),
	.Q(data1)
	);  
`endif

endmodule
`ifdef SIMULATOR
module sync_rom9_1k(
    input wire          clk_in,
    
    input wire [9:0]   addr_in,
    output reg [8:0]    data_o
    );

reg [8:0] mem[1023:0];

always @(posedge clk_in)
    begin
        data_o <= #5 mem[addr_in];
    end
    

initial
    begin
        $readmemb("../../03_ROMS/hp67_9_bits_1k.bin", mem);
    end
    
endmodule

module sync_rom9_4k(
    input wire          clk_in,
    
    input wire [11:0]   addr_in,
    output reg [8:0]    data_o
    );

reg [8:0] mem[4095:0];

always @(posedge clk_in)
    begin
        data_o <= #5 mem[addr_in];
    end
    

initial
    begin
        $readmemb("../../03_ROMS/hp67_9_bits_4k.bin", mem);
    end
    
endmodule

module sync_rom1(
    input wire          clk_in,
    
    input wire [12:0]   addr_in,
    output reg [0:0]    data_o
    );

reg [0:0] mem[8191:0];

always @(posedge clk_in)
    begin
        data_o <= #5 mem[addr_in];
    end
    

initial
    begin
        $readmemb("../../03_ROMS/hp67_1_bit.bin", mem);
    end
    
endmodule
`endif
`endif