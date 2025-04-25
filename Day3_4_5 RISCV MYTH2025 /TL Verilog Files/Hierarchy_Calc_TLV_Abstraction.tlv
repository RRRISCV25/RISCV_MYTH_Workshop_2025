\m4_TLV_version 1d: tl-x.org
\SV
   `include "sqrt32.v";
   m4_makerchip_module
\TLV

   |calc
      // 2-D Co-ordinates (XX-Co-ord & YY Co-ord to store the two similar datas or families).....
      
      // Pythagoras Theorem is Implemented using Hierarchi TL-Veliog Abstraction.....
     /coord[1:0]
         @1
            $sq[15:0] = $value[7:0] ** 2;
      @2
         $cc_sq[16:0] = /coord[0]$sq + /coord[1]$sq;
      @3
         $cc[7:0] = sqrt($cc_sq);
      // Print
      @3
         \SV_plus
            always_ff @(posedge clk) begin
               \$display("sqrt((\%2d ^ 2) + (\%2d ^ 2)) = %2d", /coord[0]$value, /coord[1]$value, $cc);
            end
\SV
endmodule


// Ref: https://www.makerchip.com/sandbox/0qxfOhqWZ/0xGh1oN#


