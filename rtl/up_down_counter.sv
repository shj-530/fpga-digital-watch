`timescale 1ns / 1ps
module up_down_counter #(
    parameter int MAX   = 2,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic enable,
    input logic up,
    output logic [WIDTH-1:0] count
);

  localparam logic [WIDTH-1:0] Max = WIDTH'(MAX);

  initial count = WIDTH'(0);
  logic [WIDTH-1:0] next_count;
  always_ff @(posedge clk) if (enable) count <= next_count;

  always_comb begin
    if (up) begin
      next_count = (count >= Max) ? WIDTH'(0) : count + WIDTH'(1);
    end else begin
      next_count = (count == WIDTH'(0)) ? Max : count - WIDTH'(1);
    end
  end
endmodule
