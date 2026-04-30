`timescale 1ns / 1ps
module mod_n_counter #(
    parameter int N = 4,  // modulus of the counter
    parameter int WIDTH = 2  // bit width of the count output
) (
    input logic clk,  // system clock
    input logic rst,  // synchronous reset
    input logic enable,  // enable counting when high
    output logic [WIDTH-1:0] count  // current count value
);
  // Overall: counts 0..N-1 with synchronous reset and enable.
  localparam logic [WIDTH-1:0] Max = WIDTH'(N - 1);
  initial count = WIDTH'(0);
  logic [WIDTH-1:0] next_count;  // next count value
  always_comb begin
    if (enable) begin
      if (count == Max) next_count = WIDTH'(0);
      else next_count = count + WIDTH'(1);
    end else next_count = count;
  end

  always_ff @(posedge clk) begin
    if (rst) count <= WIDTH'(0);
    else if (enable) begin
      count <= next_count;
    end
  end
endmodule
