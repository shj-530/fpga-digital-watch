`timescale 1ns / 1ps
// Rising edge detector: produces a single-cycle pulse when the input signal transitions from low to high.
module rising_edge_detector (
    input logic clk,  // system clock
    input logic sig_in,  // input signal to detect rising edge on
    output logic rise  //asserted immediately when sig_in transitions from 0 to 1, otherwise 0
);
  logic prev_rise;  // prev_rise tracks the previous value of sig_in to detect rising edges.
  assign rise = sig_in && !prev_rise;  // rise is high if sig_in is high and it was not high in the previous cycle
  always_ff @(posedge clk) begin
    prev_rise <= sig_in;  // update the previous value of sig_in
  end
endmodule
