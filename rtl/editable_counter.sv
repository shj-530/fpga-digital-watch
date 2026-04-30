`timescale 1ns / 1ps
module editable_counter #(
    parameter int N = 60,
    parameter int WIDTH = 6
) (
    input logic clk,
    input logic tick,  //count increments on tick when edit_mode is low
    input logic edit_mode,
    input logic inc,  //count increments on inc when edit_mode is high
    input logic dec,  //count decrements on dec when edit_mode is high
    output logic [WIDTH - 1:0] count
);
  logic enable;
  logic up;
  up_down_counter #(
      .MAX  (N - 1),
      .WIDTH(WIDTH)
  ) u_counter (
      .clk(clk),
      .enable(enable),
      .up(up),
      .count(count)
  );
  wire inc_event = edit_mode && inc && !dec;
  wire dec_event = edit_mode && dec && !inc;
  wire tick_event = !edit_mode && tick;
  assign up = inc_event ? 1'b1 : dec_event ? 1'b0 : tick_event ? 1'b1 : 1'b0;
  assign enable = (inc_event || dec_event || tick_event) && !(inc_event && dec_event);
endmodule
