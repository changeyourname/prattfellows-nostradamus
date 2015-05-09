
//-----------------------------------------------------------------------------
// Copyright (C) 2009 OutputLogic.com 
// This source file may be used and distributed without restriction 
// provided that this copyright statement is not removed from the file 
// and that any derivative work contains the original copyright notice 
// and the associated disclaimer. 
// 
// THIS SOURCE FILE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS 
// OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED	
// WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE. 
//-----------------------------------------------------------------------------
// CRC module for data[31:0] ,   crc[4:0]=1+x^2+x^5;
//-----------------------------------------------------------------------------
module crc_PC(
  input [31:0] data_in,
  output [4:0] crc_out
  );

  reg [4:0] lfsr_c;

  assign crc_out = lfsr_c;

  always @(*) begin
    lfsr_c[0] = data_in[0] ^ data_in[3] ^ data_in[5] ^ data_in[6] ^ data_in[9] ^ data_in[10] ^ data_in[11] ^ data_in[12] ^ data_in[13] ^ data_in[17] ^ data_in[18] ^ data_in[20] ^ data_in[21] ^ data_in[22] ^ data_in[24] ^ data_in[26] ^ data_in[31];
    lfsr_c[1] = data_in[1] ^ data_in[4] ^ data_in[6] ^ data_in[7] ^ data_in[10] ^ data_in[11] ^ data_in[12] ^ data_in[13] ^ data_in[14] ^ data_in[18] ^ data_in[19] ^ data_in[21] ^ data_in[22] ^ data_in[23] ^ data_in[25] ^ data_in[27];
    lfsr_c[2] = data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7] ^ data_in[8] ^ data_in[9] ^ data_in[10] ^ data_in[14] ^ data_in[15] ^ data_in[17] ^ data_in[18] ^ data_in[19] ^ data_in[21] ^ data_in[23] ^ data_in[28] ^ data_in[31];
    lfsr_c[3] = data_in[1] ^ data_in[3] ^ data_in[4] ^ data_in[7] ^ data_in[8] ^ data_in[9] ^ data_in[10] ^ data_in[11] ^ data_in[15] ^ data_in[16] ^ data_in[18] ^ data_in[19] ^ data_in[20] ^ data_in[22] ^ data_in[24] ^ data_in[29];
    lfsr_c[4] = data_in[2] ^ data_in[4] ^ data_in[5] ^ data_in[8] ^ data_in[9] ^ data_in[10] ^ data_in[11] ^ data_in[12] ^ data_in[16] ^ data_in[17] ^ data_in[19] ^ data_in[20] ^ data_in[21] ^ data_in[23] ^ data_in[25] ^ data_in[30];

  end // always

endmodule // crc

