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
   // Combinational Calculators for Addition, Subtraction, Multiplication
   // $reset = *reset;
   // Stimulus ......
   |calc
      @0
         // Stimulus for Calculator .....
         $reset = *reset;
         $op[1:0] = *cyc_cnt[1:0];
         $reset_zero[31:0] = 32'b0;
         $val2[31:0] = $rand2[3:0];
        
        // Stimulus for Free Runing Counter.......
         $inp1[0:0] = 1;
         $inp2[0:0] = 0;
         // Summation of next state (feedback) and trigger input "1".....
         $sum_sq[3:0] = $inp1 + >>1$cnt[3:0];
   // Arithmetic Functions (Add, Subt, Mult and Div).....
   |calc
      @1
         $Add_out[31:0] = $val1_sq + $val2;
         $Sub_out[31:0] = $val1_sq - $val2;
         $Mul_out[31:0] = $val1_sq * $val2;
         $Div_out[31:0] = $val1_sq / $val2;
         // Mux (4x1) Operation.....
         $calc_out[31:0] = ($op == 00 & $reset == 0) ? $Add_out:
                          ($op == 01 & $reset == 0) ? $Sub_out:
                          ($op == 10 & $reset == 0) ? $Mul_out:
                          ($op == 10 & $reset == 0) ? $Div_out:
                          $reset_zero;
         $val1_sq[31:0] = & $calc_out;
                 
         // Free Runing Counter Mux (2x1) Operation ......
         $cnt[3:0] = ($reset == 1) ? $inp2:
                                     $sum_sq;
         //
   //...
   // Assert these to end simulation (before the cycle limit).
   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
\SV
   endmodule

// Ref: https://www.makerchip.com/sandbox/0qxfOhqWZ/0nZh7NW#

