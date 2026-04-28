`timescale 1ns / 1ps
// Binary to Binary-Coded Decimal (BCD) converter.
//
// Ports:
//   bin [6:0]   Binary input (range 0-99).
//   tens [3:0]  Decimal tens digit in BCD.
//   ones [3:0]  Decimal ones digit in BCD.
module binary_to_bcd (
    input  logic [6:0] bin,
    output logic [3:0] tens,
    output logic [3:0] ones
);

  // corresponding width for ttens and ones and 7 bits for bin
  assign tens = 4'(bin / 7'd10);
  assign ones = 4'(bin % 7'd10);
endmodule
