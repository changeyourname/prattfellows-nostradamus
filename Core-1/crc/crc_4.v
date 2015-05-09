
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
// CRC module for data[3:0] ,   crc[4:0]=1+x^2+x^5;
//-----------------------------------------------------------------------------
module crc_4(
  input [3:0] data_in,
  output [4:0] crc_out
  );

  reg [4:0] lfsr_c;

  assign crc_out = lfsr_c;

  always @(*) begin
    lfsr_c[0] = data_in[0] ^ data_in[3];
    lfsr_c[1] = data_in[1];
    lfsr_c[2] = data_in[0] ^ data_in[2] ^ data_in[3];
    lfsr_c[3] = data_in[1] ^ data_in[3];
    lfsr_c[4] = data_in[2];

  end // always
endmodule // crc

