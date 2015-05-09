//-----------------------------------------------------
// Design Name : parity_using_bitwise
// File Name   : parity_using_bitwise.v
// Function    : Parity using bitwise xor
// Coder       : Deepak Kumar Tala
//-----------------------------------------------------
module parity_32 (
data_in    , //  8 bit data in
parity   //  1 bit parity out
);
output  parity ;
input [31:0] data_in ; 
     
assign parity = ^data_in; 

endmodule
