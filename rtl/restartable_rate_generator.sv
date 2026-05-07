`timescale 1ns / 1ps
module restartable_rate_generator #(
    parameter int CYCLE_COUNT = 2  // clock cycles per tick
) (
    input  logic clk,  // system clock
    input  logic run,  // when high, the generator runs
    output logic tick  // single-cycle pulse every CYCLE_COUNT cycles
);
  // Overall: produces a periodic tick that resets when run deasserts.
  logic tick_qualifier;  // asserted when counter reaches terminal count

  logic running;  // delayed run to align tick with counter output
  always_ff @(posedge clk) running <= run;
  assign tick = running && tick_qualifier;

  generate
    if (CYCLE_COUNT > 1) begin : g_general
      localparam int CountWidth = $clog2(CYCLE_COUNT);
      logic rst_count;
      logic enable_count;
      logic [CountWidth-1:0] count;

      mod_n_counter #(
          .N(CYCLE_COUNT),
          .WIDTH(CountWidth)
      ) u_count (
          .clk(clk),
          .rst(rst_count),
          .enable(enable_count),
          .count(count)
      );

      assign rst_count = !run;
      assign enable_count = run;
      assign tick_qualifier = (count == CountWidth'(CYCLE_COUNT - 1));
    end else begin : g_special
      assign tick_qualifier = 1'b1;
    end
  endgenerate
endmodule
