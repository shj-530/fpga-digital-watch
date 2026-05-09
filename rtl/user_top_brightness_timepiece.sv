`timescale 1ns / 1ps

module user_top_brightness_timepiece #(
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

  // 1. Instantiate user_top (the Assignment 1 digital clock)
  logic inner_blank_h, inner_blank_m, inner_blank_s;

  user_top_timepiece_v1 #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_inner (
      .clk(clk),
      .button(button),
      .sw(sw),
      .led(led),
      .hours_disp(hours_disp),
      .minutes_disp(minutes_disp),
      .seconds_disp(seconds_disp),
      .blank_hours(inner_blank_h),
      .blank_minutes(inner_blank_m),
      .blank_seconds(inner_blank_s)
  );

  // 2. Instantiate mod_n_counter for the PWM logic (1 kHz)
  localparam int Pwmperiod = CYCLES_PER_SECOND / 1000;
  localparam int Pwmwidth = $clog2(Pwmperiod);
  logic [Pwmwidth-1:0] pwm_count;

  mod_n_counter #(
      .N(Pwmperiod),
      .WIDTH(Pwmwidth)
  ) u_pwm_counter (
      .clk(clk),
      .rst(1'b0),
      .enable(1'b1),
      .count(pwm_count)
  );

  // 3. Threshold Logic for sw[9:8]
  logic pwm_blank;
  always_comb begin
    case (sw[9:8])
      2'b00:   pwm_blank = (pwm_count >= (Pwmperiod / 8));  // 12.5% brightness
      2'b01:   pwm_blank = (pwm_count >= (Pwmperiod / 4));  // 25% brightness
      2'b11:   pwm_blank = (pwm_count >= (Pwmperiod / 2));  // 50% brightness
      2'b10:   pwm_blank = 1'b0;  // 100% brightness
      default: pwm_blank = 1'b0;
    endcase
  end

  // 4. Combine original blanking with PWM blanking
  assign blank_hours   = inner_blank_h | pwm_blank;
  assign blank_minutes = inner_blank_m | pwm_blank;
  assign blank_seconds = inner_blank_s | pwm_blank;

endmodule
