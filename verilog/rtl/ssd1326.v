/* Handles the display
 * ST1326 based OLED 256x32 graphic display
 * Glyphs are stored in ROM
 * 15 digits of 16x16 wide pixels 
 * The decimal point in the classic series occupies one digit
 */



module nclassic_display_ssd1326(
	input wire			clk_in,
    input wire          reset_n_in,           // asserted low reset
	input wire			op_disp_off_in,
	input wire			op_disp_toggle_in,
	input wire	[3:0]	ra_in,
	input wire	[3:0]	rb_in,
    input wire          seq_fetch_in,      // asserted when data for the display is to be latched/used
    output wire [3:0]   disp_curr_nibble_o, // controls which nibble should be output now
	output wire	      	disp_cs_n_o,
	output wire         disp_res_n_o,
    output wire         disp_data_o,
    output wire         disp_addr_o,
    output wire         disp_sck_o,
	output wire         disp_acq_o
	);
	
reg [3:0] state = 4'h0;
reg [3:0] scanned_digit = 4'h0; // index used to extract the information fromA and B
reg [3:0] digit_position = 4'h0; // display position
reg [5:0] x = 6'h0; // index in current glyph, 32 bytes per glyph
reg [4:0] curr_bit = 5'h0;
reg ss = 1'b0;
reg dispon = 1'b0;
reg send_ready = 1'b0;
reg disp_sck = 1'b0;
reg clock_active = 1'b0;
reg [3:0] glyph_addr;
reg [3:0] glyph_addr_latched = 4'h0;
reg [7:0] out_data = 8'h0;
reg [7:0] cmddata = 8'h0;
wire [7:0] glyph_data;
//reg force_refresh_f = 1'h0;
reg force_refresh = 1'h0;
reg [9:0] counter = 8'h0;
reg [7:0] glyphs [127:0];//[511:0]; // 16x16 glyphs 32 bytes
reg [7:0] initseq [31:0]; // 
reg [7:0] disp_content[13:0];

`define ST_RESET            4'h0
`define ST_WAIT_FOR_INIT    4'h1
`define ST_INIT             4'h2
`define ST_CLR_DISP         4'h3
`define ST_WAIT_FOR_TOGGLE  4'h4
`define ST_WAIT_FOR_DATA    4'h5
`define ST_SET_COL_CMD      4'h6
`define ST_SET_COL_START    4'h7
`define ST_SET_COL_END      4'h8
`define ST_REFRESH          4'h9
`define ST_SLEEP_CMD        4'hA
`define ST_POWER_DOWN       4'hB
`define ST_WAKE_UP          4'hC 

assign disp_sck_o = disp_sck;
assign disp_cs_n_o = ss;

assign disp_data_o = out_data[7]; // MSB first
assign disp_addr_o = (state == `ST_REFRESH) || (state == `ST_CLR_DISP);
assign disp_res_n_o = reset_n_in;

assign disp_curr_nibble_o = scanned_digit;

assign disp_acq_o = force_refresh;

// set address 

// [11:8] = 4'h1  3.45
// [11:8] = 4'h0 -3.45      entry
// [11:8] = 4'h3  3.45e-45  entry
// [11:8] = 4'h2 -3.45e-45  entry
// [11:8] = 4'h8 -3.45e-45  after enter
// [11:8] = 4'h9  3.45e-45  after enter
//

always @(*)
    begin
        if (rb_in[3] == 1'b1) // blank
            glyph_addr <= 4'hf;
        else
            if (rb_in == 4'h2) // decimal point
                glyph_addr <= 4'hb;
            else
                case (digit_position) // from right to left
                    4'd0: glyph_addr <= ra_in;
                    4'd1: glyph_addr <= ra_in;
                    4'd2: glyph_addr <= (ra_in[3] == 1'b1) ? 4'hd:4'hf;
                    4'd3: glyph_addr <= ra_in;
                    4'd4: glyph_addr <= ra_in;
                    4'd5: glyph_addr <= ra_in;
                    4'd6: glyph_addr <= ra_in;
                    4'd7: glyph_addr <= ra_in;
                    4'd8: glyph_addr <= ra_in;
                    4'd9: glyph_addr <= ra_in;
                    4'd10:glyph_addr <= ra_in;
                    4'd11:glyph_addr <= ra_in;
                    4'd12:glyph_addr <= ra_in;
                    4'd13:glyph_addr <= (ra_in[3] == 1'b1) ? 4'hd:4'hf; // used for minus sign
                    default: glyph_addr <= 4'hf; // blank default;
                endcase
    end
wire [7:0] glyph_data_c;
assign glyph_data_c = glyphs[{ glyph_addr_latched, x[5:3] } ];
assign glyph_data = (x[0] == 1'b0) ? { glyph_data_c[0], glyph_data_c[0], glyph_data_c[1], glyph_data_c[1], 
                                       glyph_data_c[2], glyph_data_c[2], glyph_data_c[3], glyph_data_c[3] }:
                                     { glyph_data_c[4], glyph_data_c[4], glyph_data_c[5], glyph_data_c[5],
                                       glyph_data_c[6], glyph_data_c[6], glyph_data_c[7], glyph_data_c[7] };



always @(posedge clk_in)
    begin
        if (reset_n_in == 1'b0)
            begin
                state <= 4'h0;
                ss <= 1'b1;
                send_ready <= 1'b1;
                scanned_digit <= 4'h0;
                digit_position <= 4'h0;
                x <= 6'h0;
                curr_bit <= 5'h0;
				force_refresh <= 1'b0;
                counter <= 10'h0;
            end
        else
            begin
				if (op_disp_off_in)
					begin
						dispon <= 1'b0;
					end
                if (op_disp_toggle_in)
                    begin
                        if (dispon)
                            dispon <= 1'b0;
                        else
                            begin
                                dispon <= 1'b1;
                                force_refresh <= 1'b1;
                            end
                    end
				if (clock_active)
                    disp_sck <= ~disp_sck;
                else
                    disp_sck <= 1'b0;
                
                case (state)
                    `ST_RESET: // 2ms delay after reset goes from low to high to allow for internal reset procedure
                        begin
                            if (op_disp_off_in) // 256 * 0.5 us = 1.28 ms
                                begin
                                    //counter <= 8'd0;
                                    state <= state + 4'd1;
                                end
                            //else
                            //    counter <= counter + 8'd1; 
                        end
                    `ST_INIT:
                        begin
                            if (send_ready == 1'b1)
                                begin
                                    if (counter == 8'd31)
                                        begin
                                            counter <= 8'd0;
                                            state <= state + 4'd1;
                                        end
                                    else
                                        counter <= counter + 8'd1;
                                    curr_bit <= 5'h0;
                                    send_ready <= 1'b0;
                                end
                        end
                    `ST_CLR_DISP:
                        begin
                            if (send_ready == 1'b1)
                                begin
                                    if (counter == 10'd1023)
                                        begin
                                            counter <= 9'd0;
                                            state <= state + 4'd1;
                                        end
                                    else
                                        counter <= counter + 10'd1;
                                    curr_bit <= 5'h0;
                                    send_ready <= 1'b0;
                                end
                        end
                    `ST_WAIT_FOR_TOGGLE: 
                        begin 
                            if (force_refresh)
                                begin
                                    state <= state + 4'd1;
                                    scanned_digit <= 4'h0; // refresh is from right to left exponent first
                                    digit_position <= 4'h0;
                                    x <= 6'h0; // from right to left because the column 0 is on the right
                                    force_refresh <= 1'b0;
                                    curr_bit <= 5'h0;
                                end
                        end
                    `ST_WAIT_FOR_DATA:
                        if (seq_fetch_in)
                            begin
                                glyph_addr_latched <= glyph_addr;
                                curr_bit <= 5'h0;
                                state <= state + 4'd1;
                                send_ready <= 1'b0;
                                x <= 6'h0;
                                if (digit_position == 4'hd) // display sign
                                    begin
                                        scanned_digit <= 4'h2;
                                    end
                                else
                                    scanned_digit <= scanned_digit + 4'd1;
                            end
                    `ST_REFRESH:
                        if (send_ready == 1'b1)
                            begin
                                if (x == 6'h3f)
                                    begin
                                        if (digit_position == 4'he)
                                            state <= `ST_WAIT_FOR_TOGGLE;
                                        else
                                            begin
                                                state <= `ST_WAIT_FOR_DATA;
                                                digit_position <= digit_position + 4'h1;
                                            end
                                    end
                                else
                                    begin
                                        x <= x + 6'd1; // from right to left because the column 0 is on the right
                                        curr_bit <= 5'h0;
                                        send_ready <= 1'b0;
                                    end
                            end
                    default:
                        if (send_ready == 1'b1)
                            begin
                                state <= state + 4'd1;
                                curr_bit <= 5'h0;
                                send_ready <= 1'b0;
                            end
                endcase
                // only send when curr_bit is < 19
                if (~send_ready)
                    begin
                        case (curr_bit)
                            5'd0: out_data <= cmddata; // data to shift
                            5'd1: begin clock_active <= 1'b1; ss <= 1'b0; end
                            5'd3, 4'h5, 4'h7, 4'h9,
                            5'd11, 5'd13, 5'd15: out_data <= out_data << 1;
                            5'd16: begin clock_active <= 1'b0; end
                            5'd18: begin ss <= 1'b1; send_ready <= 1'b1; end
                        endcase
                        curr_bit <= curr_bit + 5'h1;
                    end
            end
    end

    
// command/data according to the state machine
always @(*)
    begin
        cmddata = 8'h00;
        case (state)
            `ST_CLR_DISP: cmddata = 8'h00; // clear display 32*8 = 256
            `ST_WAIT_FOR_TOGGLE: cmddata = 8'hAF; // display ON
            `ST_SET_COL_CMD: cmddata = 8'h15;
            `ST_SET_COL_START: cmddata = { 3'b00, digit_position, 1'b0 }; // column 0..31 
            `ST_SET_COL_END: cmddata = { 3'b00, digit_position, 1'b1 }; // one digit only
            `ST_REFRESH: cmddata = glyph_data; /* A1 for inverted display */
            default:
                   cmddata = initseq[counter[4:0]];
        endcase
    end
    
   
initial
	begin
        $readmemb("../rtl/glyphs.bin", glyphs);
        $readmemh("../rtl//initseq.hex", initseq);
	end
	
endmodule