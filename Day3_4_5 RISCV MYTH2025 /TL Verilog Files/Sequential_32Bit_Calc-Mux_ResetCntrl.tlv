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
   // Stimulus for Sequential Calculator with reset...
   $reset = *reset;
   $op[1:0] = *cyc_cnt[1:0];
   // $val1[31:0] = 32'b0000;
   $val2[31:0] = $ran1[3:0];
   $reset_state[31:0] = 32'b0;
   
   
   // Previous State is Feedback for First Input to Perfrom Calculations.....
   $val1[31:0] = >>1$calc_out;
   
   // Arithmetic Functions (ADD, SUB, MUL & DIV)....
   $sum[31:0] = $val1 + $val2;
   $diff[31:0] = $val1 - $val2;
   $mul[31:0] = $val1 * $val2;
   $div[31:0] = $val1 / $val2;
   
   // Mux (4x1) Function to Produce Calc Output (ADD, SUB, MUL & DIV) ....
   $calc_out[31:0] = ($op == 00 & $reset ==0) ? $sum:
                     ($op == 01 & $reset ==0) ? $diff:
                     ($op == 10 & $reset ==0) ? $mul:
                     ($op == 11 & $reset ==0) ? $div:                  
                     $reset_state;
                     
   // $calc_out[31:0] = $reset ? 1
                     // $reset_state:
                     // $calc_out;
   
   //...
   
   // Assert these to end simulation (before the cycle limit).
   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
\SV
   endmodule

// Ref: https://www.makerchip.com/sandbox/0PNf4hBRp/0X6hXoM#


