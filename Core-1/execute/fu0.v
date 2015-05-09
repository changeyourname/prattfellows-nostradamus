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
# Purpose: FU0 performs simple arithmetic and logic operations which includes 
#	   addition, substraction, or, etc. 
# Author:  FabGen
*******************************************************************************/

`timescale 1ns/100ps

/* Algorithm
 
 1. FU0 is a simple ALU. It takes one clock cycle to execute the required
    operation. 

 2. FU0 may receive one instructions per cycle. The instruction packet should
    contain following information:
	(.) Opcode
	(.) Source Data-1
	(.) Source Data-2
	(.) Destination Register
	(.) Active List ID
	(.) Issue Queue ID
	(.) Branch Mask

 3. FU0 also receives control execution flags from the bypass path ( Bypass
    designated for Control execution unit). Bypass information comes from the
    instruction executed in the previous cycle.

 4. Output of a global Functional unit would be (following information is contained
    by outPacket_o):
        (.) Executed             : bits-`SIZE_PHYSICAL_LOG+`SIZE_ACTIVELIST_LOG+`SIZE_DATA+`SIZE_ISSUEQ_LOG`SIZE_LSQ_LOG+`CHECKPOINTS_LOG+`SIZE_CTI_LOG+`SIZE_PC+3
        (.) Exception            : bits-`SIZE_PHYSICAL_LOG+`SIZE_ACTIVELIST_LOG+`SIZE_DATA+`SIZE_ISSUEQ_LOG`SIZE_LSQ_LOG+`CHECKPOINTS_LOG+`SIZE_CTI_LOG+`SIZE_PC+2
        (.) Mispredict           : bits-`SIZE_PHYSICAL_LOG+`SIZE_ACTIVELIST_LOG+`SIZE_DATA+`SIZE_ISSUEQ_LOG`SIZE_LSQ_LOG+`CHECKPOINTS_LOG+`SIZE_CTI_LOG+`SIZE_PC+1
        (.) Destination Register : bits-`SIZE_PHYSICAL_LOG+`SIZE_ACTIVELIST_LOG+`SIZE_DATA+`SIZE_ISSUEQ_LOG`SIZE_LSQ_LOG+`CHECKPOINTS_LOG+`SIZE_CTI_LOG+`SIZE_PC:`SIZE_ACTIVELIST_LOG+`SIZE_DATA+`SIZE_ISSUEQ_LOG`SIZE_LSQ_LOG+`CHECKPOINTS_LOG+`SIZE_CTI_LOG+`SIZE_PC+1
        (.) Active List ID       : bits-`SIZE_ACTIVELIST_LOG+`SIZE_DATA+`SIZE_ISSUEQ_LOG`SIZE_LSQ_LOG+`CHECKPOINTS_LOG+`SIZE_CTI_LOG+`SIZE_PC:`SIZE_DATA+`SIZE_ISSUEQ_LOG`SIZE_LSQ_LOG+`CHECKPOINTS_LOG+`SIZE_CTI_LOG+`SIZE_PC+1
        (.) Output Data          : bits-`SIZE_DATA+`SIZE_ISSUEQ_LOG`SIZE_LSQ_LOG+`CHECKPOINTS_LOG+`SIZE_CTI_LOG+`SIZE_PC:`SIZE_ISSUEQ_LOG`SIZE_LSQ_LOG+`CHECKPOINTS_LOG+`SIZE_CTI_LOG+`SIZE_PC+1
        (.) Issue Queue ID       : bits-`SIZE_ISSUEQ_LOG`SIZE_LSQ_LOG+`CHECKPOINTS_LOG+`SIZE_CTI_LOG+`SIZE_PC:`SIZE_LSQ_LOG+`CHECKPOINTS_LOG+`SIZE_CTI_LOG+`SIZE_PC+1
        (.) Load-Store Queue ID  : bits-`SIZE_LSQ_LOG+`CHECKPOINTS_LOG+`SIZE_CTI_LOG+`SIZE_PC:`CHECKPOINTS_LOG+`SIZE_CTI_LOG+`SIZE_PC+1 
        (.) Shadow Map Table ID  : bits-`CHECKPOINTS_LOG+`SIZE_CTI_LOG+`SIZE_PC:`SIZE_CTI_LOG+`SIZE_PC+1
        (.) Ctiq Tag             : bits-`SIZE_CTI_LOG+`SIZE_PC:`SIZE_PC+1 
        (.) Computed Target Addr : bits-`SIZE_PC:1
        (.) Computed Direction   : bits-0
*/


module FU0 (
	input clk,
	input reset,
             
	input [`SIZE_IMMEDIATE+`SIZE_OPCODE_I+2*(`SIZE_DATA+`SIZE_PHYSICAL_LOG)+`SIZE_PHYSICAL_LOG+
		`SIZE_ACTIVELIST_LOG+`SIZE_ISSUEQ_LOG+`CHECKPOINTS-1:0] inPacket_i, 
	input [`SIZE_DATA-1:0] fuFinalData1_i,
	input [`SIZE_DATA-1:0] fuFinalData2_i,
	input inValid_i,
				 
	input ctrlVerified_i,
	input ctrlMispredict_i,
	input [`CHECKPOINTS_LOG-1:0] ctrlSMTid_i, 

	/* Output packet from the functional unit.
	*/	
	output [`CHECKPOINTS+`EXECUTION_FLAGS+`SIZE_PHYSICAL_LOG+`SIZE_ACTIVELIST_LOG+`SIZE_DATA+
		`SIZE_ISSUEQ_LOG+`SIZE_LSQ_LOG+`CHECKPOINTS_LOG+`SIZE_CTI_LOG+`SIZE_PC:0] outPacket_o,
	output outValid_o, 
									output error
); 

//wire error;

reg outValid;
reg flush;
reg instBrDir;
reg [`SIZE_CTI_LOG-1:0] instCtiqTag;
reg [`SIZE_PC-1:0] instTarAddr;
reg [`SIZE_PC-1:0] instPC;
reg [`SIZE_OPCODE_I-1:0] instOpcode;
reg [`SIZE_IMMEDIATE-1:0] instImmd;
reg [`SIZE_PHYSICAL_LOG-1:0] instDestReg;
reg [`CHECKPOINTS_LOG-1:0] instSMTid;
reg [`CHECKPOINTS-1:0] instBranchMask;
reg [`SIZE_ISSUEQ_LOG-1:0] instIQentry;
reg [`SIZE_ACTIVELIST_LOG-1:0] instALid;
reg [`SIZE_LSQ_LOG-1:0] instLSQid;

wire [`SIZE_DATA-1:0] result;
wire [`EXECUTION_FLAGS-1:0] flags;

assign outValid_o  = outValid;
assign outPacket_o = {instBranchMask,flags,instDestReg,instALid,result,instIQentry,
	instLSQid,instSMTid,instCtiqTag,instTarAddr,instBrDir};

/* Following filters the instructions which is newer than the mis-predicted 
   branch (branch inst computed in the last cycle).
*/
always @(*)
begin
	instBranchMask = inPacket_i[`CHECKPOINTS-1:0]; 
	outValid = inValid_i; 

	flush = instBranchMask[ctrlSMTid_i];
	if(ctrlVerified_i && ctrlMispredict_i)
	begin
		if(flush)
			outValid = 1'b0;
		else
			outValid = inValid_i;	
	end
end    

/* Following extracts information from the incoming FU packet.
 */ 
always @(*)
begin:EXTRACTS_INFO
	instIQentry = inPacket_i[`SIZE_ISSUEQ_LOG+`CHECKPOINTS-1:`CHECKPOINTS];
	instALid    = inPacket_i[`SIZE_ACTIVELIST_LOG+`SIZE_ISSUEQ_LOG+`CHECKPOINTS-1:`SIZE_ISSUEQ_LOG+`CHECKPOINTS];
	instDestReg = inPacket_i[`SIZE_PHYSICAL_LOG+`SIZE_ACTIVELIST_LOG+`SIZE_ISSUEQ_LOG+`CHECKPOINTS-1:
		`SIZE_ACTIVELIST_LOG+`SIZE_ISSUEQ_LOG+`CHECKPOINTS];
	instOpcode  = inPacket_i[`SIZE_OPCODE_I+2*(`SIZE_DATA+`SIZE_PHYSICAL_LOG)+`SIZE_PHYSICAL_LOG+`SIZE_ACTIVELIST_LOG+
		`SIZE_ISSUEQ_LOG+`CHECKPOINTS-1:2*(`SIZE_DATA+`SIZE_PHYSICAL_LOG)+`SIZE_PHYSICAL_LOG+
		`SIZE_ACTIVELIST_LOG+`SIZE_ISSUEQ_LOG+`CHECKPOINTS];
	instImmd    = inPacket_i[`SIZE_IMMEDIATE+`SIZE_OPCODE_I+2*(`SIZE_DATA+`SIZE_PHYSICAL_LOG)+`SIZE_PHYSICAL_LOG+
		`SIZE_ACTIVELIST_LOG+`SIZE_ISSUEQ_LOG+`CHECKPOINTS-1:`SIZE_OPCODE_I+2*(`SIZE_DATA+
		`SIZE_PHYSICAL_LOG)+`SIZE_PHYSICAL_LOG+`SIZE_ACTIVELIST_LOG+`SIZE_ISSUEQ_LOG+`CHECKPOINTS];

	instIQentry = 0;
	instLSQid   = 0;
	instSMTid   = 0; 
	instCtiqTag = 0;
	instTarAddr = 0;
	instBrDir   = 0;
	instPC      = 0;
end

/* Functionality for the FU0.
*/
wire cout;
Simple_ALU salu (
	.data1_i(fuFinalData1_i),
	.data2_i(fuFinalData2_i),
	.immd_i(instImmd),
	.opcode_i(instOpcode),
	.result_o(result),
	.cout_o(cout),
	.flags_o(flags)
);

/* rn19 MODULO ALU */
wire [`SIZE_DATA-1:0] result2;
wire [`SIZE_MOD-1:0]	result2_mod, result_mod;
wire [`EXECUTION_FLAGS-1:0] flags2;
wire [2*`SIZE_DATA-1:0] result_in;

wire error_FU0;
Simple_ALU_mod salumod (
	.data1_i(fuFinalData1_i[`SIZE_DATA-1:0]),
	.data2_i(fuFinalData2_i[`SIZE_DATA-1:0]),
	.immd_i(instImmd),
	.opcode_i(instOpcode),
	.result_o(result2),
	.result_mod_o(result2_mod),
	.flags_o(flags2));
	
assign result_in = {cout, result};
mod31_64bit moddata1 (.data(result_in), .pad(3'b000), .sign(1'b0), .mod31(result_mod));

assign error_FU0 = (result2 != result & result2_mod != result_mod)?1'b1:1'b0;
assign error = error_FU0;

endmodule
