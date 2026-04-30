`timescale 1ns / 1ps
module button_hold_detect #(
    parameter int HOLD_CYCLES = 50_000_000  // clock cycles to consider a hold
) (
    input logic clk,  // system clock
    input logic button,  // raw button input (active high)
    output logic held  // goes high when button is held for HOLD_CYCLES
);
  localparam int CountMax = HOLD_CYCLES;
  localparam int CountWidth = $clog2(CountMax + 1);

  logic count_rst;  // reset count when button is released
  logic count_enable;  // enable counting when button is pressed
  logic [CountWidth-1:0] count;  // current count value
  mod_n_counter #(
      .N(CountMax + 1),
      .WIDTH(CountWidth)
  ) u_counter (
      .clk(clk),
      .rst(count_rst),
      .enable(count_enable),
      .count(count)
  );

  // Combinational logic for counter control
  // Reset the counter immediately if the button is released
  assign count_rst = !button;

  // Enable the counter if the button is pressed,
  // but stop once 'held' is high to freeze the count.
  assign count_enable = button && !held;

  // The output 'held' is a function of the current state (the count)
  assign held = (count == CountWidth'(CountMax));
endmodule
