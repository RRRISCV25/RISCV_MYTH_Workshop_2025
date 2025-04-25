\m5_TLV_version 1d: tl-x.org
\m5
   
   // ============================================
   // Welcome, new visitors! Try the "Learn" menu.
   // ============================================
   
   //use(m5-1.0)   /// uncomment to use M5 macro library.
\SV
   // Macro providing required top-level module definition, random
   // stimulus support, and Verilator config.
   m5_makerchip_module   // (Expanded in Nav-TLV pane.)
\TLV
   // $reset = *reset;
   // Logic Gate (Combination circuit)...
   $INV_out = !$A_inp; // Inverter Logic...
   $AND_out = ($A_inp && $B_inp); // AND Logic...
   $OR_out = ($A_inp || $B_inp); // OR Logic...
   $XOR_out = ($A_inp ^ $B_inp); // XOR Logic...
   $NAND_out = !($A_inp && $B_inp); // NAND Logic...
   $NOR_out = !($A_inp || $B_inp); // NOR Logic...
   $XNOR_out = !($A_inp ^ $B_inp); // XNOR Logic...
  
   //...
   
   // Assert these to end simulation (before the cycle limit).
   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
\SV
   endmodule

// Ref: https://www.makerchip.com/sandbox/0KrfqhowY/0Q1hkpn#
