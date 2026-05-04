// ------------------------------------------------------------------
// WARNING: This file is used by the automated test suite. Do not
// modify it.
//
// This file also serves as a template for your own designs. To use
// it:
//   1. Copy the entire contents into a new file with a descriptive
//      name.
//   2. Delete the test logic below and replace it with your own
//      code.
//   3. In top_de1_soc, change the module name from user_top to your
//      new module name.
//
//   The board wrapper sets CYCLES_PER_SECOND; use this parameter in
//   your design wherever timing is needed.
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module user_top_watch_v4 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic clk,
    /* verilator lint_off UNUSED */
    input logic [3:0] button,
    input logic [9:0] sw,
    /* verilator lint_on UNUSED */
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic blank_hours,
    output logic blank_minutes,
    output logic blank_seconds
);
  // ------------------
  // Core Functionality
  // ------------------
  // Seconds
  logic seconds_tick;
  logic seconds_edit;
  logic seconds_inc;
  logic seconds_dec;
  logic [5:0] seconds;
  editable_counter #(
      .N(60),
      .WIDTH(6)
  ) u_seconds (
      .clk(clk),
      .tick(seconds_tick),
      .edit_mode(seconds_edit),
      .inc(seconds_inc),
      .dec(seconds_dec),
      .count(seconds)
  );

  //Minutes
  logic minutes_tick;
  logic minutes_edit;
  logic minutes_inc;
  logic minutes_dec;
  logic [5:0] minutes;
  editable_counter #(
      .N(60),
      .WIDTH(6)
  ) u_minutes (
      .clk(clk),
      .tick(minutes_tick),
      .edit_mode(minutes_edit),
      .inc(minutes_inc),
      .dec(minutes_dec),
      .count(minutes)
  );

  // Hours
  logic hours_tick;
  logic hours_edit;
  logic hours_inc;
  logic hours_dec;
  logic [4:0] hours;
  editable_counter #(
      .N(24),
      .WIDTH(5)
  ) u_hours (
      .clk(clk),
      .tick(hours_tick),
      .edit_mode(hours_edit),
      .inc(hours_inc),
      .dec(hours_dec),
      .count(hours)
  );

  //rising edge detector for v4//
  logic button_rise;
  rising_edge_detector u_button_rise (
      .clk(clk),
      .sig_in(button[3]),
      .rise(button_rise)
  );
  // Derive 1 Hz tick from system clock
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_divider_1_Hz (
      .clk (clk),
      .run (!(mode_enable[0] && button_rise)),
      .tick(seconds_tick)
  );

  assign seconds_edit = mode_enable[0];
  assign minutes_edit = mode_enable[1];
  assign hours_edit = mode_enable[2];

  assign seconds_inc = seconds_edit && inc_pulse;
  assign minutes_inc = minutes_edit && inc_pulse;
  assign hours_inc = hours_edit && inc_pulse;
  assign seconds_dec = seconds_edit && dec_pulse;
  assign minutes_dec = minutes_edit && dec_pulse;
  assign hours_dec = hours_edit && dec_pulse;

  assign minutes_tick = ((seconds == 6'd59) && seconds_tick && !mode_enable[0]) ? 1'b1 : 1'b0;
  assign hours_tick = ((minutes == 6'd59) && (seconds == 6'd59) && minutes_tick && !mode_enable[1]) ? 1'b1 : 1'b0;
  //Zero -extend counter values to display outputs
  assign hours_disp = {2'b0, hours};
  assign minutes_disp = {1'b0, minutes};
  assign seconds_disp = {1'b0, seconds};

  //unused
  assign led = 10'b0;

  // --------------
  // Mode Selection
  // --------------
  logic [2:0] mode_enable;
  logic out_blank;
  edit_mode_selector #(
      .HOLD_CYCLES(CYCLES_PER_SECOND)
  ) u_mode_selector (
      .clk(clk),
      .button(button[3]),
      .mode_enable(mode_enable)
  );
  pwm_generator #(
      .PERIOD_CYCLES(CYCLES_PER_SECOND / 2),  // 2 Hz PWM for visible blinking
      .DUTY_CYCLES(CYCLES_PER_SECOND / 2 * 1 / 5)  // 80% duty cycle
  ) u_pwm (
      .clk(clk),
      .rst(1'b0),
      .pwm_out(out_blank)
  );
  assign blank_hours   = out_blank & mode_enable[2];
  assign blank_minutes = out_blank & mode_enable[1];
  assign blank_seconds = out_blank & mode_enable[0];
  // --------------
  // Setting time
  // --------------
  logic inc_pulse, dec_pulse;
  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)
  ) u_seconds_inc (
      .clk(clk),
      .button(button[1]),  // Increment button
      .pulse(inc_pulse)
  );

  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)
  ) u_seconds_dec (
      .clk(clk),
      .button(button[0]),  // Decrement button
      .pulse(dec_pulse)
  );
endmodule
