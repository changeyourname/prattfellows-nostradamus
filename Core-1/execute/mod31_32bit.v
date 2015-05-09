

// Module to compute 'data mod 31'
// If data is negative set sign and pad to 1'b1
// If data is positive set sign and pad to 1'b0
// Pad and sign only differ if module is used to build wider modulo unit 
module mod31_32bit( data, pad, sign, mod31 );
input  [31:0] data;
input  [2:0]  pad;
input  sign;
output [4:0] mod31;
wire [4:0] S0_0;
wire [4:0] S0_1;
wire [4:0] S0_2;
wire [4:0] S0_3;
wire [4:0] S0_4;
wire [4:0] S0_5;
wire [4:0] S0_6;
wire [4:0] sign_adjust;
wire [4:0] S1_0;
wire [4:0] S1_1;
wire [4:0] S1_2;
wire [4:0] S1_3;
wire [4:0] S1_4;
wire [4:0] S1_5;
wire [4:0] S2_0;
wire [4:0] S2_1;
wire [4:0] S2_2;
wire [4:0] S2_3;
wire [4:0] S3_0;
wire [4:0] S3_1;
wire [4:0] S3_2;
wire [4:0] S4_0;
wire [4:0] S4_1;
wire C5_0;
wire [4:0] S5_0;
assign S0_0 = data[4:0];
assign S0_1 = data[9:5];
assign S0_2 = data[14:10];
assign S0_3 = data[19:15];
assign S0_4 = data[24:20];
assign S0_5 = data[29:25];
assign S0_6 = { pad, data[31:30] };
assign sign_adjust = { {4{sign}}, 1'b0 };
// LAYER 1
MOD_ADD3 ADD3_1_0( .in0(S0_0), .in1(S0_1), .in2(S0_2), .out0(S1_0), .out1(S1_1) );
MOD_ADD3 ADD3_1_2( .in0(S0_3), .in1(S0_4), .in2(S0_5), .out0(S1_2), .out1(S1_3) );
assign S1_4 = S0_6;
assign S1_5 = sign_adjust;
// LAYER 2
MOD_ADD3 ADD3_2_0( .in0(S1_0), .in1(S1_1), .in2(S1_2), .out0(S2_0), .out1(S2_1) );
MOD_ADD3 ADD3_2_2( .in0(S1_3), .in1(S1_4), .in2(S1_5), .out0(S2_2), .out1(S2_3) );
// LAYER 3
MOD_ADD3 ADD3_3_0( .in0(S2_0), .in1(S2_1), .in2(S2_2), .out0(S3_0), .out1(S3_1) );
assign S3_2 = S2_3;
// LAYER 4
MOD_ADD3 ADD3_4_0( .in0(S3_0), .in1(S3_1), .in2(S3_2), .out0(S4_0), .out1(S4_1) );
// LAYER 5
MOD_ADD2 ADD2_5_0( .cin(1'b0), .in0(S4_0), .in1(S4_1), .sum(S5_0), .cout(C5_0) );
assign mod31 = ((S5_0 + C5_0) == 5'b11111) ? 5'b00000 : (S5_0 + C5_0);
	
endmodule

/*module MERSENNE_MOD_MULT5( in0, in1, product );
input  [4:0] in0, in1;
output [4:0] product;
wire   [9:0] p;
assign p = in0 * in1;
MERSENNE_MOD_ADD5 mod_add( .in0(p[9:5]), .in1(p[4:0]), .cin(1'b0), .sum(product));
endmodule*/

