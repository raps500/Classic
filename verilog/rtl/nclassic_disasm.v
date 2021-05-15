module NClassic_disasm(
    input wire [10:0]   addr_in,
    input wire [9:0]    opcode_in,
    input wire [9:0]    op2_in,
    
    output wire [199:0] o_o
    
);

reg [199:0] o;
wire [1:0] op_type;
wire [2:0] op_size;

wire [3:0] op_literal;
wire [3:0] op_lit_cmp_p = op_literal;
wire [3:0] op_lit_let_p = op_literal;

assign op_literal = opcode_in[9:6];
assign op_type = opcode_in[1:0];
assign op_size = opcode_in[4:2];
assign op_lit_cmp_p = op_literal;
assign op_lit_let_p = op_literal;
/*
always @(op_literal)
    case (op_literal)
        4'b0000: op_lit_let_p = 4'he; 
        4'b0001: op_lit_let_p = 4'h4;
        4'b0010: op_lit_let_p = 4'h7;
        4'b0011: op_lit_let_p = 4'h8;
        4'b0100: op_lit_let_p = 4'hb;
        4'b0101: op_lit_let_p = 4'h2;
        4'b0110: op_lit_let_p = 4'ha;
        4'b0111: op_lit_let_p = 4'hc;
        4'b1000: op_lit_let_p = 4'h1;
        4'b1001: op_lit_let_p = 4'h3;
        4'b1010: op_lit_let_p = 4'hd;
        4'b1011: op_lit_let_p = 4'h6;
        4'b1100: op_lit_let_p = 4'h0;
        4'b1101: op_lit_let_p = 4'h9;
        4'b1110: op_lit_let_p = 4'h5;
        4'b1111: op_lit_let_p = 4'he; 
    endcase

always @(op_literal)
    case (op_literal) // Scrambled to real P. Not all values are used
        4'b0000: op_lit_cmp_p = 4'h4; 
        4'b0001: op_lit_cmp_p = 4'h8;
        4'b0010: op_lit_cmp_p = 4'hc;
        4'b0011: op_lit_cmp_p = 4'h2;
        4'b0100: op_lit_cmp_p = 4'h9;
        4'b0101: op_lit_cmp_p = 4'h1;
        4'b0110: op_lit_cmp_p = 4'h6;
        4'b0111: op_lit_cmp_p = 4'h3;
        4'b1000: op_lit_cmp_p = 4'h1;
        4'b1001: op_lit_cmp_p = 4'hd;
        4'b1010: op_lit_cmp_p = 4'h5;
        4'b1011: op_lit_cmp_p = 4'h0;
        4'b1100: op_lit_cmp_p = 4'hb;
        4'b1101: op_lit_cmp_p = 4'ha;
        4'b1110: op_lit_cmp_p = 4'h7;
        4'b1111: op_lit_cmp_p = 4'h4; 
        default: op_lit_cmp_p = 4'h4; 
    endcase
*/
wire [7:0] hh8, hl8, hh10, hl10, hll10, hletp, hcmpp;
wire [23:0] naddr;
wire [31:0] faddr;
    
assign hh8 = (opcode_in[9:6] > 4'h9) ? (8'd55 + opcode_in[9:6]):(8'd48 + opcode_in[9:6]);
assign hl8 = (opcode_in[5:2] > 4'h9) ? (8'd55 + opcode_in[5:2]):(8'd48 + opcode_in[5:2]);

assign hh10 = opcode_in[9:8] + 8'd48;
assign hl10 = (opcode_in[7:4] > 4'h9) ? (8'd55 + opcode_in[7:4]):(8'd48 + opcode_in[7:4]);
assign hll10 = (opcode_in[3:0] > 4'h9) ? (8'd55 + opcode_in[3:0]):(8'd48 + opcode_in[3:0]);

assign hletp = (op_lit_let_p > 4'h9) ? (8'd55 + op_lit_let_p):(8'd48 + op_lit_let_p);
assign hcmpp = (op_lit_cmp_p > 4'h9) ? (8'd55 + op_lit_cmp_p):(8'd48 + op_lit_cmp_p);

assign naddr = { "$", hh8, hl8 };

assign faddr = { "$", hh10, hl10, hll10 };

reg [31:0] ssize;

assign o_o = o;

always @(op_size)
    case(op_size)
        3'h0: ssize = "[p]";
        3'h1: ssize = "[m]";
        3'h2: ssize = "[x]";
        3'h3: ssize = "[w]";
        3'h4: ssize = "[wp]";
        3'h5: ssize = "[ms]";
        3'h6: ssize = "[xs]";
        3'h7: ssize = "[s]";
    endcase
    
always @(*)
    begin
        case (op_type)
            2'b00:
                case (opcode_in[9:2])
                    8'b0000_0000: o = "nop";
                    
                    8'b0000_0001, 8'b0001_0001, 8'b0010_0001, 8'b0011_0001,
                    8'b0100_0001, 8'b0101_0001, 8'b0110_0001, 8'b0111_0001,
                    8'b1000_0001, 8'b1001_0001, 8'b1010_0001, 8'b1011_0001,
                    8'b1100_0001, 8'b1101_0001, 8'b1110_0001, 8'b1111_0001: o = { "1 -> s ", hh8 };

                    // Load Constant to P, carry cleared from reg_p module
                    8'b0000_0011, 8'b0001_0011, 8'b0010_0011, 8'b0011_0011,
                    8'b0100_0011, 8'b0101_0011, 8'b0110_0011, 8'b0111_0011,
                    8'b1000_0011, 8'b1001_0011, 8'b1010_0011, 8'b1011_0011,
                    8'b1100_0011, 8'b1101_0011, 8'b1110_0011, 8'b1111_0011: o = { hletp, " -> p" };

                    8'b0000_0100: o = "select rom 0";
                    8'b0010_0100: o = "select rom 1";
                    8'b0011_0100: o = "keys -> rom";
                    8'b0100_0100: o = "select rom 2";
                    8'b0110_0100: o = "select rom 3";
                    8'b1000_0100: o = "select rom 4";
                    8'b1010_0100: o = "select rom 5";
                    8'b1100_0100: o = "select rom 6";
                    8'b1110_0100: o = "select rom 7";
                                        
                    8'b0000_0101, 8'b0001_0101, 8'b0010_0101, 8'b0011_0101,
                    8'b0100_0101, 8'b0101_0101, 8'b0110_0101, 8'b0111_0101,
                    8'b1000_0101, 8'b1001_0101, 8'b1010_0101, 8'b1011_0101,
                    8'b1100_0101, 8'b1101_0101, 8'b1110_0101, 8'b1111_0101: o = { "if s = 0 ", hh8 };                    

                    8'b0000_0110, 8'b0001_0110, 8'b0010_0110, 8'b0011_0110,
                    8'b0100_0110, 8'b0101_0110, 8'b0110_0110, 8'b0111_0110,
                    8'b1000_0110, 8'b1001_0110, 8'b1010_0110, 8'b1011_0110,
                    8'b1100_0110, 8'b1101_0110, 8'b1110_0110, 8'b1111_0110: o = { "load constant ", hh8 };
                    
                    8'b0000_0111: o = "p - 1 -> p"; 

                    8'b0000_1001, 8'b0001_1001, 8'b0010_1001, 8'b0011_1001,
                    8'b0100_1001, 8'b0101_1001, 8'b0110_1001, 8'b0111_1001,
                    8'b1000_1001, 8'b1001_1001, 8'b1010_1001, 8'b1011_1001,
                    8'b1100_1001, 8'b1101_1001, 8'b1110_1001, 8'b1111_1001: o = { "0 -> s ", hh8 };
                    
                    8'b0000_1010: o = "disp toggle";
                    8'b0010_1010: o = "c ex m";
                    8'b0100_1010: o = "push c";
                    8'b0110_1010: o = "pop a";
                    8'b1000_1010: o = "disp off";
                    8'b1010_1010: o = "m -> c";
                    8'b1100_1010: o = "rot stack";
                    8'b1110_1010: o = "clear regs";

                    8'b0000_1011, 8'b0001_1011, 8'b0010_1011, 8'b0011_1011,
                    8'b0100_1011, 8'b0101_1011, 8'b0110_1011, 8'b0111_1011,
                    8'b1000_1011, 8'b1001_1011, 8'b1010_1011, 8'b1011_1011,
                    8'b1100_1011, 8'b1101_1011, 8'b1110_1011,
                    8'b1111_1011: o = { "if p # ",  hcmpp };
                    
                    8'b0000_1101: o = "clr status";
                    
                    8'b0000_1100: o = "return";
                    8'b1011_1100: o = "c -> data";
                    8'b1001_1100: o = "c -> data addr";
                    8'b1011_1110: o = "data -> c";

                    8'b0000_1111: o = "p + 1 -> p";          
                    default: 
                        begin
                            o ="unkn opcode";
                        end
                endcase
            2'b01: o = { "jsb   ", naddr };
            2'b10:
                case (opcode_in[9:5])
                    5'b00000: begin o = { "if 0 = b", ssize }; end
                    5'b00001: begin o = { "0 -> b", ssize }; end
                    5'b00010: begin o = { "if a >= c", ssize }; end
                    5'b00011: begin o = { "if 0 # c", ssize }; end
                    5'b00100: begin o = { "b -> c", ssize }; end
                    5'b00101: begin o = { "0 - c -> c", ssize }; end
                    5'b00110: begin o = { "0 -> c", ssize }; end
                    5'b00111: begin o = { "0 - c - 1 -> c", ssize }; end
                    5'b01000: begin o = { "shift left a", ssize }; end
                    5'b01001: begin o = { "a -> b", ssize }; end
                    5'b01010: begin o = { "a - c -> c", ssize }; end
                    5'b01011: begin o = { "c - 1 -> c", ssize }; end
                    5'b01100: begin o = { "c -> a", ssize }; end
                    5'b01101: begin o = { "if 0 = c", ssize }; end
                    5'b01110: begin o = { "a + c -> c", ssize }; end
                    5'b01111: begin o = { "c + 1 -> c", ssize }; end
                    5'b10000: begin o = { "if a >= b", ssize }; end
                    5'b10001: begin o = { "b ex c", ssize }; end
                    5'b10010: begin o = { "shift right c", ssize }; end
                    5'b10011: begin o = { "if 0 # a", ssize }; end
                    5'b10100: begin o = { "shift right b", ssize }; end
                    5'b10101: begin o = { "c + c -> c", ssize }; end
                    5'b10110: begin o = { "shift right a", ssize }; end
                    5'b10111: begin o = { "0 -> a", ssize }; end
                    5'b11000: begin o = { "a - b -> a", ssize }; end
                    5'b11001: begin o = { "a ex b", ssize }; end
                    5'b11010: begin o = { "a - c -> a", ssize }; end
                    5'b11011: begin o = { "a - 1 -> a", ssize }; end
                    5'b11100: begin o = { "a + b -> a", ssize }; end
                    5'b11101: begin o = { "a ex c", ssize }; end
                    5'b11110: begin o = { "a + c -> a", ssize }; end
                    5'b11111: begin o = { "a + 1 -> a", ssize }; end                    
                endcase
            2'b11: o = { "go nc ", naddr }; 
        endcase
    end
    
endmodule
