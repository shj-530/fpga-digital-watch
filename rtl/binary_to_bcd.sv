`timescale 1ns / 1ps
// Binary to Binary-Coded Decimal (BCD) converter.
// Overall: converts a 0-99 binary value into two BCD digits (tens/ones).
//
// Ports:
//   bin [6:0]   Binary input (range 0-99).
//   tens [3:0]  Decimal tens digit in BCD.
//   ones [3:0]  Decimal ones digit in BCD.
module binary_to_bcd (
    input  logic [6:0] bin,   // binary value to convert
    output logic [3:0] tens,  // BCD tens digit
    output logic [3:0] ones   // BCD ones digit
);

  // Extract BCD digits from the binary value.
  assign tens = 4'(bin / 7'd10);
  assign ones = 4'(bin % 7'd10);
endmodule
