\m4_TLV_version 1d: tl-x.org
   // This code can be found in: https://github.com/stevehoover/RISC-V_MYTH_Workshop
   
\SV
    m4_include_lib(['https://raw.githubusercontent.com/BalaDhinesh/RISC-V_MYTH_Workshop/master/tlv_lib/risc-v_shell_lib.tlv'])
\SV
    m4_makerchip_module   // (Expanded in Nav-TLV pane.)
\TLV
 // TL-Verilog code for RISC-V Processor (Micro-architecture to Perfrom summation of numbers from 1 to 9)...
 // 3-Cycle RISC-V CPU using TL-Verilog......
 
   // /====================\
   // | Sum 1 to 9 Program |
   // \====================/
   //
   // Program for MYTH Workshop to test RV32I
   // Add 1,2,3,...,9 (in that order).
   //
   // Regs:
   //  r10 (a0): In: 0, Out: final sum
   //  r12 (a2): 10
   //  r13 (a3): 1..10
   //  r14 (a4): Sum
   // 
   // External to function:
   m4_asm(ADD, r10, r0, r0)             // Initialize r10 (a0) to 0.
   // Function:
   m4_asm(ADD, r14, r10, r0)            // Initialize sum register a4 with 0x0
   m4_asm(ADDI, r12, r10, 1010)         // Store count of 10 in register a2.
   m4_asm(ADD, r13, r10, r0)            // Initialize intermediate sum register a3 with 0
   // Loop:
   m4_asm(ADD, r14, r13, r14)           // Incremental addition
   m4_asm(ADDI, r13, r13, 1)            // Increment intermediate register by 1
   m4_asm(BLT, r13, r12, 1111111111000) // If a3 is less than a2, branch to label named <loop>
   m4_asm(ADD, r10, r14, r0)            // Store final result to register a0 so that it can be read by main program
   
   // Optional:
   // m4_asm(JAL, r7, 00000000000000000000) // Done. Jump to itself (infinite loop). (Up to 20-bit signed immediate plus implicit 0 bit (unlike JALR) provides byte address; last immediate bit should also be 0)
   m4_define_hier(['M4_IMEM'], M4_NUM_INSTRS)

   |cpu
      @0
         $reset = *reset;
      // YOUR CODE HERE
      // Stimulus for RISC-V CPU........   
         $pc[31:0] = (>>1$reset) ? 32'b0 : (>>3$valid_taken_br) ? (>>3$br_tgt_pc) :  (>>3$int_pc)  ;
         $imem_rd_en = !$reset;
         $imem_rd_addr[M4_IMEM_INDEX_CNT-1:0] = $pc[M4_IMEM_INDEX_CNT+1:2];
      
         $valid = $reset ? 1'b0 : ($start) ? 1'b1 : (>>3$valid) ;
         $start_int = $reset ? 1'b0 : 1'b1;
         $start = $reset ? 1'b0 : ($start_int && !>>1$start_int);
            
      // Read or Fetch Instructionsm from imem with PC indexed by 32-Bit...
      @1
         $int_pc[31:0] = $pc + 32'd4;
         $instr[31:0] = $imem_rd_data;
         $is_i_instr = $instr[6:2] ==? 5'b0000x || $instr[6:2] ==? 5'b001x0 || $instr[6:2] ==? 5'b11001;
         $is_r_instr = $instr[6:2] == 5'b01011 || $instr[6:2] == 5'b10100 || $instr[6:2] == 5'b01110 || $instr[6:2] == 5'b01100 ;
         $is_u_instr = $instr[6:2] ==? 5'b0x101;
         $is_s_instr = $instr[6:2] ==? 5'b0100x;
         $is_b_instr = $instr[6:2] == 5'b11000;
         $is_j_instr = $instr[6:2] ==? 5'b11011;
         
         // Form immediate values based on instruction type(Example: I, S, B, U and J)...
         $imm[31:0] = $is_i_instr ? { {21{$instr[31]}}, $instr[30:20]} :
                      $is_s_instr ? { {21{$instr[31]}}, $instr[30:25], $instr[11:7]} :
                      $is_b_instr ? { {20{$instr[31]}}, $instr[7], $instr[30:25] ,$instr[11:8], 1'b0} :
                      $is_u_instr ? { $instr[31], $instr[30:20], $instr[19:12], {12{1'b0}} } :
                      $is_j_instr ? { {11{$instr[31]}}, $instr[19:12], $instr[20], $instr[30:25], $instr[24:21], 1'b0} : 32'b0;
         
         // Check the source register file with valid signal ...
         // Extract other instruction files ($rs1, $rs2, $funct3, $funct7, $opcode and $rd)...
         $rs2_valid = $is_r_instr || $is_s_instr || $is_b_instr ;
         $rs1_valid = $is_r_instr || $is_s_instr || $is_b_instr || $is_i_instr ;
         $funct7_valid = $is_r_instr;
         $funct3_valid = $is_r_instr || $is_s_instr || $is_b_instr || $is_i_instr ;
         $opcode_valid = $is_r_instr || $is_s_instr || $is_b_instr || $is_i_instr || $is_u_instr || $is_j_instr ;
         $rd_valid = $is_r_instr || $is_u_instr || $is_j_instr || $is_i_instr ;
         
         // Check valid on instruction fileds...
         ?$rs2_valid
            $rs2[4:0] = $instr[24:20];
         ?$rs1_valid
            $rs1[4:0] = $instr[19:15];
         ?$funct7_valid
            $funct7[6:0] = $instr[31:25];
         ?$funct3_valid
            $funct3[2:0] = $instr[14:12];
         ?$opcode_valid
            $opcode[6:0] = $instr[6:0];
         ?$rd_valid
            $rd[4:0] = $instr[11:7];
         
         // Decode instruction and find the basic instructions....
         $dec_bits[10:0] = { $funct7[5] ,$funct3 ,$opcode};
         $is_beq = $dec_bits ==? 11'bx_000_1100011;
         $is_bne = $dec_bits ==? 11'bx_001_1100011;
         $is_blt = $dec_bits ==? 11'bx_100_1100011;
         $is_bge = $dec_bits ==? 11'bx_101_1100011;
         $is_bltu = $dec_bits ==? 11'bx_110_1100011;
         $is_bgeu = $dec_bits ==? 11'bx_111_1100011;
         $is_addi = $dec_bits ==? 11'bx_000_0010011;
         $is_add = $dec_bits ==? 11'b0_000_0110011;
      //Array index for read cycle or operation....
      @2   
         $rf_rd_en1 = $rs1_valid;
         $rf_rd_index1[4:0] = $rs1;
         $rf_rd_en2 = $rs2_valid;
         $rf_rd_index2[4:0] = $rs2;
         
         $br_tgt_pc[31:0] = $pc + $imm ;
         
      // Soursing the register data 1&2 and assigning....
      @3
         $src1_value[31:0] = $rf_rd_data1; 
         $src2_value[31:0] = $rf_rd_data2;
         
         // Perfom the instructions ADD and ADDI through ALU blcok in the RISC-V CPU....
         $result[31:0] = $is_addi ? $src1_value + $imm : 
                         $is_add  ? $src1_value + $src2_value : 32'bx ;
         
         // Enable the write operation and store the results in the array index of 5-Bits....
         // and store the datas in 32-bit write register (array)...
         $rf_wr_en = ($rd == 5'b0 ) ? 1'b0 : ($valid && $rd_valid);
         $rf_wr_index[4:0] = $rd ;
         $rf_wr_data[31:0] = $result;
         
         // Perfrom the following instruction execution for branching control operation....
         $beq = ($src1_value == $src2_value ) ? 1'b1 :1'b0 ;
         $bne = ($src1_value != $src2_value ) ? 1'b1 :1'b0 ;
         $bltu = ($src1_value < $src2_value ) ? 1'b1 :1'b0 ;
         $bgeu = ($src1_value >= $src2_value ) ? 1'b1 :1'b0 ;
         $blt = ( ($src1_value < $src2_value) ^ ($src1_value[31] != $src2_value[31] )) ? 1'b1 : 1'b0 ;
         $bge = ( ($src1_value >= $src2_value) ^ ($src1_value[31] != $src2_value[31] )) ? 1'b1 : 1'b0 ;
         
         // Control for branching operation for the next cycle....
         $taken_br = ( ($is_beq && $beq) || ($is_bne && $bne) || 
                       ($is_blt && $blt) || ($is_bge && $bge) || 
                       ($is_bltu && $bltu) || ($is_bgeu && $bgeu) ) ? 1'b1 :1'b0 ;
                 
         $valid_taken_br = $valid && $taken_br;
         
         // Pass the RISC-V CPU execustion...
         *passed = |cpu/xreg[10]>>5$value == (1+2+3+4+5+6+7+8+9);
   // Assert these to end simulation (before Makerchip cycle limit).
   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
   
   // Macro instantiations for:
   //  o instruction memory
   //  o register file
   //  o data memory
   //  o CPU visualization
   |cpu
      m4+imem(@1)    // Args: (read stage)
      m4+rf(@2, @3)  // Args: (read stage, write stage) - if equal, no register bypass is required
      //m4+dmem(@4)    // Args: (read/write stage)
   
   m4+cpu_viz(@4)    // For visualisation, argument should be at least equal to the last stage of CPU logic
                       // @4 would work for all labs
\SV
   endmodule

// Ref: https://www.makerchip.com/sandbox/0G6fJh1LR/0KOh2WB#

