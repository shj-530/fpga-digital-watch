`timescale 1ns / 1ps
module editable_countdown #(
    parameter int MAX   = 59,
    parameter int WIDTH = 6
) (
    input logic clk,
    input logic clr,
    input logic tick,
    input logic edit_mode,
    input logic inc,
    input logic dec,
    output logic [WIDTH-1:0] count,
    output logic borrow_out
);
  logic enable;
  logic down;

  logic inc_event;
  logic dec_event;
  logic tick_event;

  up_down_counter_rst #(
      .MAX  (MAX),
      .WIDTH(WIDTH)
  ) u_counter (
      .clk(clk),
      .rst(clr),
      .enable(enable),
      .up(!down),
      .count(count)
  );
  always_comb begin
    // Define the conditions under which an event occurs
    inc_event = edit_mode && inc && !dec;
    dec_event = edit_mode && dec && !inc;
    tick_event = !edit_mode && tick;

    // Determine the direction (down)
    // We go down if it's a decrement or a standard tick
    down = dec_event || tick_event;

    enable = inc_event || dec_event || tick_event;
    if (!edit_mode && !clr && tick && (count == 0)) begin
      borrow_out = 1'b1;
    end else begin
      borrow_out = 1'b0;
    end
  end
endmodule

