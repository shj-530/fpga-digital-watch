`timescale 1ns / 1ps
module top_time_display_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic CLOCK_50,
    input logic [1:0] SW,
    output logic [6:0] HEX0,
    output logic [6:0] HEX1,
    output logic [6:0] HEX2,
    output logic [6:0] HEX3,
    output logic [6:0] HEX4,
    output logic [6:0] HEX5
);

  localparam int Cycles1Hz = CYCLES_PER_SECOND;  //cycles= system frequency / desired frequency
  localparam int Cycles25Hz = CYCLES_PER_SECOND / 25;
  localparam int Cycles1KHz = CYCLES_PER_SECOND / 1_000;
  logic [4:0] hours;
  logic [5:0] minutes, seconds;
  logic tick_1hz, tick_25hz, tick_1khz, hms_enable;
  logic [3:0] second_one, second_ten, minute_one, minute_ten, hour_one, hour_ten;
  hms_counter u_hms (
      .clk(CLOCK_50),
      .enable(hms_enable),
      .hours(hours),
      .minutes(minutes),
      .seconds(seconds)
  );
  restartable_rate_generator #(
      .CYCLE_COUNT(Cycles1Hz)
  ) u_gen_1hz (
      .clk (CLOCK_50),
      .run (1'b1),
      .tick(tick_1hz)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(Cycles25Hz)
  ) u_gen_25hz (
      .clk (CLOCK_50),
      .run (1'b1),
      .tick(tick_25hz)
  );
  restartable_rate_generator #(
      .CYCLE_COUNT(Cycles1KHz)
  ) u_gen_1khz (
      .clk (CLOCK_50),
      .run (1'b1),
      .tick(tick_1khz)
  );

  always_comb begin
    unique case (SW)
      2'b00: hms_enable = tick_1hz;  // 1Hz
      2'b01: hms_enable = tick_25hz;  // 25Hz
      2'b10: hms_enable = tick_1khz;  // 1kHz
      2'b11: hms_enable = 1'b1;  // default to tick 50Mhz
    endcase
  end

  binary_to_bcd u_hour (
      .bin ({2'b0, hours}),
      .tens(hour_ten),
      .ones(hour_one)
  );
  binary_to_bcd u_minute (
      .bin ({1'b0, minutes}),
      .tens(minute_ten),
      .ones(minute_one)
  );
  binary_to_bcd u_second (
      .bin ({1'b0, seconds}),
      .tens(second_ten),
      .ones(second_one)
  );
  seven_segment u_display0 (
      .digit(second_one),
      .blank(1'b0),
      .segments(HEX0)
  );
  seven_segment u_display1 (
      .digit(second_ten),
      .blank(1'b0),
      .segments(HEX1)
  );
  seven_segment u_display2 (
      .digit(minute_one),
      .blank(1'b0),
      .segments(HEX2)
  );
  seven_segment u_display3 (
      .digit(minute_ten),
      .blank(1'b0),
      .segments(HEX3)
  );
  seven_segment u_display4 (
      .digit(hour_one),
      .blank(1'b0),
      .segments(HEX4)
  );
  seven_segment u_display5 (
      .digit(hour_ten),
      .blank(1'b0),
      .segments(HEX5)
  );
endmodule

