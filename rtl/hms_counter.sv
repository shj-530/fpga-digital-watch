`timescale 1ns / 1ps
module hms_counter #(
    // Modulus for each time field.
    parameter int N_HOURS   = 24,
    parameter int N_MINUTES = 60,
    parameter int N_SECONDS = 60,

    // Bit widths for each counter output.
    parameter int W_HOURS   = 5,
    parameter int W_MINUTES = 6,
    parameter int W_SECONDS = 6
) (
    input logic clk,  // system clock
    input logic enable,  // tick enable for seconds
    output logic [W_HOURS-1:0] hours,  // hour count
    output logic [W_MINUTES-1:0] minutes,  // minute count
    output logic [W_SECONDS-1:0] seconds  // second count
);

  // Overall: cascaded counters for seconds, minutes, and hours.
  logic second_rollover;  // asserted when seconds roll over
  logic minute_rollover;  // asserted when minutes roll over

  // Max values for rollover detection.
  localparam logic [W_MINUTES-1:0] MaxMinutes = W_MINUTES'(N_MINUTES - 1);
  localparam logic [W_SECONDS-1:0] MaxSeconds = W_SECONDS'(N_SECONDS - 1);
  // Rollover logic for cascading counters.
  assign second_rollover = enable && (seconds == MaxSeconds);
  assign minute_rollover = second_rollover && (minutes == MaxMinutes);

  up_down_counter #(
      .MAX  (N_HOURS - 1),
      .WIDTH(W_HOURS)
  ) u_hour (
      .clk(clk),
      .enable(minute_rollover),
      .up(1'b1),  // hours always count up
      .count(hours)
  );

  up_down_counter #(
      .MAX  (N_MINUTES - 1),
      .WIDTH(W_MINUTES)
  ) u_minute (
      .clk(clk),
      .enable(second_rollover),
      .up(1'b1),  // minutes always count up
      .count(minutes)
  );

  up_down_counter #(
      .MAX  (N_SECONDS - 1),
      .WIDTH(W_SECONDS)
  ) u_second (
      .clk(clk),
      .enable(enable),
      .up(1'b1),  // seconds always count up
      .count(seconds)
  );
endmodule
