/*******************************************************************************
#                        NORTH CAROLINA STATE UNIVERSITY
#
#                               FabScalar Project
#
# FabScalar Copyright (c) 2007-2011 by Niket K. Choudhary, Salil Wadhavkar,
# and Eric Rotenberg.  All Rights Reserved.
#
# This is a beta-release version.  It must not be redistributed at this time.
#
# Purpose: This is a simple ALU module.
# Author:  FabGen
*******************************************************************************/

`timescale 1ns/100ps

/* Algorithm
 1. result_o contains the result of the arithmetic operation.
 2. flags_o has following fields:
	(.) Executed  :"bit-2"
       	(.) Exception :"bit-1"
       	(.) Mispredict:"bit-0"
***************************************************************************/


module NU_Simple_ALU_mod (
			input [`SIZE_DATA-1:0] 		data1_i,	
        input [`SIZE_DATA-1:0] 		data2_i,	
		    input [`SIZE_IMMEDIATE-1:0] 	immd_i,
		    input [`SIZE_OPCODE_I-1:0] 		opcode_i,

		    output [`SIZE_DATA-1:0] 		result_o,
				output [`SIZE_DATA-1:0] 		result_mod_o,
		    output [`EXECUTION_FLAGS-1:0] 	flags_o	
	          ); 


reg [`SIZE_MOD-1:0]			result_mod;
reg [`SIZE_DATA-1:0] 		result;
reg [`EXECUTION_FLAGS-1:0] 	flags;
wire [`SIZE_MOD-1:0] data1_mod, data2_mod, immd_mod;
wire [`SIZE_MOD-1:0] sum12, sum1i, diff12;
wire cinsub12;

wire[`SIZE_DATA-1:0] sign_ex_immd;
assign sign_ex_immd = (immd_i[`SIZE_IMMEDIATE-1] == 1'b1)? {16'b1111111111111111,immd_i}:
		{16'b0000000000000000,immd_i};

mod31_32bit moddata1 (.data(data1_i), .pad(3'b000), .sign(1'b0), .mod31(data1_mod));
mod31_32bit moddata2 (.data(data2_i), .pad(3'b000), .sign(1'b0), .mod31(data2_mod));
mod31_32bit modimmd  (.data(sign_ex_immd), .pad(3'b000), .sign(1'b0), .mod31(immd_mod));

assign result_o    = result;
assign result_mod_o = result_mod;
assign flags_o     = flags;


assign cinsub12 = (data1_i > data2_i)?1'b1:1'b0;
mod5_add add12 (.cin(1'b0), .in0(data1_mod), .in1(data2_mod), .sum(sum12));
mod5_add add1i (.cin(1'b0), .in0(data1_mod), .in1(immd_mod), .sum(sum1i));
mod5_add sub12 (.cin(cinsub12), .in0(data1_mod), .in1(data2_mod), .sum(diff12));


always @(*)
begin:ALU_OPERATION
  reg signed [`SIZE_DATA-1:0] data_signed1;
  reg cout;
	
  result    = 0;
  result_mod= 0;
  cout      = 0;	
  flags     = 0;

  case(opcode_i)
	`ADD:    
	 begin
		result_mod = sum12;
		flags         	= {1'b0,1'b1,1'b0,1'b1,cout,1'b0};
	 end
	`ADDI:
	 begin
		result_mod = sum1i;
		flags         	= {1'b0,1'b1,1'b0,1'b1,cout,1'b0};
	 end
	`ADDU:                    
	 begin
		result_mod = sum12;
		flags         	= {1'b0,1'b1,1'b0,1'b1,1'b0,1'b0};
	 end
	`ADDIU:                   
	 begin
		result_mod = sum1i;
		flags         	= {1'b0,1'b1,1'b0,1'b1,1'b0,1'b0};
	 end
	`SUB:                     
	 begin
		result_mod = diff12;
                flags         	= {1'b0,1'b1,1'b0,1'b1,cout,1'b0};
	 end
	`SUBU:                    
	 begin
		result_mod = sum12;
                flags         	= {1'b0,1'b1,1'b0,1'b1,1'b0,1'b0};
	 end
	`MFHI:                    
	 begin
		result		= data1_i;
                flags   	= {1'b0,1'b1,1'b0,1'b1,1'b0,1'b0};
	 end
	`MTHI:                    
	 begin
		result		= data1_i;
                flags   	= {1'b0,1'b1,1'b0,1'b1,1'b0,1'b0};
	 end
	`MFLO:                    
	 begin
		result		= data1_i;
                flags   	= {1'b0,1'b1,1'b0,1'b1,1'b0,1'b0};
	 end
	`MTLO:                    
	 begin
		result		= data1_i;
                flags   	= {1'b0,1'b1,1'b0,1'b1,1'b0,1'b0};
	 end
	`AND_:                    
	 begin
		result  	= data1_i & data2_i;
                flags   	= {1'b0,1'b1,1'b0,1'b1,1'b0,1'b0};
	 end
	`ANDI:                    
	 begin
		result  	= data1_i & {16'b0,immd_i};
                flags   	= {1'b0,1'b1,1'b0,1'b1,1'b0,1'b0};
	 end
	`OR:                      
	 begin
		result  	= data1_i | data2_i;
                flags   	= {1'b0,1'b1,1'b0,1'b1,1'b0,1'b0};
	 end
	`ORI:                     
	 begin
		result  	= data1_i | {16'b0,immd_i};
                flags   	= {1'b0,1'b1,1'b0,1'b1,1'b0,1'b0};
	 end
	`XOR:                     
	 begin
		result  	= data1_i ^ data2_i;
                flags   	= {1'b0,1'b1,1'b0,1'b1,1'b0,1'b0};
	 end
	`XORI:                    
	 begin
		result  	= data1_i ^ {16'b0,immd_i};
                flags   	= {1'b0,1'b1,1'b0,1'b1,1'b0,1'b0};
	 end
	`NOR:                     
	 begin
		result  	= ~(data1_i | data2_i);
                flags   	= {1'b0,1'b1,1'b0,1'b1,1'b0,1'b0};
	 end
	`SLL:                     
	 begin
		result  	= data1_i << immd_i;
                flags   	= {1'b0,1'b1,1'b0,1'b1,1'b0,1'b0};
	 end
	`SLLV:                    
	 begin
		result  	= data2_i << (data1_i & 32'h1f);
                flags   	= {1'b0,1'b1,1'b0,1'b1,1'b0,1'b0};
	 end
	`SRL:                     
	 begin
		result  	= data1_i >> immd_i;
                flags   	= {1'b0,1'b1,1'b0,1'b1,1'b0,1'b0};
	 end
	`SRLV:                    
	 begin
		result  	= data2_i >> (data1_i & 32'h1f);
                flags   	= {1'b0,1'b1,1'b0,1'b1,1'b0,1'b0};
	 end
	`SRA:                     
	 begin
		data_signed1	= data1_i;
		result 		= data_signed1 >>> immd_i;
                flags   	= {1'b0,1'b1,1'b0,1'b1,1'b0,1'b0};
	 end
	`SRAV:                    
	 begin
		data_signed1	= data2_i;
		result  	= data_signed1 >>> (data1_i & 32'h1f);
                flags   	= {1'b0,1'b1,1'b0,1'b1,1'b0,1'b0};
	 end
	`SLT:                    
	 begin
		case({data1_i[31],data2_i[31]})
		  2'b00: result = (data1_i < data2_i);
		  2'b01: result = 1'b0;
		  2'b10: result = 1'b1;
		  2'b11: result = (data1_i < data2_i);		
		endcase
                flags   	= {1'b0,1'b1,1'b0,1'b1,1'b0,1'b0};
	 end
	`SLTI:                    
	 begin
		case({data1_i[31],sign_ex_immd[31]})
		  2'b00: result = (data1_i < sign_ex_immd);
		  2'b01: result = 1'b0;
		  2'b10: result = 1'b1;
		  2'b11: result = (data1_i < sign_ex_immd);		
		endcase
                flags   	= {1'b0,1'b1,1'b0,1'b1,1'b0,1'b0};
	 end
	`SLTU:                    
	 begin
		result  	= (data1_i < data2_i);
                flags   	= {1'b0,1'b1,1'b0,1'b1,1'b0,1'b0};
	 end
	`SLTIU:
	 begin
		result  	= (data1_i < {16'b0,immd_i});
                flags   	= {1'b0,1'b1,1'b0,1'b1,1'b0,1'b0};
	 end
	`LUI:
	 begin
		result  	= {immd_i,16'b0};
                flags   	= {1'b0,1'b1,1'b0,1'b1,1'b0,1'b0};
	 end
	`NOP:	
	 begin
                flags   	= {1'b0,1'b0,1'b0,1'b1,1'b0,1'b0};
	 end
  endcase
end    



endmodule
