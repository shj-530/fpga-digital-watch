`timescale 1ns / 1ps

module user_top_stopwatch_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic clk,
    /* verilator lint_off UNUSEDSIGNAL */
    input logic [3:0] button,
    input logic [9:0] sw,
    /* verilator lint_on UNUSEDSIGNAL */
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic blank_hours,
    output logic blank_minutes,
    output logic blank_seconds
);
  logic rise_ss, rise_lap;
  logic stop_rst, counter_enable, lap_hold;

  logic [6:0] count_mins, count_cents;
  logic [ 5:0] count_secs;

  logic [19:0] live_time;
  logic [19:0] new_time;
  rising_edge_detector u_ss (
      .clk(clk),
      .sig_in(button[0]),
      .rise(rise_ss)
  );
  rising_edge_detector u_lap (
      .clk(clk),
      .sig_in(button[1]),
      .rise(rise_lap)
  );

  stopwatch_control u_control (
      .clk(clk),
      .rise_start_stop(rise_ss),
      .rise_lap(rise_lap),
      .counter_rst(stop_rst),
      .counter_enable(counter_enable),
      .lap_hold(lap_hold)
  );
  stopwatch_counter #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_counter (
      .clk(clk),
      .rst(stop_rst),
      .enable(counter_enable),
      .minutes(count_mins),
      .seconds(count_secs),
      .centiseconds(count_cents)
  );
  assign live_time = {count_mins, count_secs, count_cents};
  snapshot_mux #(
      .WIDTH(20)
  ) u_mux (
      .clk(clk),
      .hold(lap_hold),
      .d(live_time),
      .q(new_time)
  );

  assign hours_disp = new_time[19:13];
  assign minutes_disp = {1'b0, new_time[12:7]};
  assign seconds_disp = new_time[6:0];

  assign led = 10'b0;
  assign {blank_hours, blank_minutes, blank_seconds} = 3'b000;

endmodule
