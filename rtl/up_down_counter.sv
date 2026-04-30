`timescale 1ns / 1ps
module up_down_counter #(
    parameter int MAX   = 2,  // maximum count value before wrap
    parameter int WIDTH = 2   // bit width of the count output
) (
    input logic clk,  // system clock
    input logic enable,  // enable counting when high
    input logic up,  // 1=count up, 0=count down
    output logic [WIDTH-1:0] count  // current count value
);
  // Overall: up/down counter with wrap at 0 and MAX.
  localparam logic [WIDTH-1:0] Max = WIDTH'(MAX);
  initial count = WIDTH'(0);
  logic [WIDTH-1:0] next_count;  // next count value
  always_ff @(posedge clk) if (enable) count <= next_count;

  always_comb begin
    if (up) begin
      next_count = (count >= Max) ? WIDTH'(0) : count + WIDTH'(1);
    end else begin
      next_count = (count == WIDTH'(0)) ? Max : count - WIDTH'(1);
    end
  end
endmodule
