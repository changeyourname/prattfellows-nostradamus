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
# Purpose: This file contains all micorarchitecture parameters of the core.
# Author:  FabGen
*******************************************************************************/

`timescale 1ns/100ps

`define WB_NUM 0
`define WB_VALUE 0

//rn19
`define SIZE_CRC 							5
`define SIZE_MOD							5
//end rn19

`define START_PC	       	32'd4194624	
`define STACK_BASE	       	32'h7fffb000
`define ZERO_REG               	0
`define STACK_POINTER          	29
`define RETURN_ADDR_REG	       	31	


`define SIZE_PC                	32
`define SIZE_INSTRUCTION       	64
`define CACHE_BYTE_OFFSET      	4
`define CACHE_WIDTH            	4*`SIZE_INSTRUCTION // in bits
`define CACHE_INDEX_BITS       	10
`define CACHE_DEPTH            	512
`define CACHE_TAG_BITS         	16
`define PHYSICAL_ADDR          	`CACHE_TAG_BITS+`CACHE_INDEX_BITS+`CACHE_BYTE_OFFSET


`define FETCH_BANDWIDTH        	4
`define FETCH_BANDWIDTH_LOG    	2        
`define INSTRUCTION_BUNDLE    	(`FETCH_BANDWIDTH*`SIZE_INSTRUCTION)


`define SIZE_BYTE_OFFSET       	3
`define SIZE_BTB               	4096
`define SIZE_BTB_LOG           	12
`define SIZE_BTB_INDEX         	1024
`define SIZE_BTB_INDEX_LOG     	10
`define SIZE_CNT_TABLE         	65536
`define SIZE_CNT_TBL_LOG       	16
`define SIZE_PREDICTION_CNT    	2
`define TAG_TYPE_BITS		   2
`define BTB_ASSOC			   4
`define BTB_ASSOC_LOG		   2
`define FIFO_SIZE			   (`BTB_ASSOC_LOG*`BTB_ASSOC)
`define MAX_PREDICTION_CNT		3


`define SIZE_RAS               	32
`define SIZE_RAS_LOG           	5


`define SIZE_CTI_QUEUE         	16
`define SIZE_CTI_LOG           	4
`define CTRL_CNT_FETCH_BLOCK    3

`define INST_QUEUE             	16
`define INST_QUEUE_LOG         	4


`define BRANCH_TYPE            	2


`define SIZE_DATA              	32
`define INSTRUCTION_TYPES      	4
`define INST_TYPES_LOG         	2
`define INSTRUCTION_TYPE0      	2'b00     // Simple ALU
`define INSTRUCTION_TYPE1      	2'b01     // Complex ALU (for MULTIPLY & DIVIDE)
`define INSTRUCTION_TYPE2      	2'b10     // CONTROL Instructions
`define INSTRUCTION_TYPE3      	2'b11     // LOAD/STORE Address Generator
`define LDST_BYTE              	2'b00
`define LDST_HALF_WORD         	2'b01
`define LDST_WORD              	2'b10
`define LDST_DOUBLE_WORD       	2'b11
`define LDST_TYPES_LOG         	2
`define BRANCH_COUNT           	3        // Niket change it to checkpoint log....
       	 

`define SIZE_PHYSICAL_TABLE    	96
`define SIZE_PHYSICAL_LOG      	7
`define SIZE_RMT               	34        /* Size of the Register Map Table. */
`define SIZE_RMT_LOG           	6
`define CHECKPOINTS            	4
`define CHECKPOINTS_LOG        	2
`define RMT_CHECKPOINT_VECTOR 	(`SIZE_RMT*`SIZE_PHYSICAL_LOG)


`define SIZE_FREE_LIST         	(`SIZE_PHYSICAL_TABLE - `SIZE_RMT)
`define SIZE_FREE_LIST_LOG     	6


`define DISPATCH_WIDTH         	4
`define SIZE_ISSUEQ            	32
`define SIZE_ISSUEQ_LOG        	5
`define ISSUE_WIDTH		4


`define SIZE_ACTIVELIST        	128
`define SIZE_ACTIVELIST_LOG    	7
`define SIZE_REGFILE	       	8
`define ACTIVE_ENTRY_LENGTH    	52
`define COMMIT_WIDTH           	4


`define LSQ_FLAGS		2	 /* bit[0]:inst0Load  bit[1]:inst0Store */
`define SIZE_LSQ               	32
`define SIZE_LSQ_LOG           	5
`define SIZE_MSHR              	8
`define SIZE_MSHR_LOG          	3
`define SIZE_WRITEBUF          	16
`define SIZE_WRITEBUF_LOG      	4
`define SIZE_DCACHE_ADDR       	32


`define NUM_FU                 	4
`define FU0                    	2'b00     // Simple ALU
`define FU1                    	2'b01     // Complex ALU (for MULTIPLY & DIVIDE)
`define FU2                    	2'b10     // ALU for CONTROL Instructions
`define FU3                    	2'b11     // LOAD/STORE Address Generator
`define FU0_LATENCY            	1
`define FU1_LATENCY            	3
`define FU2_LATENCY            	1
`define FU3_LATENCY            	2
`define EXECUTION_FLAGS		8 	  
					  /*  bit[0]: Mispredict, 
					   *  bit[1]: Exception,
					   *  bit[2]: Executed,
					   *  bit[3]: Fission Instruction,
					   *  bit[4]: Destination Valid,
					   *  bit[5]: Predicted Control Instruction
					   *  bit[6]: Load byte/half-word sign
					   *  bit[7]: Conditional Branch Instruction	
					   */	
`define WRITEBACK_FLAGS		8	  /* EXECUTION_FLAGS */

`define WRITEBACK_LATENCY      	2

`define RETIRE_WIDTH		4	// Maximum number of instructions that
					// can retire this cycle.


`define VERIFY

//`define ICACHE
