`timescale 1ns / 1ps
module user_top_timer_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
`ifdef FORMAL
    output logic probe_running,
    output logic [2:0] probe_mode_enable,
`endif
    input logic clk,
    /* verilator lint_off UNUSED */
    input logic [3:0] button,
    input logic [9:0] sw,
    /* verilator lint_on UNUSED */
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic blank_hours,
    output logic blank_minutes,
    output logic blank_seconds
);
  logic running;
  logic [2:0] mode_enable;
  logic seconds_borrow, minutes_borrow;
  logic rst;
  logic seconds_edit;
  logic seconds_inc;
  logic seconds_dec;
  logic [5:0] seconds;
  logic zero;
  assign rst  = 1'b0;
  assign zero = (seconds == 0) && (minutes == 0) && (hours == 0);


  logic rise_start;
  rising_edge_detector u_start_stop (
      .clk(clk),
      .sig_in(button[0]),
      .rise(rise_start)
  );
  logic editing;
  assign editing = (mode_enable != 3'b000);

  initial running = 1'b0;
  always_ff @(posedge clk) begin
    if (editing) running <= 1'b0;
    else if (running && zero) running <= 1'b0;
    else if (rise_start && !zero) running <= !running;
  end

  logic tick_sec;
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_div (
      .clk (clk),
      .run (running),
      .tick(tick_sec)
  );

  // Gate the tick with the running register to prevent "leaked" ticks 
  // after the timer is stopped. This satisfies formal induction.
  logic gated_tick_sec;
  assign gated_tick_sec = tick_sec && running;

  editable_countdown #(
      .MAX  (59),
      .WIDTH(6)
  ) u_seconds (
      .clk(clk),
      .clr(rst),
      .tick(gated_tick_sec),
      .edit_mode(seconds_edit),
      .inc(seconds_inc),
      .dec(seconds_dec),
      .count(seconds),
      .borrow_out(seconds_borrow)
  );

  //Minutes
  logic minutes_edit;
  logic minutes_inc;
  logic minutes_dec;
  logic [5:0] minutes;
  editable_countdown #(
      .MAX  (59),
      .WIDTH(6)
  ) u_minutes (
      .clk(clk),
      .clr(rst),
      .tick(seconds_borrow),
      .edit_mode(minutes_edit),
      .inc(minutes_inc),
      .dec(minutes_dec),
      .count(minutes),
      .borrow_out(minutes_borrow)
  );

  // Hours
  logic hours_edit;
  logic hours_inc;
  logic hours_dec;
  logic [4:0] hours;
  editable_countdown #(
      .MAX  (23),
      .WIDTH(5)
  ) u_hours (
      .clk(clk),
      .clr(rst),
      .tick(minutes_borrow),
      .edit_mode(hours_edit),
      .inc(hours_inc),
      .dec(hours_dec),
      .count(hours),
      /* verilator lint_off PINCONNECTEMPTY */
      .borrow_out()
      /* verilator lint_on PINCONNECTEMPTY */
  );

  assign seconds_disp = {1'b0, seconds};
  assign minutes_disp = {1'b0, minutes};
  assign hours_disp = {2'b0, hours};

  assign led = 10'b0;

  // Edit Mode Selector (Long press button[3] to enter, short press to cycle)
  edit_mode_selector #(
      .HOLD_CYCLES(CYCLES_PER_SECOND)
  ) u_mode_selector (
      .clk(clk),
      .button(button[3] & !running),
      .mode_enable(mode_enable)
  );

  // Increment and Decrement Pulses (with auto-repeat)
  logic inc_pulse, dec_pulse;
  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)
  ) u_inc_repeat (
      .clk(clk),
      .button(button[1]),
      .pulse(inc_pulse)
  );

  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)
  ) u_dec_repeat (
      .clk(clk),
      .button(button[0]),
      .pulse(dec_pulse)
  );

  // PWM for flashing the display
  logic flash;
  pwm_generator #(
      .PERIOD_CYCLES(CYCLES_PER_SECOND / 2),
      .DUTY_CYCLES  (CYCLES_PER_SECOND / 2 * 4 / 5)  // 80% duty cycle
  ) u_pwm (
      .clk(clk),
      .rst(1'b0),
      .pwm_out(flash)
  );

  assign seconds_edit = mode_enable[0];
  assign minutes_edit = mode_enable[1];
  assign hours_edit = mode_enable[2];

  assign seconds_inc = seconds_edit && inc_pulse;
  assign minutes_inc = minutes_edit && inc_pulse;
  assign hours_inc = hours_edit && inc_pulse;

  assign seconds_dec = seconds_edit && dec_pulse;
  assign minutes_dec = minutes_edit && dec_pulse;
  assign hours_dec = hours_edit && dec_pulse;

  assign blank_seconds = !flash && seconds_edit;
  assign blank_minutes = !flash && minutes_edit;
  assign blank_hours = !flash && hours_edit;


`ifdef FORMAL
  assign probe_running = running;
  assign probe_mode_enable = mode_enable;
`endif
endmodule
