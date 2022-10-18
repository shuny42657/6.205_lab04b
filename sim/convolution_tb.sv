`timescale 1ns / 1ps
`default_nettype none

module convolution_tb;
  logic clk;
  logic rst;

  logic [2:0][15:0] data;
  logic [10:0] hcount_in, hcount_out;
  logic [9:0] vcount_in, vcount_out;
  logic data_valid_in, data_valid_out;
  logic [15:0] line_out;

  logic [4:0] r;
  logic [5:0] g;
  logic [4:0] b;

  assign r = line_out[15:11];
  assign g = line_out[10:5];
  assign b = line_out[4:0];

  parameter K_SELECT = 0;

  /* A quick note about this simulation! Most waveform viewers
   * (including GTKWave) don't display arrays in their output
   * unless the array is packed along all dimensions. This is
   * to prevent the amount of data GTKWave has to render from 
   * getting too large, but it also means you'll have to use
   * $display statements to read out from your arrays.
  */

  convolution #(
    .K_SELECT(K_SELECT)
    ) uut (
    .clk_in(clk),
    .rst_in(rst),
    .data_in(data),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .data_valid_in(data_valid_in),

    .data_valid_out(data_valid_out),
    .hcount_out(hcount_out),
    .vcount_out(vcount_out),
    .line_out(line_out));

  always begin
    #5;
    clk = !clk;
  end

  initial begin
    $dumpfile("convolution.vcd");
    $dumpvars(0, convolution_tb);
    $display("Starting Sim");
    clk = 0;
    rst = 0;
    #10;
    rst = 1;
    #10;
    rst = 0;

    $display("Test 1: {test description}");
    data_valid_in = 1;
    data[0] = {5'd0, 6'd0, 5'd0};
    data[1] = {5'd0, 6'd0, 5'd0};
    data[2] = {5'd0, 6'd0, 5'd0};
    hcount_in = 0;
    vcount_in = 5;
    #10;
    data[0] = {5'd0, 6'd0, 5'd0};
    data[1] = {5'd0, 6'd0, 5'd0};
    data[2] = {5'd0, 6'd0, 5'd0};
    hcount_in = 1;
    vcount_in = 5;
    #10;
    data[0] = {5'd0, 6'd0, 5'd0};
    data[1] = {5'd0, 6'd0, 5'd0};
    data[2] = {5'd0, 6'd0, 5'd0};
    hcount_in = 2;
    vcount_in = 5;
    #10;
    data_valid_in = 0;
    #45;
    data_valid_in = 1;
    data[0] = {5'd1,6'd1,5'd1};
    data[1] = {5'd1,6'd1,5'd1};
    data[2] = {5'd1,6'd1,5'd1};
    hcount_in = 3;
    vcount_in = 5;
    #10;
    data_valid_in = 0;
    data[0] = {5'd2,6'd2,5'd2};
    data[1] = {5'd2,6'd2,5'd2};
    data[2] = {5'd2,6'd2,5'd2};
    hcount_in = 4;
    vcount_in = 5;
    #10
    data_valid_in = 1;
    data[0] = {5'd3,6'd3,5'd3};
    data[1] = {5'd3,6'd3,5'd3};
    data[2] = {5'd3,6'd3,5'd3};
    hcount_in = 5;
    vcount_in = 5;
    #50;
    data_valid_in = 0;
    $display("line_out: (unsigned): %h", line_out);
    $display("RGB: %3d %3d %3d", r, g, b);
    #20;

    $display("Finishing Sim");
    $finish;
  end
endmodule // convolution_tb

`default_nettype wire
