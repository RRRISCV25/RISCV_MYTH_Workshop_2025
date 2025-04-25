\m5_TLV_version 1d: tl-x.org
// \m5
   
   // ============================================
   // Welcome, new visitors! Try the "Learn" menu.
   // ============================================
   
   //use(m5-1.0)   /// uncomment to use M5 macro library.
\SV
   // Macro providing required top-level module definition, random
   // stimulus support, and Verilator config.
 //`include "sqrt32.v";
   `include "sqrt32.v";
   m4_include_lib(https://raw.githubusercontent.com/stevehoover/makerchip_examples/refs/master/pythagoras_viz.tlv)
   
   m5_makerchip_module   // (Expanded in Nav-TLV pane.)
\TLV
   // Pythagoras Theorem TLV code......
   
   // Stimulus....
   // $reset = *reset;....
   |calc
      @0
         $valid = & $rand_valid[1:0];
         
   |calc
      ?$valid
      @1
         $aa_sq[7:0] = $aa[3:0] ** 2;  // $aa_sq[7:0] = $aa[3:0] * $aa[3:0];
         $bb_sq[7:0] = $bb[3:0] ** 2;  // $bb_sq[7:0] = $bb[3:0] * $bb[3:0];
      @2
         $cc_sq[8:0] = $aa_sq + $bb_sq;
      @3
         $cc[4:0] = sqrt($cc_sq);
            
   //...
   
   // Assert these to end simulation (before the cycle limit).
   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
        m5+pythagorean_viz_and_log(1)
\SV
   endmodule


// Ref: https://www.makerchip.com/sandbox/0qxfOhqWZ/076hA1j#
