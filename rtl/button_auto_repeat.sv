`timescale 1ns / 1ps
module button_auto_repeat #(
    parameter int HOLD_CYCLES   = 50_000_000,  // cycles to hold before first pulse
    parameter int REPEAT_CYCLES = 5_000_000    // cycles between repeat pulses
) (
    input logic clk,  // system clock
    input logic button,  // raw button signal
    output logic pulse  // single pulse on press + auto-repeat pulses
);
  logic rise;  // one-cycle pulse on rising edge of button
  logic held;  // asserted after button is held for HOLD_CYCLES
  logic pulse_train;  // periodic pulses while held

  assign pulse = rise | (button & pulse_train);  // combine immediate press and repeats
  //rise is high for one cycle when button is pressed.
  rising_edge_detector u_rise (
      .clk(clk),
      .sig_in(button),
      .rise(rise)
  );
  //when button stays high for HOLD_CYCLES - REPEAT_CYCLES+1,
  //held goes high and stays high until button is released.
  button_hold_detect #(
      .HOLD_CYCLES(HOLD_CYCLES-REPEAT_CYCLES+1)  // first pulse after HOLD_CYCLES, then every REPEAT_CYCLES
  ) u_hold (
      .clk(clk),
      .button(button),
      .held(held)
  );
  //generate a pulse when held every REPEAT_CYCLES.
  restartable_rate_generator #(
      .CYCLE_COUNT(REPEAT_CYCLES)
  ) u_repeat (
      .clk (clk),
      .run (held),
      .tick(pulse_train)
  );

endmodule
