\m4_TLV_version 1d: tl-x.org
\SV
   m4_include_lib(['https://raw.githubusercontent.com/BalaDhinesh/RISC-V_MYTH_Workshop/master/tlv_lib/risc-v_shell_lib.tlv'])
\SV
   m4_makerchip_module   // (Expanded in Nav-TLV pane.)
\TLV
   // TL-Verilog Code for RISC-V RV32I CPU Architecture with all instruction set (Using Load and Store through Jump Logic)...
   // Complete RISC-V RV32I CUP Design using TL-Verilog Abstraction.....
   // /====================\
   // | Sum 1 to 9 Program |
   // \====================/
  
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
   m4_asm(SW, r0, r10, 100)
   m4_asm(LW, r15, r0, 100)
   
   // Optional:
   // m4_asm(JAL, r7, 00000000000000000000) // Done. Jump to itself (infinite loop). (Up to 20-bit signed immediate plus implicit 0 bit (unlike JALR) provides byte address; last immediate bit should also be 0)
   m4_define_hier(['M4_IMEM'], M4_NUM_INSTRS)
   
   |cpu
      @0
         $reset = *reset;
      // YOUR CODE HERE
      // Stimulus for RISC-V CPU Architecture..... 
         $pc[31:0] = (>>1$reset) ? 32'b0 :
                     (>>3$is_load) ? (>>3$int_pc) : 
                     (>>3$is_jal) ? (>>3$br_tgt_pc) :
                     (>>3$is_jalr) ? (>>3$jalr_tgt_pc) :
                     (>>3$taken_br) ? (>>3$br_tgt_pc) :  (>>1$int_pc)  ;
                  
         // Set the Instruction Memory Enable to access the memory and also set the read address...
         $imem_rd_en = !$reset;
         $imem_rd_addr[M4_IMEM_INDEX_CNT-1:0] = $pc[M4_IMEM_INDEX_CNT+1:2];
      
         // Check the reset control to start the Fetch , Decode and Execution Process....
         $start_int = $reset ? 1'b0 : 1'b1;
         $start = $reset ? 1'b0 : ($start_int && !>>1$start_int);
      
      // Assign Program Counter or Pointer for read operation for instcrtuction stored in the IMEM memory....      
      @1
         $int_pc[31:0] = $pc + 32'd4;
         $instr[31:0] = $imem_rd_data;
         $is_i_instr = $instr[6:2] ==? 5'b0000x || $instr[6:2] ==? 5'b001x0 || $instr[6:2] ==? 5'b11001;
         $is_r_instr = $instr[6:2] == 5'b01011 || $instr[6:2] == 5'b10100 || $instr[6:2] == 5'b01110 || $instr[6:2] == 5'b01100 ;
         $is_u_instr = $instr[6:2] ==? 5'b0x101;
         $is_s_instr = $instr[6:2] ==? 5'b0100x;
         $is_b_instr = $instr[6:2] == 5'b11000;
         $is_j_instr = $instr[6:2] ==? 5'b11011;
         
         // Assign immediate for the instrction type (S,B,U & J) .....
         $imm[31:0] = $is_i_instr ? { {21{$instr[31]}}, $instr[30:20]} :
                      $is_s_instr ? { {21{$instr[31]}}, $instr[30:25], $instr[11:7]} :
                      $is_b_instr ? { {20{$instr[31]}}, $instr[7], $instr[30:25] ,$instr[11:8], 1'b0} :
                      $is_u_instr ? { $instr[31], $instr[30:20], $instr[19:12], {12{1'b0}} } :
                      $is_j_instr ? { {11{$instr[31]}}, $instr[19:12], $instr[20], $instr[30:25], $instr[24:21], 1'b0} : 32'b0;
         
         //Extract other parameters like ($rs1, $rs2, $finct3, $funct7, $opcode and $rd etc)....
         $rs2_valid = $is_r_instr || $is_s_instr || $is_b_instr ;
         $rs1_valid = $is_r_instr || $is_s_instr || $is_b_instr || $is_i_instr ;
         $funct7_valid = $is_r_instr;
         $funct3_valid = $is_r_instr || $is_s_instr || $is_b_instr || $is_i_instr ;
         $opcode_valid = $is_r_instr || $is_s_instr || $is_b_instr || $is_i_instr || $is_u_instr || $is_j_instr ;
         $rd_valid = $is_r_instr || $is_u_instr || $is_j_instr || $is_i_instr ;
         
         // Chech all the extracted parameters as valid signal....
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
         
         //Assign Instrction Set and its Decode values......
         $dec_bits[10:0] = { $funct7[5] ,$funct3 ,$opcode};
         $is_beq = $dec_bits ==? 11'bx_000_1100011;
         $is_bne = $dec_bits ==? 11'bx_001_1100011;
         $is_blt = $dec_bits ==? 11'bx_100_1100011;
         $is_bge = $dec_bits ==? 11'bx_101_1100011;
         $is_bltu = $dec_bits ==? 11'bx_110_1100011;
         $is_bgeu = $dec_bits ==? 11'bx_111_1100011;
         $is_addi = $dec_bits ==? 11'bx_000_0010011;
         $is_add = $dec_bits ==? 11'b0_000_0110011;
         $is_lui = $dec_bits ==? 11'bx_xxx_0110111;
         $is_auipc = $dec_bits ==? 11'bx_xxx_0010111;
         $is_jal = $dec_bits ==? 11'bx_xxx_1101111;
         $is_jalr = $dec_bits ==? 11'bx_000_1100111;
         $is_load = $dec_bits ==? 11'bx_xxx_0000011;
         $is_store = $dec_bits ==? 11'bx_0xx_0100011;
         
         $is_slti = $dec_bits ==? 11'bx_010_0010011;
         $is_sltiu = $dec_bits ==? 11'bx_011_0010011;
         $is_xori = $dec_bits ==? 11'bx_100_0100011;
         $is_ori = $dec_bits ==? 11'bx_110_0100011;
         $is_andi = $dec_bits ==? 11'bx_111_0100011;
         $is_slli = $dec_bits ==? 11'b0_001_0100011;
         $is_srli = $dec_bits ==? 11'b0_101_0100011;
         $is_srai = $dec_bits ==? 11'b1_101_0100011;
         $is_sub = $dec_bits ==? 11'b1_000_0110011;
         $is_sll = $dec_bits ==? 11'b0_001_0110011;
         $is_slt = $dec_bits ==? 11'b0_010_0110011;
         $is_sltu = $dec_bits ==? 11'b0_011_0110011;
         $is_xor = $dec_bits ==? 11'b0_100_0110011;
         $is_srl = $dec_bits ==? 11'b0_101_0110011;
         $is_sra = $dec_bits ==? 11'b1_101_0110011;
         $is_or = $dec_bits ==? 11'b0_110_0110011;
         $is_and = $dec_bits ==? 11'b0_111_0110011;
         
         // Check the Read Enable signal and assign the index values (address) for read operation...
         // (Example: Sourcing registers 1 and 2 with index value of 5-Bit)....
      @2   
         $rf_rd_en1 = $rs1_valid;
         $rf_rd_index1[4:0] = $rs1;
         $rf_rd_en2 = $rs2_valid;
         $rf_rd_index2[4:0] = $rs2;
         
         // Increment Program Counter for sourcing the read values to the source registers 1&2
         // Similarly write enable for write operation.....
         $br_tgt_pc[31:0] = $pc + $imm ;
         $jalr_tgt_pc[31:0] = $src1_value + $imm;
         $src1_value[31:0] = ((>>1$rf_wr_en) && (>>1$rd == $rs1 )) ? (>>1$result): $rf_rd_data1; 
         $src2_value[31:0] = ((>>1$rf_wr_en) && (>>1$rd == $rs2 )) ? (>>1$result) : $rf_rd_data2;
         
         // Assign the results ....
      @3
         $sltu_rslt = $is_sltu ? $src1_value < $src2_value : 32'bx ;
         $sltiu_rslt = $is_sltiu ? $src1_value < $imm : 32'bx ;
         
         // RISC-V ALUOperation based on Instruction set fetched....
         $result[31:0] = $is_addi ? $src1_value + $imm : 
                         $is_add  ? $src1_value + $src2_value :
                         $is_andi ? $src1_value & $imm :
                         $is_ori ? $src1_value | $imm :
                         $is_xori ? $src1_value ^ $imm :
                         $is_slli ? $src1_value << $imm[5:0] :
                         $is_srli ? $src1_value >> $imm[5:0] :
                         $is_and ? $src1_value & $src2_value :
                         $is_or ? $src1_value | $src2_value :
                         $is_xor ? $src1_value ^ $src2_value :
                         $is_sub  ? $src1_value - $src2_value :
                         $is_sltu ? $src1_value < $src2_value :
                         $is_sltiu ? $src1_value < $imm :
                         $is_sll ? $src1_value << $src2_value[4:0] :
                         $is_srl ? $src1_value >> $src2_value[4:0] :
                         $is_lui ? {$imm[31:12],12'b0} :
                         $is_auipc ? $imm + $pc :
                         $is_jal ? $pc + 32'd4 :
                         $is_jalr ? $pc + 32'd4 :
                         $is_load ? $src1_value + $imm :
                         $is_store ? $src1_value + $imm :
                         $is_srai ? { {32{$src1_value[31]}}, $src1_value} >> $imm[4:0] :
                         $is_sra ? { {32{$src1_value[31]}}, $src1_value} >> $src2_value[4:0] :
                         $is_slt ? (($src1_value[31] == $src2_value[31]) ? $sltu_rslt : {31'b0,$src1_value[31]} ) :
                         $is_slti ? (($src1_value[31] == $imm[31]) ? $sltiu_rslt : {31'b0,$src1_value[31]} ) : 32'bx ;
         
         // Write Enable and write the data to the sourcing register....
         $rf_wr_en = ($rd == 5'b0 ) ? 1'b0 : ($valid && $rd_valid);
         $rf_wr_index[4:0] = $rd ;
         $rf_wr_data[31:0] = (!$valid) ? (>>2$dmem_rd_data) : $result;
         
         $beq = ($src1_value == $src2_value ) ? 1'b1 :1'b0 ;
         $bne = ($src1_value != $src2_value ) ? 1'b1 :1'b0 ;
         $bltu = ($src1_value < $src2_value ) ? 1'b1 :1'b0 ;
         $bgeu = ($src1_value >= $src2_value ) ? 1'b1 :1'b0 ;
         $blt = ( ($src1_value < $src2_value) ^ ($src1_value[31] != $src2_value[31] )) ? 1'b1 : 1'b0 ;
         $bge = ( ($src1_value >= $src2_value) ^ ($src1_value[31] != $src2_value[31] )) ? 1'b1 : 1'b0 ;
         
         // Branch control operation.....
         $taken_br = ( ($is_beq && $beq) || ($is_bne && $bne) || 
                       ($is_blt && $blt) || ($is_bge && $bge) || 
                       ($is_bltu && $bltu) || ($is_bgeu && $bgeu) ) ? 1'b1 :1'b0 ;
         
         // Load and Jump control....
         $valid = ($is_load) ? 1'b0 : !((>>1$taken_br)|| (>>2$taken_br));
         
         // Check the write enable valid ...
         // if passed then the processed data will be store in the write register next to ALU ....
      @4
         $dmem_wr_en = $valid;
         $dmem_addr[3:0] = $result[5:2] ;
         $dmem_wr_data[31:0] = $src2_value ;
         $dmem_rd_en = $valid;
         $dmem_rd_index[5:0] = $rf_rd_index2 ;
         
         *passed = |cpu/xreg[15]>>5$value == (1+2+3+4+5+6+7+8+9);
         
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
      m4+dmem(@4)    // Args: (read/write stage)
   
   m4+cpu_viz(@4)    // For visualisation, argument should be at least equal to the last stage of CPU logic
                       // @4 would work for all labs
\SV
   endmodule

// Ref: https://www.makerchip.com/sandbox/0rkfAhG55/03lhpK4#

