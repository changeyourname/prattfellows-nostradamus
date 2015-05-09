module WireBreaker(
input in,
output out,
input[31:0] num);

assign out = (num==`WB_NUM)?`WB_VALUE:in;

endmodule
