module NWS(
    output wire			disp_cs_n_o,
	output wire			disp_addr_o,
	output wire			disp_sck_o,
	output wire			disp_data_o,
	output wire			disp_res_n_o,
	
	inout wire			col0l_o,
	inout wire			col1l_o,
	inout wire 			col2lt_o, // only top key
	inout wire			col2l_o,  // three key below, power together
	inout wire			col3l_o,
	inout wire			col4l_o,
	inout wire			col0r_o,
	inout wire			col1r_o,
	inout wire			col2r_o,
	inout wire			col3r_o,
	inout wire			col4r_o,
	
	input wire [3:0]	rowsl_in,
	input wire [3:0]	rowsr_in,
	output wire			txd_o,
	
	output wire [3:0]   ra_o,
	
    output wire         fetch_op0_o

);
wire [19:0] debug;
wire osc_clk;
reg [1:0] clk_div = 2'h0;

defparam ws.MXO2 = 1;
defparam ws.MAX10 = 0;
defparam ws.HP67 = 1;
defparam ws.HW_TRACE = 1;
defparam ws.HW_TRACE_MINI = 0;
defparam ws.DISP_DOGM132 = 1;
defparam ws.DISP_SSD1603 = 0;   
wire [4:0] kbd_columns;
// divider for the 2.08 MHz clock
//GSR GSR_INST (.GSR (gbl_reset));
//   Internal Oscillator 
//   defparam OSCH_inst.NOM_FREQ = "2.08";
//   This is the default frequency     

    defparam OSCH_inst.NOM_FREQ = "2.08"; 
    OSCH OSCH_inst( .STDBY(kbd_on_off), //  0=Enabled, 1=Disabled //  also Disabled with Bandgap=OFF                
                    .OSC(osc_clk),                
                    .SEDSTDBY()); //  this signal is not required if not //  using SED 
    // divide by 4 520000 Hz
    always @(posedge osc_clk)
        begin
            clk_div <= clk_div + 1'd1;
        end
assign col0l_o = kbd_columns[0] ? 1'b1:1'bz; // they have pull-downs
assign col0r_o = kbd_columns[0] ? 1'b1:1'bz; // they have pull-downs
assign col1l_o = kbd_columns[1] ? 1'b1:1'bz; // they have pull-downs
assign col1r_o = kbd_columns[1] ? 1'b1:1'bz; // they have pull-downs
assign col2lt_o= kbd_columns[2] ? 1'b1:1'bz; // they have pull-downs, top key has another pin due to routing issues
assign col2l_o = kbd_columns[2] ? 1'b1:1'bz; // they have pull-downs
assign col2r_o = kbd_columns[2] ? 1'b1:1'bz; // they have pull-downs
assign col3l_o = kbd_columns[3] ? 1'b1:1'bz; // they have pull-downs
assign col3r_o = kbd_columns[3] ? 1'b1:1'bz; // they have pull-downs
assign col4l_o = kbd_columns[4] ? 1'b1:1'bz; // they have pull-downs
assign col4r_o = kbd_columns[4] ? 1'b1:1'bz; // they have pull-downs

ws_hp67_xo2_7k  ws(
	.clk_in(clk_div[1]),     // only used in Simulation or Max 10 variant
    .disp_cs_n_o(disp_cs_n_o),
	.disp_addr_o(disp_addr_o),
	.disp_sck_o(disp_sck_o),
	.disp_data_o(disp_data_o),
	.disp_res_n_o(disp_res_n_o),
	
	.kbd_columns_o(kbd_columns),
	.rowsl_in(rowsl_in),
	.rowsr_in(rowsr_in),
	.txd_o(txd_o),	
	.debug_o(debug)
	);
endmodule
// Sync ROM for Simulation
module sync_rom(
    input wire          clk_in,
    
    input wire [12:0]   addr_in,
    output reg [9:0]    data_o
    );

wire [12:0] new_addr;
assign new_addr = addr_in[12:10] == 3'b000 ? { 1'b0, addr_in[11:0] }:
                  addr_in[12:10] == 3'b001 ? { 1'b0, addr_in[11:0] }:
                  addr_in[12:10] == 3'b010 ? { 1'b0, addr_in[11:0] }:
                  addr_in[12:10] == 3'b011 ? { 1'b0, addr_in[11:0] }:
                  addr_in[12:10] == 3'b100 ? { 1'b0, addr_in[11:0] }:
                  addr_in[12:10] == 3'b101 ? { 3'b100, addr_in[9:0] }: // bank 1 is located in the 4096..5119 area
                  addr_in[12:10] == 3'b110 ? { 1'b0, addr_in[11:0] }:
                                             { 1'b0, addr_in[11:0] };
reg [9:0] mem[5119:0];

always @(posedge clk_in)
    begin
        data_o <= #5 mem[new_addr];
    end

    
integer i;
initial
    begin
`ifdef CPU_TEST
        $readmemb("cpu_test.bin", mem);
`else
        $readmemb("hp-67.bin", mem);
`endif
    end
    
endmodule
