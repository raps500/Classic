/* HP Classic series - Top file
 *
 * Classic Portrait keyboard layout
 * 10-bit sync memory for program
 *
 * (c) Copyright 2018-2019 R.A. Paz S.
 * 
 */
`include "nclassic_defs.v" 
`default_nettype none
`timescale 1ns/1ns

module NClassic_core #(
    parameter [0:0] MXO2 = 0,
    parameter [0:0] HP35 = 0,
    parameter [0:0] HP45 = 1,
    parameter [0:0] HP65 = 0,
    parameter [0:0] HW_TRACE = 1,
    parameter [0:0] HW_TRACE_MINI = 0,
    parameter [0:0] DISP_DOGM132 = 0,
    parameter [0:0] DISP_SSD1326 = 1    
)
(
    input wire          clk_in,     // ~1 MHz clock needed when trace is active
    output wire         disp_cs_n_o,
    output wire         disp_addr_o,
    output wire         disp_sck_o,
    output wire         disp_data_o,
    output wire         disp_res_n_o,
    input wire          pgm_in,         // Progam mode, asserted HIGH normal pull-down
    input wire          batt_in,        // Battery status 0 = healthy, 1 = not so healthy
	
    output wire [4:0]   key_columns_o,    
    input wire [7:0]    rows_in,
    output wire         txd_o
`ifdef SIMULATOR
    ,
    input wire          simkey_activate_key_pending_in,
    input wire [7:0]    simkey_keycode_in
`endif
	,
	output wire [23:0]  debug_o
    );

/* Reset and clocking */
reg cpu_reset_n = 1'b0;
reg [5:0] reset_cnt = 6'h0;
wire cpu_clk, tx_clk;

/* Decoder */

reg [3:0] dec_op_alu;
reg dec_f_set_carry;
reg [6:0] dec_reg_op1;
reg [6:0] dec_reg_dst;
reg [3:0] dec_lit_operand;
reg [3:0] dec_field_start;
reg [3:0] dec_field_end;

reg dec_f_bank;
reg dec_f_clr_status;
reg dec_f_clr_flag;
reg dec_f_delayed;
reg dec_f_disp_toggle;
reg dec_f_disp_off;
reg dec_f_gto_c_clr;
reg dec_f_gto_c_set;
reg dec_f_jump;
reg dec_f_gonc;
reg dec_f_use_delay_rom;
reg dec_f_nop;
reg dec_f_pop_pc;
reg dec_f_push_pc;
reg [2:0] dec_p_func;
reg dec_f_set_hex;
reg dec_f_set_dec;
reg dec_f_set_flag;
reg dec_f_test_clr_flag;
reg dec_f_test_set_flag;
reg dec_f_key_ack;
reg dec_f_set_carry_early;
reg [11:0] dec_jaddr;
reg dec_f_rol      ;
reg dec_f_lsl      ;
reg dec_f_lsr      ;
reg dec_f_tfr      ;
reg dec_f_exchange ;
reg dec_f_wr_alu   ;
reg dec_f_wr_lit   ; // load constant into C
reg dec_f_push_c   ;
reg dec_f_pop_a    ;
reg dec_f_clr_regs ;
reg dec_f_clr_dregs;
reg dec_f_rot_stack;

// Opcode field translators

wire [3:0] dec_lit_ldi_p, dec_lit_cmp_p;
wire [3:0] dec_op_field_start, dec_op_field_end;

// Registers
reg [3:0] SPC = 4'h0;
reg [7:0] RPC = 8'h00;              // Program counter
reg [7:0] STACK;
reg [3:0] RP = 4'h0;                // Pointer register
reg [5:0] DATAADDR = 6'h0;          // Data address register
reg [11:4] RA;                      // copy of RA[11:4] for jump to a
reg f_carry = 1'b0;                 // result from current instrction

reg [11:0] f_hw_status;
reg [2:0] bank = 3'h0;

// Register P outputs

reg reg_p_set_carry;
reg p_crossed_inc = 1'b0;
reg p_crossed_dec = 1'b0;
// Registers and Arithmetic outputs

(* syn_keep=1 *) wire [10:0] regbank_addr_a;
(* syn_keep=1 *) wire [10:0] regbank_addr_b;

(* syn_keep=1 *) wire [3:0] reg_path_a;
(* syn_keep=1 *) wire [3:0] reg_path_b;
(* syn_keep=1 *) wire [3:0] data_from_regbank_path_a;
(* syn_keep=1 *) wire [3:0] data_from_regbank_path_b;
(* syn_keep=1 *) wire [3:0] data_to_reg_b;
// ALU registers and signals
wire [3:0] alu_out;             // alu output to register bank
wire alu_set_carry;
// intermediate values
wire [3:0] alu_q_add, alu_q_sub, alu_q_rsub;

wire alu_qc_add, alu_qc_sub, alu_qc_rsub;

/* compare unit */
reg [2:0] alu_comp_res = 3'h0;
wire alu_eq, alu_neq, alu_gt;
reg alu_icarry = 1'b0;

// Sequencer outputs
// these outputs are only active for one, sometimes more than one state of the sequencer
wire seq_fetch_op0;
wire seq_fetch_op1;
wire seq_fetch_op2;
wire seq_decode;
wire seq_exe;
wire seq_jump;
wire seq_alu_prep;
wire seq_alu_wback;
wire seq_alu_read3;
wire seq_reg_transfer;
wire seq_reg_write_alu_or_lit;
wire seq_reg_read;
wire seq_reg_exchange;

(* syn_keep=1 *) reg [6:0] seq_op1;             // operand 1 name from sequencer
(* syn_keep=1 *) reg [6:0] seq_dst;             // operand 2 and destination name from sequencer
(* syn_keep=1 *) reg [3:0] seq_op1_nibble;      // operand 1 current nibble from sequencer
(* syn_keep=1 *) reg [3:0] seq_dst_nibble;      // operand 2/destination current nibble from sequencer

reg seq_fetch_op1_delayed = 1'b0;
reg [9:0] seq_opcode = 10'h0;   // latched opcode
reg [9:0] seq_opcode2 = 10'h0;   // latched opcode 2nd word
reg [11:0] seq_fetched_addr;    // address of the  current fetched opcode 1st word if multiword
reg [11:0] seq_ifaddr = 12'h0;  // target address of the two word if opcode
reg seq_wback_carry = 1'b0;

reg [3:0] seq_state = `ST_INIT;
reg seq_field_ofs = 1'h0;
reg [3:0] seq_field_counter= 4'h0;
reg seq_latched_carry = 1'b0;         // result from last instruction
assign seq_fetch_op0 = seq_state == `ST_FETCH_OP0;
assign seq_fetch_op1 = seq_state == `ST_FETCH_OP1;
assign seq_fetch_op2 = seq_state == `ST_FETCH_OP2;
assign seq_decode = seq_state == `ST_DECODE;
assign seq_exe = seq_state == `ST_EXE_NORM;
assign seq_jump = seq_state == `ST_JUMP;
assign seq_alu_prep = seq_state == `ST_AT_PREP;
assign seq_alu_read3 = seq_state == `ST_AT_READ3;
assign seq_alu_wback = seq_state == `ST_AT_WBACK;
// these three signals are not state dependant
assign seq_reg_transfer = dec_f_tfr | dec_f_clr_regs | dec_f_rol | dec_f_lsl | dec_f_lsr |
                          dec_f_clr_dregs | dec_f_pop_a | dec_f_push_c;

assign seq_reg_write_alu_or_lit = (dec_op_alu == `ALU_ADD) | (dec_op_alu == `ALU_SUB) | (dec_op_alu == `ALU_RSUB);
assign seq_reg_exchange = dec_f_exchange | dec_f_rot_stack;
assign seq_reg_read = (seq_state == `ST_FETCH_OP1) | (seq_state == `ST_FETCH_OP2) | (seq_state == `ST_HW_TRACE_READ) | (seq_state == `ST_HW_TRACE_OUTPUT);
// using combinatorial outputs as write enable seems to cause erratic synthesis results, sometimes works sometimes doesn't
// registered enables seem to solve the problem
reg seq_write_path_b = 1'b0; // registered write enable for the register bank path a
reg seq_write_path_a = 1'b0; // registered write enable for the register bank path b

// Keyboard connections

wire [7:0] key_keycode; // current pressed key
wire key_pending;

reg key_pgm_mode;
wire key_on_off;
//
wire disp_acq;

assign debug_o[ 3 :0] = reg_path_a; //data_from_regbank_path_a;//regbank_addr_a[10:8];
assign debug_o[ 7: 4] = reg_path_b; //data_from_regbank_path_b;//regbank_addr_a[7:4];
assign debug_o[11: 8] = alu_out;//regbank_addr_a[3:0];
assign debug_o[14:12] = 3'b0;
assign debug_o[15:15] = alu_icarry;
assign debug_o[16:16] = alu_set_carry;
assign debug_o[17:17] = seq_alu_wback;

assign debug_o[18:18] = RPC == 12'h6B4;
assign debug_o[19:19] = cpu_clk;
assign debug_o[23:20] = SPC;



wire [3:0] disp_curr_nibble;

assign cpu_clk = clk_in;
assign tx_clk = clk_in;

    always @(posedge cpu_clk)
        begin
            if (reset_cnt != 6'd62)
                begin
                    reset_cnt <= reset_cnt + 6'd1;
                    cpu_reset_n <= 1'b0;
                end
            else
                cpu_reset_n <= 1'b1;
        end
`ifdef DOGM132
// Display output
ws_display_dogm132 ws_dogm132(
    .clk_in(cpu_clk),
    .reset_in(cpu_reset_n),
    .op_disp_off_in(dec_f_disp_off & seq_exe),
    .op_disp_toggle_in(dec_f_disp_toggle & seq_exe),
    .ra_in(data_from_regbank_path_a),
    .rb_in(data_from_regbank_path_b),
    .seq_fetch_op0(seq_fetch_op1_delayed),      // asserted when data for the display is to be latched/used
    .disp_curr_nibble_o(disp_curr_nibble), // controls which nibble should be output now
    .disp_cs_n_o(disp_cs_n_o),
    .disp_res_n_o(disp_res_n_o),
    .disp_data_o(disp_data_o),
    .disp_addr_o(disp_addr_o),
    .disp_sck_o(disp_sck_o),
	.disp_acq_o(disp_acq)
);
`endif

// Display output
nclassic_display_ssd1326 ssd1326(
    .clk_in(cpu_clk),
    .reset_n_in(cpu_reset_n),
    .op_disp_off_in(dec_f_disp_off & seq_exe),
    .op_disp_toggle_in(dec_f_disp_toggle & seq_exe),
    .ra_in(data_from_regbank_path_a),
    .rb_in(data_from_regbank_path_b),
    .seq_fetch_in(seq_fetch_op1_delayed),      // asserted when data for the display is to be latched/used
    .disp_curr_nibble_o(disp_curr_nibble), // controls which nibble should be output now
    .disp_cs_n_o(disp_cs_n_o),
    .disp_res_n_o(disp_res_n_o),
    .disp_data_o(disp_data_o),
    .disp_addr_o(disp_addr_o),
    .disp_sck_o(disp_sck_o),
	.disp_acq_o(disp_acq)
);
wire [10:0] fetch_addr;
wire [9:0] rom_opcode;
assign fetch_addr = { bank, RPC }; // use actual PC value, it is incremented automatically on stages FETCH_OP0 and FETCH_OP2

sync_rom rom(
    .clk_in(cpu_clk),
    .addr_in(fetch_addr),
    .data_o(rom_opcode)
    );  
// Trace unit 
wire [7:0] trace_tx_data;
reg trace_tx_start;
wire trace_tx_busy;
reg trace_tx_space;
reg trace_tx_cr;
wire [3:0] trace_tx_hex_d;
reg [4:0] trace_state;
wire trace_key_enable;  // TRACE mode enabled by keyboard command
assign trace_key_enable = HW_TRACE;

reg [2:0] trace_delay = 3'd0;

generate if (HW_TRACE)
    begin

assign trace_tx_hex_d = (seq_op1 == `OP1_PC) ? ((seq_op1_nibble == 4'h3) ? { 3'h0, bank }:
                                                (seq_op1_nibble == 4'h2) ? seq_fetched_addr[11:8]:
                                                (seq_op1_nibble == 4'h1) ? seq_fetched_addr[ 7:4]:seq_fetched_addr[3:0]):
                        (seq_op1 == `OP1_CNT) ?((seq_op1_nibble == 4'h2) ? { 2'h0, seq_opcode[9:8] }:
                                                (seq_op1_nibble == 4'h1) ? seq_opcode[ 7:4]:seq_opcode[3:0]): 
                        (seq_op1 == `OP1_0)   ? RP:
                        reg_path_a;

assign trace_tx_data = trace_tx_space ? 8'h20:
                       trace_tx_cr ? 8'h0d:
                       trace_tx_hex_d > 4'h9 ? { 4'h4, 4'h7 + trace_tx_hex_d }:{ 4'h3, trace_tx_hex_d };

        async_transmitter txer(
            .clk(tx_clk),
            .TxD_start(trace_tx_start),
            .TxD_data(trace_tx_data),
            .TxD(txd_o),
            .TxD_busy(trace_tx_busy)
        );
    end
endgenerate

//
// Keyboard
//

always @(posedge cpu_clk)
	begin
		key_pgm_mode <= pgm_in;
	end

nclassic_keys_portrait keys(
    .clk_in(cpu_clk), // use processor clock for sync purposes
    .reset_in(cpu_reset_n),
    .key_read_ack_in(dec_f_key_ack & (seq_exe | seq_alu_wback)),
    .keys_rows_in(rows_in),
    .key_cols_o(key_columns_o),
    .keycode_o(key_keycode),
    .key_pending_o(key_pending),
  
    .do_scan_in((dec_lit_operand == 4'hf) && (dec_f_test_clr_flag == 1'b1) && (seq_exe == 1'b1)),
    .clear_pending_in(((dec_f_key_ack == 1'b1) && (seq_exe == 1'b1)) |
                      (dec_lit_operand == 4'h0) && (dec_f_test_clr_flag == 1'b1) && (seq_exe == 1'b1)
    ) 
`ifdef SIMULATOR
    ,
    .simkey_activate_key_pending_in(simkey_activate_key_pending_in),
    .simkey_keycode_in(simkey_keycode_in)
`endif
    );

/*************************************************************************/
/*************************************************************************/
// Decoder


always @(*)
    begin
        dec_op_alu =            `ALU_NONE;
        dec_f_set_carry =       1'b0;
        dec_reg_op1 =           `OP1_A;
        dec_reg_dst =           `DST_A;
        dec_lit_operand =       seq_opcode[9:6];
        dec_field_start =       4'h0;
        dec_field_end =         4'hd;
        dec_f_bank =            1'b0;
        dec_f_disp_toggle =     1'b0;
        dec_f_disp_off =        1'b0;
        dec_f_gto_c_clr =       1'b0; /* goto on carry clear, for tests */
        dec_f_gto_c_set =       1'b0; /* goto on carry set, for tests */
        dec_f_jump =            1'b0; // jumps without delay rom 
        dec_f_use_delay_rom   = 1'b0; // selects delay rom during write back of new PC
        dec_f_gonc            = 1'b0; // checks for carry cleared during ST_JUMP
        dec_f_nop =             1'b0;
        dec_f_pop_pc =          1'b0; /* rtn */
        dec_f_push_pc =         1'b0;
        dec_p_func =            `P_NONE;
        dec_f_clr_status =      1'b0;
        dec_f_clr_flag =        1'b0;
        dec_f_set_flag =        1'b0;
        dec_f_test_clr_flag =   1'b0;
        dec_f_test_set_flag =   1'b0;
        dec_f_key_ack =         1'b0;
        dec_f_set_carry_early = 1'b0; // use to set the carry for opcodes that need a 1 as dec_lit_operand
        dec_jaddr =             { bank, seq_opcode[9:2] };  // jump address are absolute
        dec_f_rol             = 1'b0;
        dec_f_lsl             = 1'b0;
        dec_f_lsr             = 1'b0;
        dec_f_tfr             = 1'b0;
        dec_f_exchange        = 1'b0;
        dec_f_wr_alu          = 1'b0;
        dec_f_wr_lit          = 1'b0; // load constant into C
        dec_f_push_c          = 1'b0;
        dec_f_pop_a           = 1'b0;
        dec_f_clr_regs        = 1'b0;
        dec_f_clr_dregs       = 1'b0;
        dec_f_rot_stack       = 1'b0;
        case (seq_opcode[1:0])
            2'b00: // general opcodes
                begin
                    case (seq_opcode[9:2])
                        // nop
                        8'b0000_0000: dec_f_nop = 1'b1;
                        // 1-> s[n]
                        8'b0000_0001, 8'b0001_0001, 8'b0010_0001, 8'b0011_0001,
                        8'b0100_0001, 8'b0101_0001, 8'b0110_0001, 8'b0111_0001,
                        8'b1000_0001, 8'b1001_0001, 8'b1010_0001, 8'b1011_0001: dec_f_set_flag = 1'b1;
                        8'b1100_0001, 8'b1101_0001, 8'b1110_0001, 8'b1111_0001: dec_f_nop = 1'b1;
                        // Load Constant to P, carry cleared from reg_p module
                        8'b0000_0011, 8'b0001_0011, 8'b0010_0011, 8'b0011_0011,
                        8'b0100_0011, 8'b0101_0011, 8'b0110_0011, 8'b0111_0011,
                        8'b1000_0011, 8'b1001_0011, 8'b1010_0011, 8'b1011_0011,
                        8'b1100_0011, 8'b1101_0011, 8'b1110_0011, 8'b1111_0011: dec_p_func = `P_LOAD; 
                        // keys -> rom
                        8'b0011_0100: begin dec_jaddr = { bank, key_keycode[7:0] }; dec_f_jump = 1'b1; dec_f_key_ack = 1'b1; end// keys-> rom 
                        // select rom
                        8'b0000_0100, 8'b0010_0100, 
                        8'b0100_0100, 8'b0110_0100, 
                        8'b1000_0100, 8'b1010_0100,
                        8'b1100_0100, 8'b1110_0100:
                                      begin dec_jaddr = { seq_opcode[9:7], RPC[7:0] }; dec_f_jump = 1'b1; end // select rom
                        // if s[n] # 1 / = 0
                        8'b0000_0101, 8'b0001_0101, 8'b0010_0101, 8'b0011_0101,
                        8'b0100_0101, 8'b0101_0101, 8'b0110_0101, 8'b0111_0101,
                        8'b1000_0101, 8'b1001_0101, 8'b1010_0101, 8'b1011_0101: begin dec_f_test_clr_flag = 1'b1; dec_f_gto_c_clr = 1'b1; end // if 0 = s
                        8'b1100_0101, 8'b1101_0101, 8'b1110_0101, 8'b1111_0101:  dec_f_nop = 1'b1;
                        // load constant
                        8'b0000_0110, 8'b0001_0110, 8'b0010_0110, 8'b0011_0110,
                        8'b0100_0110, 8'b0101_0110, 8'b0110_0110, 8'b0111_0110,
                        8'b1000_0110, 8'b1001_0110, 8'b1010_0110, 8'b1011_0110,
                        8'b1100_0110, 8'b1101_0110, 8'b1110_0110, 8'b1111_0110: 
                                      begin dec_f_tfr = 1'b1; dec_reg_dst = `DST_C; dec_reg_op1 = `OP1_CNT; 
                                            dec_field_start = RP; dec_field_end = RP; dec_p_func = `P_DEC_P; end // Load Constant @P                        
                        8'b0000_0111: dec_p_func = `P_DEC_P;
                        8'b0000_1111: dec_p_func = `P_INC_P;
                        // 0 -> s[n]
                        8'b0000_1001, 8'b0001_1001, 8'b0010_1001, 8'b0011_1001,
                        8'b0100_1001, 8'b0101_1001, 8'b0110_1001, 8'b0111_1001,
                        8'b1000_1001, 8'b1001_1001, 8'b1010_1001, 8'b1011_1001: dec_f_clr_flag = 1'b1;
                        8'b1100_1001, 8'b1101_1001, 8'b1110_1001, 8'b1111_1001: dec_f_nop = 1'b1;
                        // display toggle
                        8'b0000_1010: dec_f_disp_toggle = 1'b1;
                        // c exchange m
                        8'b0010_1010: begin dec_f_exchange = 1'b1;  dec_reg_dst = `DST_C; dec_reg_op1 = `OP1_M1; dec_field_end = 4'hd; end// c <-> m1
                        // c -> stack
                        8'b0100_1010: dec_f_push_c = 1'b1; // t = z, z = y, y = c
                        // stack -> a
                        8'b0110_1010: dec_f_pop_a = 1'b1; // a = y, y = z, z = t
                        // display off
                        8'b1000_1010: dec_f_disp_off = 1'b1;
                        // m -> c
                        8'b1010_1010: begin dec_f_tfr = 1'b1; dec_reg_dst = `DST_C; dec_reg_op1 = `OP1_M1; dec_field_end = 4'hd; end // m1 -> C
                        // down rotate
                        8'b1100_1010: dec_f_rot_stack = 1'b1;
                        // clear regs
                        8'b1110_1010: dec_f_clr_regs = 1'b1;
                        // if p # n
                        8'b0000_1011, 8'b0001_1011, 8'b0010_1011, 8'b0011_1011,
                        8'b0100_1011, 8'b0101_1011, 8'b0110_1011, 8'b0111_1011,
                        8'b1000_1011, 8'b1001_1011, 8'b1010_1011, 8'b1011_1011,
                        8'b1100_1011, 8'b1101_1011, 8'b1110_1011,
                        8'b1111_1011: begin dec_p_func = `P_CMP_NEQ; dec_f_gto_c_clr = 1'b1; end// if p =/# 0 
                        // return
                        8'b0000_1100: begin dec_f_pop_pc = 1'b1; end
                        // c -> data address
                        8'b1001_1100: begin dec_f_tfr = 1'b1; dec_reg_dst = `DST_DA; dec_reg_op1 = `OP1_C; dec_field_end = 4'hC; dec_field_start = 4'hC; end// C -> DA
                        // c -> data
                        8'b1011_1100: begin dec_f_tfr = 1'b1; dec_reg_dst = { 1'b0, DATAADDR }; dec_reg_op1 = `OP1_C; end // C -> reg[DA]
                        // clear status
                        8'b0000_1101: dec_f_clr_status = 1'b1;
                        // data -> c
                        8'b1011_1110: begin dec_f_tfr = 1'b1; dec_reg_dst = `OP1_C;  dec_reg_op1 = { 1'b0, DATAADDR}; end // C -> reg n                     
                        default: 
                            begin
                                dec_f_nop = 1'b1;
                                $display("%1x:%02x %1x:%03o %04b.%04b.%02b unrecognized opcode", 
                                         bank, seq_fetched_addr[7:0], bank, seq_fetched_addr[7:0],
                                         seq_opcode[9:6], seq_opcode[5:2], seq_opcode[1:0]);
                                $finish;
                            end
                    endcase
                end
            2'b01: // jsb
                begin
                    dec_f_push_pc = 1'b1;
                    dec_f_use_delay_rom = 1'b1;
                    dec_f_jump = 1'b1;
                end
            2'b10: // arithmetic opcodes
                begin
                    dec_field_start = dec_op_field_start; // load translated field pointers
                    dec_field_end = dec_op_field_end; // load translated field pointers
                    case (seq_opcode[9:5])
                        5'b00000: begin dec_op_alu = `ALU_EQ;  dec_reg_op1 = `OP1_0; dec_reg_dst = `DST_B; dec_f_set_carry = 1'b1; dec_f_gto_c_set = 1'b1; end // if 0 = b
                        5'b00001: begin dec_f_tfr = 1'b1; dec_reg_op1 = `OP1_0; dec_reg_dst = `DST_B; end // 0 -> b[w ]
                        5'b00010: begin dec_op_alu = `ALU_GTEQ;dec_reg_op1 = `OP1_A; dec_reg_dst = `DST_C; dec_f_set_carry = 1'b1; dec_f_gto_c_set = 1'b1; end // if a >= c
                        5'b00011: begin dec_op_alu = `ALU_NEQ; dec_reg_op1 = `OP1_0; dec_reg_dst = `DST_C; dec_f_set_carry = 1'b1; dec_f_gto_c_set = 1'b1; end // if 0 # c
                        5'b00100: begin dec_f_tfr = 1'b1; dec_reg_op1 = `OP1_B; dec_reg_dst = `DST_C; end // b -> c[wp]
                        5'b00101: begin dec_op_alu = `ALU_RSUB;dec_reg_op1 = `OP1_0; dec_reg_dst = `DST_C; dec_f_set_carry = 1'b1; end // 0 - c -> c[s ]
                        5'b00110: begin dec_f_tfr = 1'b1; dec_reg_op1 = `OP1_0; dec_reg_dst = `DST_C; end // 0 -> c[w ]
                        5'b00111: begin dec_op_alu = `ALU_RSUB;dec_reg_op1 = `OP1_9; dec_reg_dst = `DST_C; dec_f_set_carry = 1'b1; end // 0 - c - 1 -> c[s ]
                        5'b01000: begin dec_f_lsl = 1'b1; dec_reg_op1 = `OP1_A; dec_reg_dst = `DST_A; end // shift left a[w ] 
                        5'b01001: begin dec_f_tfr = 1'b1; dec_reg_op1 = `OP1_A; dec_reg_dst = `DST_B; end //  a -> b[x ]
                        5'b01010: begin dec_op_alu = `ALU_RSUB;dec_reg_op1 = `OP1_A; dec_reg_dst = `DST_C; dec_f_set_carry = 1'b1; end // a - c -> c[s ]
                        5'b01011: begin dec_op_alu = `ALU_SUB; dec_reg_op1 = `OP1_0; dec_reg_dst = `DST_C; dec_f_set_carry = 1'b1; dec_f_set_carry_early = 1'b1; end // c - 1 -> c[x ] carry used as constant 1
                        5'b01100: begin dec_f_tfr = 1'b1; dec_reg_op1 = `OP1_C; dec_reg_dst = `DST_A; end // c -> a[w ]
                        5'b01101: begin dec_op_alu = `ALU_EQ;  dec_reg_op1 = `OP1_0; dec_reg_dst = `DST_C; dec_f_set_carry = 1'b1; dec_f_gto_c_set = 1'b1; end // if 0 = c
                        5'b01110: begin dec_op_alu = `ALU_ADD; dec_reg_op1 = `OP1_A; dec_reg_dst = `DST_C; dec_f_set_carry = 1'b1; end // a + c -> c[x ]
                        5'b01111: begin dec_op_alu = `ALU_ADD; dec_reg_op1 = `OP1_0; dec_reg_dst = `DST_C; dec_f_set_carry = 1'b1; dec_f_set_carry_early = 1'b1; end // c + 1 -> c[xs] carry used as constant 1
                        5'b10000: begin dec_op_alu = `ALU_GTEQ;dec_reg_op1 = `OP1_A; dec_reg_dst = `DST_B; dec_f_set_carry = 1'b1; dec_f_gto_c_set = 1'b1; end // if a >= b
                        5'b10001: begin dec_f_exchange = 1'b1;  dec_reg_op1 = `OP1_B; dec_reg_dst = `DST_C; end // b exchange c[w ]
                        5'b10010: begin dec_f_lsr = 1'b1; dec_reg_op1 = `OP1_C; dec_reg_dst = `DST_C; end // shift right c[w ]
                        5'b10011: begin dec_op_alu = `ALU_NEQ; dec_reg_op1 = `OP1_0; dec_reg_dst = `DST_A; dec_f_set_carry = 1'b1; dec_f_gto_c_set = 1'b1; end // if 0 # a
                        5'b10100: begin dec_f_lsr = 1'b1; dec_reg_op1 = `OP1_B; dec_reg_dst = `DST_B; end // shift right b[wp]
                        5'b10101: begin dec_op_alu = `ALU_ADD; dec_reg_op1 = `OP1_C; dec_reg_dst = `DST_C; dec_f_set_carry = 1'b1; end // c + c -> c[w ]
                        5'b10110: begin dec_f_lsr = 1'b1; dec_reg_op1 = `OP1_A; dec_reg_dst = `DST_A; end // shift right a[wp]
                        5'b10111: begin dec_f_tfr = 1'b1; dec_reg_op1 = `OP1_0; dec_reg_dst = `DST_A; end // 0 -> a[w ]
                        5'b11000: begin dec_op_alu = `ALU_SUB; dec_reg_op1 = `OP1_B; dec_reg_dst = `DST_A; dec_f_set_carry = 1'b1; end // a - b -> a[ms]
                        5'b11001: begin dec_f_exchange = 1'b1;  dec_reg_op1 = `OP1_A; dec_reg_dst = `DST_B; end // a exchange b[wp]
                        5'b11010: begin dec_op_alu = `ALU_SUB; dec_reg_op1 = `OP1_C; dec_reg_dst = `DST_A; dec_f_set_carry = 1'b1; end // a - c -> a[wp]
                        5'b11011: begin dec_op_alu = `ALU_SUB; dec_reg_op1 = `OP1_0; dec_reg_dst = `DST_A; dec_f_set_carry = 1'b1; dec_f_set_carry_early = 1'b1; end // a - 1 -> a[s ] carry used as constant 1
                        5'b11100: begin dec_op_alu = `ALU_ADD; dec_reg_op1 = `OP1_B; dec_reg_dst = `DST_A; dec_f_set_carry = 1'b1; end // a + b -> a[ms]
                        5'b11101: begin dec_f_exchange = 1'b1;  dec_reg_op1 = `OP1_A; dec_reg_dst = `DST_C; end // a exchange c[w ]
                        5'b11110: begin dec_op_alu = `ALU_ADD; dec_reg_op1 = `OP1_C; dec_reg_dst = `DST_A; dec_f_set_carry = 1'b1; end // a + c -> a[m ]
                        5'b11111: begin dec_op_alu = `ALU_ADD; dec_reg_op1 = `OP1_0; dec_reg_dst = `DST_A; dec_f_set_carry = 1'b1; dec_f_set_carry_early = 1'b1; end // a + 1 -> a[p ] carry used as constant 1
                    endcase
                end
            2'b11: // gonc
                begin
                    dec_f_gonc = 1'b1;
                end
        endcase
    end

/*************************************************************************/
/*************************************************************************/
// Disassembler
wire [199:0] dis_opcode;

NClassic_disasm disasm(
    .addr_in(seq_fetched_addr),
    .opcode_in(seq_opcode),
    .op2_in(seq_opcode2),
    .o_o(dis_opcode)
    );
    
/************************************************************************/
/************************************************************************/
// Field translators

nclassic_field_decoder field_decoder(
    .field_in(seq_opcode[4:2]), // .....fff..
    .p_in(RP), // register P
    .start_o(dec_op_field_start), 
    .end_o(dec_op_field_end)
    );

assign dec_lit_ldi_p = seq_opcode[9:6]; // unscrambled
assign dec_lit_cmp_p = seq_opcode[9:6]; // unscrambled

/************************************************************************/
/************************************************************************/
// PC & Stack

always @(posedge cpu_clk)
    begin
        if (seq_fetch_op0 | seq_fetch_op2)
            RPC <= RPC + 12'd1;
        else
            if (dec_f_pop_pc & seq_exe) // returns
                begin
                    RPC <= STACK;
                    STACK <= 8'h0;
                end
            else
                if (seq_jump)
                    begin
                        // flag tests, register compare
                        //if (dec_f_gto_c_set) // double word instructions use current carry
                        //    begin
                        //        if (f_carry) RPC <= seq_ifaddr; 
                        //    end
                        //else
                        //    if (dec_f_gto_c_clr) // double word instructions use current carry
                        //        begin
                        //            if (~f_carry)
                        //                RPC <= seq_ifaddr;
                        //        end
                        //    else
                                begin
                                    RPC <= dec_jaddr[7:0];
                                    bank <= dec_jaddr[10:8];
                                end
                    end
        if (dec_f_push_pc & seq_exe)
            begin
                STACK <= RPC;
            end
    end

/************************************************************************/
/************************************************************************/
// Register P

always @(posedge cpu_clk)
    begin
        if (seq_exe | seq_alu_wback)
            begin
                case (dec_p_func)
                    `P_NONE: begin end
                    `P_INC_P: 
                        begin
                            if (RP == 4'hd) begin RP <= 4'h0; p_crossed_inc <= 1'b1; end
                            else
                                begin 
                                    RP <= RP + 4'h1;
                                    if ((p_crossed_inc) && (RP != 4'h0))
                                        p_crossed_inc <= 1'b0;
                                end
                            p_crossed_dec <= 1'b0;
                        end
                    `P_DEC_P:
                        begin
                            if (RP == 4'h0) begin RP <= 4'hd; p_crossed_dec <= 1'b1; end
                            else 
                                begin 
                                    RP <= RP - 4'h1; 
                                    if ((p_crossed_dec) && (RP != 4'hd)) // extend it for one cycle if is a chain of decrements
                                        p_crossed_dec <= 1'b0;
                                end
                            p_crossed_inc <= 1'b0;
                        end
                    `P_LOAD: 
                        begin
                            RP <= dec_lit_ldi_p;
                            p_crossed_inc <= 1'b0;
                            p_crossed_dec <= 1'b0;
                        end
                endcase
            end
    end

always @(*)
    begin
        reg_p_set_carry = 1'b0;
        case (dec_p_func)
            `P_CMP_NEQ:
                begin
                    if (RP == dec_lit_cmp_p) reg_p_set_carry = 1'b1; // condition is reversed because the jump is if not carry
                end
            default: reg_p_set_carry = 1'b0;
        endcase
    end

/************************************************************************/
/************************************************************************/
// Data and Arithmetic Registers

/*
 * A dual ported memory is used for all registers
 * path a is operand 1 and path b is operand 2/destination
 * two clocks are needed to read and write to the memory
 * clock one reads, clock two writes
 * The first 64 registers are used as registers and the next 64 registers as CPU registers A, B, C. X, Y Z and M1, M2
 */

assign #100 regbank_addr_a = { seq_op1, seq_op1_nibble };
assign #100 regbank_addr_b = { seq_dst, seq_dst_nibble };

// Data comes to port b from transfer (also shifts), exchange or add/sub
assign data_to_reg_b = (seq_reg_exchange | seq_reg_transfer) ? reg_path_a:alu_out; // 

`ifdef MXO2
            regbank_lattice regs (
                .DataInA(reg_path_b), 
                .AddressA(regbank_addr_a), 
                .ClockA(cpu_clk), 
                .ClockEnA(1'b1),//seq_reg_read | (seq_reg_exchange & seq_alu_wback)), 
                .WrA(seq_write_path_a), //seq_reg_exchange & seq_alu_wback),//
                .ResetA(1'b0), 
                .QA(data_from_regbank_path_a), 
                
                .DataInB(data_to_reg_b), 
                .AddressB(regbank_addr_b), 
                .ClockB(cpu_clk), 
                .ClockEnB(1'b1),//((seq_reg_transfer | seq_reg_write_alu_or_lit | seq_reg_exchange) & seq_alu_wback) | seq_reg_read), 
                .WrB(seq_write_path_b), //(seq_reg_transfer | seq_reg_write_alu_or_lit | seq_reg_exchange) & seq_alu_wback),//
                .ResetB(1'b0), 
                .QB(data_from_regbank_path_b)
                );
`endif
`ifdef SIMULATOR
            dp_reg_bank regs(
                .clk_in(cpu_clk),
                .seq_decode_in(seq_decode),
                .wea_in(seq_write_path_a), //seq_reg_exchange & seq_alu_wback),
                .dataa_in(reg_path_b),
                .addra_in(regbank_addr_a),
                .dataa_o(data_from_regbank_path_a),
                
                .web_in(seq_write_path_b), //(seq_reg_transfer | seq_reg_write_alu_or_lit | seq_reg_exchange) & seq_alu_wback),
                .datab_in(data_to_reg_b),
                .addrb_in(regbank_addr_b),
                .datab_o(data_from_regbank_path_b)
                );            
`endif

assign #50 reg_path_a = (seq_op1 == `OP1_0) ? 4'h0:
                    (seq_op1 == `OP1_9) ? 4'h9:
                    //(seq_op1 == `OP1_F) ? RF:
                    (seq_op1 == `OP1_CNT) ? dec_lit_operand:
                    (seq_op1 == `OP1_KEY) ? (seq_op1_nibble == 4'h2 ? key_keycode[7:4]:key_keycode[3:0]):
                    data_from_regbank_path_a;
                   

assign #50 reg_path_b = (seq_dst == `DST_0) ? 4'h0:
                        (seq_dst == `DST_9) ? 4'h9:
                        //(seq_dst == `OP_F) ? RF:
                        data_from_regbank_path_b;
    
/* Updates some registers that are not in the register bank register */
always @(posedge cpu_clk)
    begin
        if ((seq_reg_transfer | seq_reg_write_alu_or_lit | seq_reg_exchange) & seq_alu_wback) // any write
            begin
                case (seq_dst)
                    `DST_A:
                        case (seq_dst_nibble)
                            4'h1: RA[7:4] <= data_to_reg_b;
                            4'h2: RA[11:8] <= data_to_reg_b;
                        endcase
                    `DST_DA:
                        if (seq_dst_nibble[0])
                            DATAADDR[5:4] <= data_to_reg_b[1:0];
                        else
                            DATAADDR[3:0] <= data_to_reg_b;
                    //`OP_F: RF <= data_to_reg_b;
                endcase
            end
        if (seq_reg_exchange & seq_alu_wback)
            begin
                case (seq_op1)
                    `OP1_A:
                        case (seq_dst_nibble)
                            4'h1: RA[7:4] <= reg_path_b;
                            4'h2: RA[11:8] <= reg_path_b;
                        endcase
                    //`OP1_F: RF <= reg_path_b;
                endcase
            end
    end    

/*********************************************************************/
/*********************************************************************/
// ALU


wire [3:0] alu_left, alu_right;
// exchange if reversed sub
assign alu_left = (dec_op_alu == `ALU_SUB) ? reg_path_b:reg_path_a;
assign alu_right = (dec_op_alu == `ALU_SUB) ? reg_path_a:reg_path_b;
wire adder_op;
assign adder_op = (dec_op_alu != `ALU_ADD); // 0 ADD, 1 SUB/CMP

addsub asub(
    .a_in(alu_left),
    .b_in(alu_right),
    .c_in(alu_icarry),
    .dec_in(1'b1), // always in decimal mode
	.as_in(adder_op),
    .q_out(alu_q_add),
    .qc_out(alu_qc_add),
    .eq_out(alu_eq),
    .neq_out(alu_neq),
    .gt_out(alu_gt)
    );
                   
assign #50 alu_out   = alu_q_add;

assign #50 alu_set_carry = (dec_op_alu == `ALU_ADD)  ? alu_qc_add:
                           (dec_op_alu == `ALU_SUB)  ? alu_qc_add:
                           (dec_op_alu == `ALU_RSUB) ? alu_qc_add:
                           //(dec_op_alu == `ALU_EQ)   ? (alu_comp_res == `CMP_EQ):
                           //(dec_op_alu == `ALU_NEQ)  ? (alu_comp_res == `CMP_NEQ):
                           //(dec_op_alu == `ALU_GTEQ) ? ((alu_comp_res == `CMP_EQ) | (alu_comp_res == `CMP_GT)):1'b0;
                           (dec_op_alu == `ALU_EQ)   ? (alu_comp_res == `CMP_NEQ):
                           (dec_op_alu == `ALU_NEQ)  ? (alu_comp_res == `CMP_EQ):
                           (dec_op_alu == `ALU_GTEQ) ? (alu_comp_res == `CMP_LT) :1'b0;

always @(posedge cpu_clk)
    begin
		if (~cpu_reset_n)
            begin
				alu_comp_res <= 'h0;
				alu_icarry <= 1'b0;
			end
		else
			begin
				if (seq_alu_prep)
					begin
						alu_comp_res <= `CMP_NONE;
						alu_icarry <= dec_f_set_carry_early;//f_carry;
					 end
				if (seq_alu_read3)
					begin
						case (dec_op_alu)
							`ALU_EQ: if (alu_eq & (alu_comp_res != `CMP_NEQ))
										alu_comp_res  <= `CMP_EQ; // EQ is NOT sticky
									 else 
										alu_comp_res <= `CMP_NEQ; // NEQ is sticky
							`ALU_NEQ: 
									if (alu_neq)
										begin
											alu_comp_res  <= `CMP_NEQ; // NEQ is sticky
										end
									 else
										if (alu_comp_res != `CMP_NEQ) alu_comp_res <= `CMP_EQ;
							`ALU_GTEQ:
								begin
									if (alu_eq)
										begin
											if (alu_comp_res == `CMP_NONE) alu_comp_res  <= `CMP_EQ;
										end
									else
										if (alu_gt)
											begin
												if ((alu_comp_res == `CMP_NONE) | (alu_comp_res == `CMP_EQ)) alu_comp_res  <= `CMP_GT;
											end
										else
											if ((alu_comp_res == `CMP_NONE) | (alu_comp_res == `CMP_EQ))
												alu_comp_res <= `CMP_LT;
								end
						endcase
					end
				if (seq_alu_wback)
					begin
						alu_icarry <= alu_set_carry;
					end
			end
    end

//
// Miscellaneous registers : carry, hw status
//
//

always @(posedge cpu_clk)
    begin
        if (~cpu_reset_n)
            begin
                f_hw_status <= 12'b0;
                f_carry <= 1'b0;
            end
        else
            begin
                if (seq_fetch_op1)
                    begin
                        f_carry <= 1'b0; // cleared automatically
                        f_hw_status[0] <= key_pending;
                    end
                if (seq_exe)
                    begin
                        if (dec_f_test_set_flag)
                            f_carry <= ~f_hw_status[dec_lit_operand];
                        if (dec_f_test_clr_flag)
                            f_carry <= f_hw_status[dec_lit_operand];
                        if (dec_f_clr_status)
                            begin
                                f_hw_status <= 12'b0;
                            end
                        if (dec_lit_operand < 12)
                            begin
                                if (dec_f_clr_flag) f_hw_status[dec_lit_operand]  <= 1'b0;
                                if (dec_f_set_flag) f_hw_status[dec_lit_operand]  <= 1'b1;
                            end
                    end
                end
                if (seq_jump)
                    f_carry <= 1'b0; // do not propagate current carry
                if (seq_exe)
                    begin
                        if (reg_p_set_carry) 
                            f_carry <= 1'b1;
                    end
                if (seq_alu_wback)
                    begin
                        if (alu_set_carry & seq_wback_carry)
                            f_carry <= 1'b1;
                    end
            end


/***************************************************************************/
/***************************************************************************/
// Sequencer and HW Trace unit

always @(posedge cpu_clk or negedge cpu_reset_n)
    begin
         if (~cpu_reset_n)
            begin
                seq_state <= `ST_INIT;
                seq_opcode <= 10'h0;
                seq_opcode2 <= 10'h0;
                seq_ifaddr[11:0] <= 12'h0;
                seq_op1_nibble[3:0]  <= 4'h0;
                seq_dst_nibble[3:0]  <= 4'h0;
                seq_field_ofs <= 1'h0;
                seq_field_counter[3:0] <= 4'h0;
                bank <= 3'h0;
                seq_wback_carry <= 1'b0;
                seq_dst <= 7'h0;
                seq_op1 <= 7'h0;
                trace_tx_start <= 1'b0;
                trace_state <= 4'h0;
                trace_tx_cr <= 1'b0;
                trace_tx_space <= 1'b0;
                seq_write_path_b <= 1'b0;
                seq_write_path_a <= 1'b0;
                seq_fetch_op1_delayed <= 1'b0;
                seq_latched_carry <= 1'b0;
				SPC <= 4'h0;
            end
        else
			begin
				seq_fetch_op1_delayed <= seq_fetch_op1;
                case (seq_state)
                    `ST_INIT:
                        begin
                            seq_state <= #2 `ST_FETCH_OP0;
                            seq_wback_carry <= 1'b0; 
                            // display refresh
                            seq_op1 <= `OP1_A;
                            seq_dst <= `DST_B;
                            seq_op1_nibble <= disp_curr_nibble;
                            seq_dst_nibble <= disp_curr_nibble;
							SPC <= RPC[11:8];
                        end
                    `ST_FETCH_OP0: // fetch 1st word
                        begin
                            seq_state <= #2 `ST_FETCH_OP1; 
                            seq_fetched_addr <= { bank, RPC };
                        end
                    `ST_FETCH_OP1: // store 1st word
                        begin
                            seq_opcode <= rom_opcode;
                            seq_latched_carry <= f_carry;
                            // look for double word opcodes, second opcode is 10 bit address
                            //if (({ rom_opcode[9:5], rom_opcode[1:0] } == 7'b00000_10 ) || //if b = 0
                            //    ({ rom_opcode[9:5], rom_opcode[1:0] } == 7'b00010_10 ) || //if a >= c
                            //    ({ rom_opcode[9:5], rom_opcode[1:0] } == 7'b00011_10 ) || //if c # 0
                            //    ({ rom_opcode[9:5], rom_opcode[1:0] } == 7'b01101_10 ) || //if c = 0
                            //    ({ rom_opcode[9:5], rom_opcode[1:0] } == 7'b10000_10 ) || // if a >= b
                            //    ({                  rom_opcode[5:0] } == 6'b010100 ) ||  // if s = 0 1... .1.1..
                            //    ({                  rom_opcode[5:0] } == 6'b101100 ))     // if p # n
                            //        seq_state <= #2 `ST_FETCH_OP2;
                            //    else
                            //        begin
                                        if (HW_TRACE && trace_key_enable)
                                            seq_state <= #2 `ST_HW_TRACE_START;
                                        else
                                            seq_state <= #2 `ST_DECODE;
                            //        end
                            //$display("%1h:%03h %1h:%04o: %s %s", bank, seq_fetched_addr, bank, seq_fetched_addr, dis_label, dis_opcode);
                            //$display("%1h:%03h %1h:%04o: %s %s A:%014x B:%014x", bank, seq_fetched_addr, bank, seq_fetched_addr, dis_label, dis_opcode);
							SPC <= RPC[7:4];
                        end
                    `ST_FETCH_OP2: // store second word if first was an if
                        begin
                            if (HW_TRACE && trace_key_enable)
                                seq_state <= #2 `ST_HW_TRACE_START;
                            else
                                seq_state <= #2 `ST_DECODE;
                            //seq_fetch_op1 <= 1'b0;
                            seq_ifaddr <= { RPC[11:10], rom_opcode[9:2] };
                            seq_opcode2 <= rom_opcode;
                        end
                    `ST_HW_TRACE_START:
                        if (HW_TRACE)
                            begin
                                //seq_fetch_op1 <= 1'b0;
                                seq_op1 <= `OP1_0; //
                                trace_state <= 4'h0;
                                seq_state <= `ST_HW_TRACE_PREPARE;
                            end
                    `ST_HW_TRACE_PREPARE:
                        if (HW_TRACE)
                            begin
                                if (trace_state != 4'hD)
                                    begin
                                        if (HW_TRACE_MINI)
                                            begin
                                                if (trace_state == 4'h1)
                                                    trace_state <= 4'h8;
                                                else
                                                    trace_state <= trace_state + 4'd1;
                                            end
                                        else
                                            trace_state <= trace_state + 4'd1;
                                        seq_state <= #2 `ST_HW_TRACE_READ;
                                    end
                                else
                                    seq_state <= #2 `ST_DECODE;
                                case (trace_state)
                                    4'h0: begin seq_op1 <= `OP1_PC; seq_op1_nibble <= 4'h3; end
                                    4'h1: begin trace_tx_space <= 1'b1; seq_op1_nibble <= 4'h0; end
                                    4'h2: begin seq_op1 <= `OP1_CNT; seq_op1_nibble <= 4'h2; end
                                    4'h3: begin trace_tx_space <= 1'b1; seq_op1_nibble <= 4'h0; end
                                    4'h4: begin seq_op1 <= `OP1_0; seq_op1_nibble <= 4'h0; end
                                    4'h5: begin trace_tx_space <= 1'b1; seq_op1_nibble <= 4'h0; end
                                    //4'h6: begin seq_op1 <= `OP1_F; seq_op1_nibble <= 4'h0; end
                                    //4'h7: begin trace_tx_space <= 1'b1; seq_op1_nibble <= 4'h0; end
                                    4'h6: begin seq_op1 <= `OP1_KEY; seq_op1_nibble <= 4'h2; end
                                    4'h7: begin trace_tx_space <= 1'b1; seq_op1_nibble <= 4'h0; end
                                    4'h8: begin seq_op1 <= `OP1_A; seq_op1_nibble <= 4'hD; end
                                    4'h9: begin trace_tx_space <= 1'b1; seq_op1_nibble <= 4'h0; end
                                    4'hA: begin seq_op1 <= `OP1_B; seq_op1_nibble <= 4'hD; end
                                    4'hB: begin trace_tx_space <= 1'b1; seq_op1_nibble <= 4'h0; end
                                    4'hC: begin seq_op1 <= `OP1_C; seq_op1_nibble <= 4'hD; end
                                    4'hD: begin trace_tx_cr <= 1'b1; seq_op1_nibble <= 4'h0; end
                                endcase
								trace_delay <= 3'd7;
                            end
                    `ST_HW_TRACE_READ:
                        if (HW_TRACE)
                            begin
                                // reads argument
								trace_delay <= trace_delay - 3'd1;
								if (trace_delay == 3'd0)
									begin
										trace_tx_start <= 1'b1;
										seq_state <= `ST_HW_TRACE_OUTPUT;
									end
                            end
                    `ST_HW_TRACE_OUTPUT:
                        if (HW_TRACE)
                            begin
                                trace_tx_space <= 1'b0;
                                trace_tx_cr <= 1'b0;
                                trace_tx_start <= 1'b0;
                                if ((~trace_tx_busy) & (~trace_tx_start))
                                    if (seq_op1_nibble == 4'h0)
                                        seq_state <= `ST_HW_TRACE_PREPARE;
                                    else
                                        begin
                                            seq_op1_nibble <= seq_op1_nibble - 4'h1;
                                            seq_state <= `ST_HW_TRACE_READ;
                                        end
                            end
                    `ST_DECODE:
                        begin
                            $display("%1h:%02h %1h:%03o: %03x %s P:%x CY:%1x A:%014x B:%014x C:%014x M:%014x ST:%03x STK:%02x DA:%02x %8t", bank, seq_fetched_addr[7:0], bank, seq_fetched_addr[7:0], seq_opcode, dis_opcode,
                                     RP, seq_latched_carry, regs.A, regs.B, regs.C, regs.M, f_hw_status, STACK, DATAADDR, $time);
                            if ((dec_op_alu != `ALU_NONE) || dec_f_rol || dec_f_lsl || dec_f_lsr || dec_f_tfr ||
                                dec_f_exchange || dec_f_wr_alu || dec_f_wr_lit || dec_f_push_c ||
                                dec_f_pop_a || dec_f_clr_regs || dec_f_clr_dregs || dec_f_rot_stack)
                                seq_state <= #2 `ST_AT_PREP; // execute
                            else
                                seq_state <= #2 `ST_EXE_NORM;
							SPC <= RPC[3:0];
                        end
                    `ST_EXE_NORM: // jumps, flags, reg-p opcodes
                        begin
                            if (dec_f_jump | //dec_f_bank | 
                                // removed because ifs only set the carry
                                //((~reg_p_set_carry) & dec_f_gto_c_clr) | // actual carry is written back in this stage it cannot de checked now                    
                                ((~seq_latched_carry) & dec_f_gonc))
                                seq_state <= #2 `ST_JUMP;
                            else
                                seq_state <= #2 `ST_INIT;
                        end
                    `ST_JUMP: // reached only if jsb, ifs or goto n/c when seq_latched_carry is zero
                        begin
                            seq_state <= #2 `ST_INIT;
                        end
                    `ST_AT_PREP: // get counters up to date
                        begin
                            seq_field_counter <= dec_field_end - dec_field_start; // use whatever the decoder provides: fixed or translated
                            seq_op1 <= dec_reg_op1;
                            seq_dst <= dec_reg_dst;
                            seq_field_ofs <= 1'b0; // means +1, from left to right for add/sub and tfr/ex
                            seq_state <=`ST_AT_READ;
                            seq_dst_nibble <= dec_field_start;
                            seq_op1_nibble <= dec_field_start;
                            if ((dec_op_alu == `ALU_EQ) || (dec_op_alu == `ALU_NEQ) || (dec_op_alu == `ALU_GTEQ))
                                begin
                                    seq_dst_nibble <= dec_field_end;
                                    seq_op1_nibble <= dec_field_end;                             
                                    seq_field_ofs <= 1'h1; // decrement pointer
                                end
                            if (dec_f_rol)
                                begin 
                                    seq_dst_nibble <= 4'he; // save left most nibble in unused nibble 15th
                                    seq_op1_nibble <= dec_field_end;                              
                                    seq_field_ofs <= 1'h1; // decrement pointer
                                    seq_field_counter <= 4'he;
                                end
                            else if (dec_f_lsl)
                                begin 
                                    seq_dst_nibble <= dec_field_end;
                                    seq_op1_nibble <= dec_field_end - 4'h1;                              
                                    seq_field_ofs <= 1'h1; // decrement pointer
                                end
                            else if(dec_f_lsr)
                                begin 
                                    seq_op1_nibble <= dec_op_field_start + 4'h1;
                                end
                            else if(dec_f_clr_dregs)
                                begin
                                    seq_dst_nibble <= 4'h0;
                                    seq_op1_nibble <= 4'h0;
                                    seq_field_counter <= 4'hd;
                                    seq_op1 <= `OP1_0;
                                    //if (HP67)
                                    //    begin
                                            seq_dst <= { 1'b0, DATAADDR }; // access data registers through DA pointer
                                    //    end
                                    //else
                                        seq_dst <= `DST_R0;
                                end
                            else if(dec_f_clr_regs)
                                begin
                                    seq_dst_nibble <= 4'h0;
                                    seq_op1_nibble <= 4'h0;
                                    seq_field_counter <= 4'hd;
                                    seq_op1 <= `OP1_0;
                                    seq_dst <= `DST_A;
                                end
                            else if(dec_f_push_c) // c->y->z->t
                                begin
                                    seq_dst_nibble <= 4'h0;
                                    seq_op1_nibble <= 4'h0;
                                    seq_field_counter <= 4'hd;
                                    seq_op1 <= `OP1_Z;
                                    seq_dst <= `DST_T;
                                end
                            else if(dec_f_pop_a) // t->z->y->a
                                begin
                                    seq_dst_nibble <= 4'h0;
                                    seq_op1_nibble <= 4'h0;
                                    seq_field_counter <= 4'hd;
                                    seq_op1 <= `OP1_Y;
                                    seq_dst <= `DST_A;
                                end
                            else if(dec_f_rot_stack) // 
                                begin
                                    seq_dst_nibble <= 4'h0;
                                    seq_op1_nibble <= 4'h0;
                                    seq_field_counter <= 4'hd;
                                    seq_op1 <= `OP1_C;
                                    seq_dst <= `DST_T;
                                end
                        end
                    `ST_AT_READ:
                        begin
                            seq_state <= `ST_AT_READ3;
                        end
                    `ST_AT_READ3:
                        begin
                            seq_state <= `ST_AT_WBACK;
                            if (seq_field_counter == 4'h0)
                               seq_wback_carry <= dec_f_set_carry;
                               
                            seq_write_path_b <= seq_reg_transfer | seq_reg_write_alu_or_lit | seq_reg_exchange;
                            seq_write_path_a <= seq_reg_exchange;
                        end
                    `ST_AT_WBACK:
                        begin
                            seq_state <= `ST_AT_READ2;
                            seq_write_path_b <= 1'b0;
                            seq_write_path_a <= 1'b0;
                        end
                    `ST_AT_READ2:
                        begin
                            seq_state <= `ST_AT_READ;
                            if (seq_field_counter != 4'h0)
                                begin
                                    seq_dst_nibble <= seq_dst_nibble + (seq_field_ofs ? 4'hf:4'h1);
                                    seq_op1_nibble <= seq_op1_nibble + (seq_field_ofs ? 4'hf:4'h1);
                                end
                            case (dec_op_alu)
                                `ALU_EQ, `ALU_NEQ, `ALU_GTEQ:
                                    if (seq_field_counter == 4'h0) seq_state <= `ST_JUMP; // jump if carry
                            endcase
                            if (dec_f_lsl | dec_f_lsr) // don't merge with next case
                                begin
                                    if (seq_field_counter == 4'h1)
                                        seq_op1 <= `OP1_0; // shift a zero from the left or right 
                                end
                            if (dec_f_rol) // don't merge with next case
                                begin
                                    if (seq_field_counter == 4'h1)
                                        seq_op1_nibble <= 4'he; // shift nibble D, saved in nibble E, to niblle 0
                                end
                            if (dec_f_clr_dregs) // cycle through all data registers (R0..R15)
                                begin
                                    if (seq_field_counter != 4'h0)
                                        seq_field_counter <= seq_field_counter - 4'h1;
                                    else
                                        begin
                                            seq_dst_nibble <= 4'h0;
                                            seq_op1_nibble <= 4'h0;
                                            seq_field_counter <= 4'hd;
                                            
                                            if (seq_dst[3:0] == 4'hf)
                                                seq_state <= `ST_INIT;
                                            else
                                                seq_dst[3:0] <= seq_dst[3:0] + 4'h1;
                                        end
                                end
                            else if (dec_f_clr_regs) // cycle through all registers(A, B, C, Mx, Y, Z, T)
                                begin
                                    if (seq_field_counter != 4'h0)
                                        seq_field_counter <= seq_field_counter - 4'h1;
                                    else
                                        begin
                                            seq_dst_nibble <= 4'h0;
                                            seq_op1_nibble <= 4'h0;
                                            seq_field_counter <= 4'hd;
                                            if (seq_dst == `DST_T)
                                                seq_state <= `ST_INIT;
                                            else
                                                seq_dst[3:0] <= seq_dst[3:0] + 4'd1;
                                        end
                                end
                            else if (dec_f_push_c) // c->y->z->t
                                begin
                                    if (seq_field_counter != 4'h0)
                                        seq_field_counter <= seq_field_counter - 4'h1;
                                    else
                                        begin
                                            seq_dst_nibble <= 4'h0;
                                            seq_op1_nibble <= 4'h0;
                                            seq_field_counter <= 4'hd;
                                            case (seq_op1)
                                                `OP1_Z: begin seq_op1 <= `OP1_Y; seq_dst <= `DST_Z; end
                                                `OP1_Y: begin seq_op1 <= `OP1_C; seq_dst <= `DST_Y; end
                                                `OP1_C: begin seq_state <= `ST_INIT; end
                                            endcase
                                        end
                                end
                            else if (dec_f_pop_a) // t->z->y->a
                                begin
                                    if (seq_field_counter != 4'h0)
                                        seq_field_counter <= seq_field_counter - 4'h1;
                                    else
                                        begin
                                            seq_dst_nibble <= 4'h0;
                                            seq_op1_nibble <= 4'h0;
                                            seq_field_counter <= 4'hd;
                                            case (seq_op1)
                                                `OP1_Y: begin seq_op1 <= `OP1_Z; seq_dst <= `DST_Y; end
                                                `OP1_Z: begin seq_op1 <= `OP1_T; seq_dst <= `DST_Z; end
                                                `OP1_T: begin seq_state <= `ST_INIT; end
                                            endcase
                                        end
                                end
                            else if (dec_f_rot_stack) // uses 3 exchanges
                                begin
                                    if (seq_field_counter != 4'h0)
                                        seq_field_counter <= seq_field_counter - 4'h1;
                                    else
                                        begin
                                            seq_dst_nibble <= 4'h0;
                                            seq_op1_nibble <= 4'h0;
                                            seq_field_counter <= 4'hd;
                                            case (seq_op1)
                                                `OP1_C: begin seq_op1 <= `OP1_Y; seq_dst <= `DST_C; end
                                                `OP1_Y: begin seq_op1 <= `OP1_Z; seq_dst <= `DST_Y; end
                                                `OP1_Z: begin seq_state <= `ST_INIT; end
                                            endcase
                                        end
                                end//
                            else
                                begin
                                    if (seq_field_counter != 4'h0)
                                        seq_field_counter <= seq_field_counter - 4'h1;
                                    else
                                        begin
                                            // removed because ifs only set the carry
                                            //if (dec_f_gto_c_clr | dec_f_gto_c_set)
                                            //    seq_state <= #2 `ST_JUMP;
                                            //else
                                                seq_state <= `ST_INIT;
                                        end
                                end
                        end
                    default:
                        seq_state <= `ST_INIT;
                endcase
            end
    end
    
endmodule


module nclassic_field_decoder(
    input wire [2:0] field_in, // 3 left most bits
    input wire [3:0] p_in, // register P
    output reg [3:0] start_o, 
    output reg [3:0] end_o
    );

always @(field_in, p_in)
    case(field_in)
        3'h0: begin start_o = p_in; end_o = p_in; end // Pointer field
        3'h1: begin start_o = 4'h3; end_o = 4'hc; end // M
        3'h2: begin start_o = 4'h0; end_o = 4'h2; end // X
        3'h3: begin start_o = 4'h0; end_o = 4'hd; end // W
        3'h4: begin start_o = 4'h0; end_o = p_in; end // WP
        3'h5: begin start_o = 4'h3; end_o = 4'hd; end // MS
        3'h6: begin start_o = 4'h2; end_o = 4'h2; end // XS
        3'h7: begin start_o = 4'hd; end_o = 4'hd; end // S        
    endcase

endmodule

module dp_reg_bank(
    input wire          clk_in,
    input wire          seq_decode_in,
    
    input wire          wea_in,
    input wire [3:0]    dataa_in,
    input wire [10:0]   addra_in,
    output wire [3:0]    dataa_o,
    
    input wire          web_in,
    input wire [3:0]    datab_in,
    input wire [10:0]   addrb_in,
    output wire [3:0]    datab_o
    );
    
reg [3:0] regs[2047:0] /* synthesis syn_ramstyle="no_rw_check" */;

wire [55:0] A, B, C, M, M2;
reg [10:0] raddra_in, raddrb_in;
assign A = {                                                             regs[ 80 * 16 + 0 * 16 + 13], regs[ 80 * 16 + 0 * 16 + 12], 
             regs[ 80 * 16 + 0 * 16 + 11], regs[ 80 * 16 + 0 * 16 + 10], regs[ 80 * 16 + 0 * 16 +  9], regs[ 80 * 16 + 0 * 16 +  8], 
             regs[ 80 * 16 + 0 * 16 +  7], regs[ 80 * 16 + 0 * 16 +  6], regs[ 80 * 16 + 0 * 16 +  5], regs[ 80 * 16 + 0 * 16 +  4], 
             regs[ 80 * 16 + 0 * 16 +  3], regs[ 80 * 16 + 0 * 16 +  2], regs[ 80 * 16 + 0 * 16 +  1], regs[ 80 * 16 + 0 * 16 +  0] };
assign B = {                                                             regs[ 80 * 16 + 1 * 16 + 13], regs[ 80 * 16 + 1 * 16 + 12], 
             regs[ 80 * 16 + 1 * 16 + 11], regs[ 80 * 16 + 1 * 16 + 10], regs[ 80 * 16 + 1 * 16 +  9], regs[ 80 * 16 + 1 * 16 +  8], 
             regs[ 80 * 16 + 1 * 16 +  7], regs[ 80 * 16 + 1 * 16 +  6], regs[ 80 * 16 + 1 * 16 +  5], regs[ 80 * 16 + 1 * 16 +  4], 
             regs[ 80 * 16 + 1 * 16 +  3], regs[ 80 * 16 + 1 * 16 +  2], regs[ 80 * 16 + 1 * 16 +  1], regs[ 80 * 16 + 1 * 16 +  0] };
assign C = {                                                             regs[ 80 * 16 + 2 * 16 + 13], regs[ 80 * 16 + 2 * 16 + 12], 
             regs[ 80 * 16 + 2 * 16 + 11], regs[ 80 * 16 + 2 * 16 + 10], regs[ 80 * 16 + 2 * 16 +  9], regs[ 80 * 16 + 2 * 16 +  8], 
             regs[ 80 * 16 + 2 * 16 +  7], regs[ 80 * 16 + 2 * 16 +  6], regs[ 80 * 16 + 2 * 16 +  5], regs[ 80 * 16 + 2 * 16 +  4], 
             regs[ 80 * 16 + 2 * 16 +  3], regs[ 80 * 16 + 2 * 16 +  2], regs[ 80 * 16 + 2 * 16 +  1], regs[ 80 * 16 + 2 * 16 +  0] };
assign M = {                                                             regs[ 80 * 16 + 3 * 16 + 13], regs[ 80 * 16 + 3 * 16 + 12], 
             regs[ 80 * 16 + 3 * 16 + 11], regs[ 80 * 16 + 3 * 16 + 10], regs[ 80 * 16 + 3 * 16 +  9], regs[ 80 * 16 + 3 * 16 +  8], 
             regs[ 80 * 16 + 3 * 16 +  7], regs[ 80 * 16 + 3 * 16 +  6], regs[ 80 * 16 + 3 * 16 +  5], regs[ 80 * 16 + 3 * 16 +  4], 
             regs[ 80 * 16 + 3 * 16 +  3], regs[ 80 * 16 + 3 * 16 +  2], regs[ 80 * 16 + 3 * 16 +  1], regs[ 80 * 16 + 3 * 16 +  0] };

assign dataa_o = regs[raddra_in];
assign datab_o = regs[raddrb_in];
             
always @(posedge clk_in)
    begin
        raddra_in <= addra_in;
        raddrb_in <= addrb_in;
        if (wea_in)
            regs[addra_in] <= dataa_in;
               
        if (web_in)
            regs[addrb_in] <= datab_in;
    end

integer i;
initial
    begin
        $display("Using simulated dp-ram");
`ifdef SIMULATOR
        for (i = 32'd0; i <= 32'd2047; i = i + 32'd1)
            begin
                regs[i[11:0]] = 4'd0;
            end
`endif
    end

endmodule

   

module nclassic_keys_portrait(
    input wire          clk_in,             // processor clock
    input wire          reset_in,
    input wire [7:0]    keys_rows_in,
    input wire          key_read_ack_in,    // asserted when the last key was read
    input wire          do_scan_in,         // start new scan
    input wire          clear_pending_in,
    output wire [4:0]   key_cols_o,
    output wire [7:0]   keycode_o,
    output wire         key_pending_o
`ifdef SIMULATOR
    ,
    input wire          simkey_activate_key_pending_in,
    input wire [7:0]    simkey_keycode_in
`endif
    );

reg [2:0] scan_tick;
reg key_pending;
reg [7:0] latched_curr_key = 7'h0;

assign keycode_o = latched_curr_key;
assign key_pending_o = key_pending;

assign key_cols_o[0] = scan_tick[2:0] == 3'd4;
assign key_cols_o[1] = scan_tick[2:0] == 3'd3;
assign key_cols_o[2] = scan_tick[2:0] == 3'd2;
assign key_cols_o[3] = scan_tick[2:0] == 3'd1;
assign key_cols_o[4] = scan_tick[2:0] == 3'd0;

/*
 *  col1 col2 col3 col4 col5
 *
 * 1/x  ln   e^x  FIX   f     R7
 * 06   04   03   02   00
 *
 * x^2  ->P  SIN  COS  TAN    R6
 * 56   54   53   52   50
 *
 * x<>y RDN  STO  RCL   %     R5
 * 16   14   13   12   10
 *
 * Enter     CHS  EEX  CLx    R4
 * 74        73   72   70         
 *
 *  -    7    8    9          R3
 *  66   64   63   62
 *
 *  +    4    5    6          R2
 *  26   24   23   22   
 *
 *  x    1    2    3          R1
 *  36   34   33   32
 *
 *  /    0    .    E+         R0        
 *  46   44   43   42
 *
 */ 

always @(posedge clk_in)
    begin
        if (~reset_in)
            begin
                key_pending <= 1'b0;
                scan_tick <= 3'd5;
                latched_curr_key <= 7'h0;
            end
        else
            begin
                if ((clear_pending_in == 1'b1) || (key_read_ack_in == 1'b1))
                    key_pending <= 1'b0;
                if (scan_tick != 3'd5)
                    scan_tick <= scan_tick + 3'h1;
				if (do_scan_in == 1'b1)
					scan_tick <= 3'd0;
                if ((key_pending != 1'b1) && (scan_tick != 3'd5))
                    begin
                        if (|keys_rows_in)
                            begin
                                case (scan_tick)
                                    3'b000:  latched_curr_key[2:0] <= 4'd6;
                                    3'b001:  latched_curr_key[2:0] <= 4'd4;
                                    3'b010:  latched_curr_key[2:0] <= 4'd2;
                                    3'b011:  latched_curr_key[2:0] <= 4'd2;
                                    3'b100:  latched_curr_key[2:0] <= 4'd0;
                                    default: latched_curr_key[2:0] <= 4'd0;
                                endcase
                                
                                latched_curr_key[7:3] <= { 2'b0 , // bit 4, 3
                                                           keys_rows_in[0] | keys_rows_in[3] | keys_rows_in[4] | keys_rows_in[6], // bit 2
                                                           keys_rows_in[1] | keys_rows_in[2] | keys_rows_in[3] | keys_rows_in[4] | keys_rows_in[6], // bit 1
                                                           keys_rows_in[1] | keys_rows_in[4] | keys_rows_in[5] | keys_rows_in[6] }; // bit 0
                                key_pending <= 1'b1;
                            end
                        scan_tick <= scan_tick + 3'd1;
                    end
`ifdef SIMULATOR
                if (simkey_activate_key_pending_in == 1'b1)
                    begin
                        key_pending <= 1'b1;
                        latched_curr_key <= simkey_keycode_in;
                    end
`endif                
            end
    end
endmodule
/**
 * 4 bits binary or decimal adder subtracter
 *
 */
module addsub(
    input wire [3:0]    a_in,
    input wire [3:0]    b_in,
    input wire          c_in,
    input wire          as_in, // 0 : Add, 1: Sub
    input wire          dec_in,
    output wire [3:0]   q_out,
    output wire         qc_out,
    output wire         eq_out,
    output wire         neq_out,
    output wire         gt_out
);
wire [3:0] part_q;  // first partial result 
wire [3:0] part_qc; // first partial carry
wire [3:0] da_q;     // decimal adjust result 
wire [3:0] da_qc;    // decimal adjust carry

// A+B
saturn_full_adder_subtracter as0( a_in[0], b_in[0],       c_in, as_in, part_q[0], part_qc[0]);
saturn_full_adder_subtracter as1( a_in[1], b_in[1], part_qc[0], as_in, part_q[1], part_qc[1]);
saturn_full_adder_subtracter as2( a_in[2], b_in[2], part_qc[1], as_in, part_q[2], part_qc[2]);
saturn_full_adder_subtracter as3( a_in[3], b_in[3], part_qc[2], as_in, part_q[3], part_qc[3]);
// Decimal adjust
//saturn_full_adder_subtracter das0( part_q[0], 1'b0,     1'b0, as_in, da_q[0], da_qc[0]);
assign da_q[0] = part_q[0];
assign da_qc[0] = 1'b0;
saturn_full_adder_subtracter das1( part_q[1], 1'b1, da_qc[0], as_in, da_q[1], da_qc[1]);
saturn_full_adder_subtracter das2( part_q[2], 1'b1, da_qc[1], as_in, da_q[2], da_qc[2]);
saturn_full_adder_subtracter das3( part_q[3], 1'b0, da_qc[2], as_in, da_q[3], da_qc[3]);
// Final mux
//assign q_out = (dec_in & part_qc[3]) ? da_q:part_q;

assign qc_out = (dec_in & (~as_in) & part_q[3] & (part_q[1] | part_q[2])) | part_qc[3];
//assign qc_out = ((~as_in) & part_q[3] & (part_q[1] | part_q[2])) | part_qc[3];
assign q_out = (qc_out & dec_in) ? da_q:part_q;
assign eq_out = ~(|(a_in ^ b_in));
assign neq_out = ~eq_out;
assign gt_out = ~qc_out; // carry set means less than a < b

endmodule

/**
 * 1 bit adder/subtracter
 *
 */
module saturn_full_adder_subtracter(
    input wire a,
    input wire b,
    input wire c,
    
    input wire as,
    
    output wire q,
    output wire qc
);
wire pq;
assign pq = a ^ b;
assign q = pq ^ c;

assign qc = (as == 1'b1) ? (( (~a) & b ) | ( (~pq) & c)): // sub
                           (( a & b ) | (pq & c)); // add

endmodule
    
/**
 * Asynchronous transmitter
 *
 */
module async_transmitter(
    input wire clk,
    input wire TxD_start,
    input wire [7:0] TxD_data,
    output wire TxD,
    output wire TxD_busy
);

////////////////////////////////

wire BitTick = 1'b1;  // output one bit per clock cycle

reg [3:0] TxD_state = 0;
wire TxD_ready = (TxD_state==0);
assign TxD_busy = ~TxD_ready;

reg [7:0] TxD_shift = 0;
always @(posedge clk)
begin
    if(TxD_ready & TxD_start)
        TxD_shift <= TxD_data;
    else
    if(TxD_state[3] & BitTick)
        TxD_shift <= (TxD_shift >> 1);

    case(TxD_state)
        4'b0000: if(TxD_start) TxD_state <= 4'b0100;
        4'b0100: if(BitTick) TxD_state <= 4'b1000;  // start bit
        4'b1000: if(BitTick) TxD_state <= 4'b1001;  // bit 0
        4'b1001: if(BitTick) TxD_state <= 4'b1010;  // bit 1
        4'b1010: if(BitTick) TxD_state <= 4'b1011;  // bit 2
        4'b1011: if(BitTick) TxD_state <= 4'b1100;  // bit 3
        4'b1100: if(BitTick) TxD_state <= 4'b1101;  // bit 4
        4'b1101: if(BitTick) TxD_state <= 4'b1110;  // bit 5
        4'b1110: if(BitTick) TxD_state <= 4'b1111;  // bit 6
        4'b1111: if(BitTick) TxD_state <= 4'b0010;  // bit 7
        4'b0010: if(BitTick) TxD_state <= 4'b0011;  // stop1
        4'b0011: if(BitTick) TxD_state <= 4'b0000;  // stop2
        default: if(BitTick) TxD_state <= 4'b0000;
    endcase
end

assign TxD = (TxD_state<4) | (TxD_state[3] & TxD_shift[0]);  // put together the start, data and stop bits
endmodule
