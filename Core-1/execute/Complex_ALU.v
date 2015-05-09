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
# Purpose: This is a Complex ALU module
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

module Complex_ALU (
			 input [`SIZE_DATA-1:0] 		data1_i,	
	     	 input [`SIZE_DATA-1:0] 		data2_i,	
		     input [`SIZE_IMMEDIATE-1:0] 	immd_i,
		     input [`SIZE_OPCODE_I-1:0] 	opcode_i,

			 
		     output [(2*`SIZE_DATA)-1:0] 	result_o,
		     output [`EXECUTION_FLAGS-1:0] 	flags_o,
				output error 
	           ); 

wire error;
wire signed [`SIZE_DATA-1:0] 		data1_s;
wire signed [`SIZE_DATA-1:0] 		data2_s;
reg [(2*`SIZE_DATA)-1:0] 		result;
reg [`EXECUTION_FLAGS-1:0] 		flags;
reg error_obs;
wire [`SIZE_MOD-1:0]	data1_mod, data2_mod, data1_mod_s, data2_mod_s;
wire [`SIZE_MOD-1:0] mulres_mod, mulres_mod_s, mulcheck, mulcheck_s;
wire [`SIZE_MOD-1:0] divres_mod, divmod_mod, btimesc, divcheck;
wire [`SIZE_MOD-1:0] divres_mod_s, divmod_mod_s, btimesc_s, divcheck_s;


mod31_32bit mod1 (.data(data1_i), .pad(3'b000), .sign(1'b0), .mod31(data1_mod));
mod31_32bit mod2 (.data(data2_i), .pad(3'b000), .sign(1'b0), .mod31(data2_mod));
mod31_32bit mod3 (.data(data1_s), .pad({2'b00,data1_s[`SIZE_DATA-1]}), .sign(data1_s[`SIZE_DATA-1]), .mod31(data1_mod_s));
mod31_32bit mod4 (.data(data2_s), .pad({2'b00,data2_s[`SIZE_DATA-1]}), .sign(data2_s[`SIZE_DATA-1]), .mod31(data2_mod_s));

// MULTIPLICATION
mod31_64bit mod5 (.data({result2,result1}), .pad(3'b000), .sign(1'b0), .mod31(mulres_mod));
mod31_64bit mod6 (.data({result2_s,result1_s}), .pad(3'b000), .sign(1'b0), .mod31(mulres_mod_s));
mod5_mul mod7 (.in0(data1_mod), .in1(data2_mod), .product(mulcheck));
mod5_mul mod8 (.in0(data1_mod_s), .in1(data2_mod_s), .product(mulcheck_s));
// DIVISION
mod31_32bit mod9  (.data(result1), .pad(3'b000), .sign(1'b0), .mod31(divres_mod));
mod31_32bit mod10 (.data(result2), .pad(3'b000), .sign(1'b0), .mod31(divmod_mod));
mod5_mul    mod11 (.in0(data2_mod), .in1(divres_mod), .product(btimesc));
mod5_add		mod12	(.cin(1'b0), .in0(btimesc), .in1(divmod_mod), .sum(divcheck));
mod31_32bit mod13 (.data(result1_s), .pad(3'b000), .sign(1'b0), .mod31(divres_mod_s));
mod31_32bit mod14 (.data(result2_s), .pad(3'b000), .sign(1'b0), .mod31(divmod_mod_s));
mod5_mul    mod15 (.in0(data2_mod_s), .in1(divres_mod_s), .product(btimesc_s));
mod5_add		mod16	(.cin(1'b0), .in0(btimesc_s), .in1(divmod_mod_s), .sum(divcheck_s));





assign error = error_obs;

assign result_o    = result;
assign flags_o     = flags;


assign data1_s     = data1_i;	
assign data2_s     = data2_i;	

always @(*)
begin:ALU_OPERATION
  reg signed [`SIZE_DATA-1:0] 	result1_s;
  reg signed [`SIZE_DATA-1:0] 	result2_s;
  reg [`SIZE_DATA-1:0] 		result1;
  reg [`SIZE_DATA-1:0] 		result2;
	
  result    = 0;
  flags     = 0;
	error_obs = 0;
  case(opcode_i)
	`MULT_L:
	 begin
		{result2_s,result1_s} = data1_s * data2_s;
		result		      = result1_s;
		flags                 = {1'b0,1'b1,1'b1,1'b1,1'b0,1'b0};
		if (((mulcheck==31)?0:mulcheck) != ((mulres_mod==31)?0:mulres_mod))
			error_obs = 1;		
	 end
	`MULT_H:
	 begin
		{result2_s,result1_s} = data1_s * data2_s;
		result		      = result2_s;
		flags                 = {1'b0,1'b1,1'b0,1'b1,1'b0,1'b0};
		if (((mulcheck_s==31)?0:mulcheck_s) != ((mulres_mod_s==31)?0:mulres_mod_s))
			error_obs = 1;		
	 end
	`MULTU_L:
	 begin
		{result2,result1}     = data1_i * data2_i;
		result		      = result1;
		flags                 = {1'b0,1'b1,1'b1,1'b1,1'b0,1'b0};
		if (((mulcheck==31)?0:mulcheck) != ((mulres_mod==31)?0:mulres_mod))
			error_obs = 1;		
	 end
	`MULTU_H:
	 begin
		{result2,result1}     = data1_i * data2_i;
		result		      = result2;
		flags                 = {1'b0,1'b1,1'b0,1'b1,1'b0,1'b0};
		if (((mulcheck_s==31)?0:mulcheck_s) != ((mulres_mod_s==31)?0:mulres_mod_s))
			error_obs = 1;		
	 end
	 `DIV_L:
         begin
                {result2_s,result1_s} = data1_s / data2_s;
                result                = result1_s;
                flags                 = {1'b0,1'b1,1'b1,1'b1,1'b0,1'b0};
         end
        `DIV_H:
         begin
                {result1_s,result2_s} = data1_s % data2_s;
                result                = result2_s;
                flags                 = {1'b0,1'b1,1'b0,1'b1,1'b0,1'b0};
         end
        `DIVU_L:
         begin
                {result2,result1}     = data1_i / data2_i;
                result                = result1;
                flags                 = {1'b0,1'b1,1'b1,1'b1,1'b0,1'b0};
         end
        `DIVU_H:
         begin
                {result1,result2}     = data1_i % data2_i;
                result                = result2;
                flags                 = {1'b0,1'b1,1'b0,1'b1,1'b0,1'b0};
         end
	`SYSCALL:
	 begin
		result                = 0;
                flags                 = {1'b0,1'b0,1'b0,1'b1,1'b1,1'b0};
	 end
  endcase
end    


endmodule
