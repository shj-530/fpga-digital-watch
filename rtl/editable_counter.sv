`timescale 1ns / 1ps

module editable_counter #(
    parameter int N = 60,
    parameter int WIDTH = 6
) (
    input  logic               clk,
    input  logic               tick,       // count increments on tick when edit_mode is low
    input  logic               edit_mode,
    input  logic               inc,        // count increments on inc when edit_mode is high
    input  logic               dec,        // count decrements on dec when edit_mode is high
    output logic [WIDTH - 1:0] count
);

  logic enable;
  logic up;

  logic inc_event;
  logic dec_event;
  logic tick_event;

  // Wrapper for the actual sequential logic
  up_down_counter #(
      .MAX  (N - 1),
      .WIDTH(WIDTH)
  ) u_counter (
      .clk(clk),
      .enable(enable),
      .up(up),
      .count(count)
  );

  always_comb begin
    // Define the conditions under which an event occurs
    inc_event = edit_mode && inc && !dec;
    dec_event = edit_mode && dec && !inc;
    tick_event = !edit_mode && tick;

    // Determine the direction (up)
    // We go up if it's an increment or a standard tick
    up = inc_event || tick_event;

    // Determine if we should change the count at all (enable)
    // Change if any of our valid events are active
    enable = inc_event || dec_event || tick_event;
  end

endmodule
