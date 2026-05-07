`timescale 1ns / 1ps

module stopwatch_control (
    input  logic clk,
    input  logic rise_start_stop,
    input  logic rise_lap,
    output logic counter_rst,
    output logic counter_enable,
    output logic lap_hold
);

  // Initial values for the state/outputs
  initial {counter_rst, counter_enable, lap_hold} = 3'b000;

  // Internal "next" signals
  logic next_counter_rst, next_counter_enable, next_lap_hold;

  // Rule: Simultaneous presses are ignored
  logic ignore = rise_start_stop && rise_lap;
  logic only_ss = rise_start_stop && !ignore;
  logic only_lap = rise_lap && !ignore;

  // BLOCK 1 (Assign): counter_enable toggle
  assign next_counter_enable = only_ss ? !counter_enable : counter_enable;

  // BLOCK 2 (Assign): counter_rst single-cycle pulse
  // Assert reset only if stopped AND display is live
  assign next_counter_rst = only_lap && !counter_enable && !lap_hold;

  always_comb begin
    next_lap_hold = lap_hold;  // Default: keep state
    if (only_lap) begin
      if (counter_enable) begin
        next_lap_hold = !lap_hold;  // Toggle freeze while running
      end else begin
        next_lap_hold = 1'b0;  // Always unfreeze if stopped[cite: 1]
      end
    end
  end

  always_ff @(posedge clk) begin
    counter_rst    <= next_counter_rst;
    counter_enable <= next_counter_enable;
    lap_hold       <= next_lap_hold;
  end

endmodule
