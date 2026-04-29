`timescale 1ns / 1ps
module mod_n_counter #(
    parameter int N = 4,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [WIDTH-1:0] count
);
  localparam logic [WIDTH-1:0] Max = WIDTH'(N - 1);
  initial count = WIDTH'(0);
  logic [WIDTH-1:0] next_count;
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
