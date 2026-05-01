`timescale 1ns / 1ps
module key_synchroniser (
    input logic clk,
    input logic [3:0] key_n,  //active low
    output logic [3:0] key_sync  //active high, synchronised
);
  logic [3:0] next_key = '0;
  logic [3:0] sync = '0;
  always_ff @(posedge clk) begin
    next_key <= ~key_n;
    sync <= next_key;
  end
  assign key_sync = sync;

endmodule
