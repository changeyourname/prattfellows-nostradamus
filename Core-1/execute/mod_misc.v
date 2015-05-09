
module MOD_FA( cin, in0, in1, sum, cout );
input cin, in0, in1;
output sum, cout;
wire [1:0] s;
assign s = in0 + in1 + cin;
assign cout = s[1];
assign sum = s[0];
endmodule

// base 1 addition, such that: out0+out1 <= in0+in1+in2
module MOD_ADD3( in0, in1, in2, out0, out1 );
input  [4:0] in0, in1, in2;
output [4:0] out0, out1;
MOD_FA FA0( .cin(in2[0]), .in0(in0[0]), .in1(in1[0]), .sum(out0[0]), .cout(out1[1]) );
MOD_FA FA1( .cin(in2[1]), .in0(in0[1]), .in1(in1[1]), .sum(out0[1]), .cout(out1[2]) );
MOD_FA FA2( .cin(in2[2]), .in0(in0[2]), .in1(in1[2]), .sum(out0[2]), .cout(out1[3]) );
MOD_FA FA3( .cin(in2[3]), .in0(in0[3]), .in1(in1[3]), .sum(out0[3]), .cout(out1[4]) );
MOD_FA FA4( .cin(in2[4]), .in0(in0[4]), .in1(in1[4]), .sum(out0[4]), .cout(out1[0]) );
endmodule

module MOD_ADD2( cin, in0, in1, sum, cout );
input  cin;
input  [4:0] in0, in1;
output [4:0] sum;
output cout;
wire [5:0] s;
assign s = in0 + in1 + cin;
assign cout = s[5];
assign sum = s[4:0];
endmodule

module mod5_mul( in0, in1, product );
input  [4:0] in0, in1;
output [4:0] product;
mod31_32bit tree( .data( { 7'b0,  
                              {in0[0:0], in0[4:1]} & {5{in1[4]}},
                              {in0[1:0], in0[4:2]} & {5{in1[3]}},
                              {in0[2:0], in0[4:3]} & {5{in1[2]}},
                              {in0[3:0], in0[4:4]} & {5{in1[1]}},
                              {in0[4:0]} & {5{in1[0]}}} ), .sign( 1'b0 ), 
                              .pad( 3'b0 ), .mod31(product) );
endmodule


module mod5_add( cin, in0, in1, sum );
input  [4:0] in0, in1;
input  cin;
output [4:0] sum;
wire   [5:0] s;
assign s = in0 + in1 + cin;
assign sum = s[4:0] + s[5];
//assign sum = s[4:0] + ( s[5] | (&s[4:0]) );
endmodule

module MERSENNE_MOD_COMP5( in0, in1, out );
input  [4:0] in0, in1;
output out;

wire z0 = (~|in0) | (&in0); // both 31 and 0 represent 0
wire z1 = (~|in1) | (&in1); // both 31 and 0 represent 0

assign out = (in0==in1) | (z0&z1);

endmodule
