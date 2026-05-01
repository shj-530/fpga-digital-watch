`timescale 1ns / 1ps
// PWM generator: creates a fixed-period, fixed-duty PWM output.
module pwm_generator #(
    // Number of clock cycles in one PWM period.
    parameter int PERIOD_CYCLES = 50_000_000,
    // Number of clock cycles that the output stays high.
    parameter int DUTY_CYCLES   = 25_000_000
) (
    input logic clk,  // system clock
    input logic rst,  // synchronous reset
    output logic pwm_out  // PWM output signal
);
  localparam int Width = $clog2(PERIOD_CYCLES + 1);
  logic [Width-1:0] duty_cycle_count;  // current count of cycles in the PWM period
  assign pwm_out = duty_cycle_count < Width'(DUTY_CYCLES)?1'b1:1'b0;  // output high if count is less than duty cycles
  // Counter tracks the current cycle position in the PWM period.
  mod_n_counter #(
      .N(PERIOD_CYCLES),
      .WIDTH(Width)
  ) u_counter (
      .clk(clk),
      .rst(rst),
      .enable(1'b1),
      .count(duty_cycle_count)
  );
endmodule
