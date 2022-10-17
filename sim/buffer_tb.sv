`timescale 1ns / 1ps
`default_nettype none

module buffer_tb;
  logic clk;
  logic rst;

  logic [10:0] hcount_in, hcount_out;
  logic [9:0] vcount_in, vcount_out;
  logic data_valid_in, data_valid_out;
  logic [15:0] pixel_data_in;
  logic [2:0][15:0] line_buffer_out; //make this 2D packed

  /* A quick note about this simulation! Most waveform viewers
   * (including GTKWave) don't display arrays in their output
   * unless the array is packed along all dimensions. This is
   * to prevent the amount of data GTKWave has to render from 
   * getting too large, but it also means you'll have to use
   * $display statements to read out from your arrays.
  */

  buffer uut (
    .clk_in(clk),
    .rst_in(rst),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .pixel_data_in(pixel_data_in),
    .data_valid_in(data_valid_in),

    .line_buffer_out(line_buffer_out),
    .hcount_out(hcount_out),
    .vcount_out(vcount_out),
    .data_valid_out(data_valid_out));

  always begin
    #5;
    clk = !clk;
  end

  initial begin
    $dumpfile("buffer.vcd");
    $dumpvars(0, buffer_tb);
    $display("Starting Sim");
    clk = 0;
    rst = 0;
    #5;
    rst = 1;
    #10;
    rst = 0;
    data_valid_in = 1;
    #10
    // Your code here!
    for(int i = 1;i<6;i+=1)begin
	    for(int j = 0;j<320;j+=1)begin
		    hcount_in = j;
		    vcount_in = i;
		    pixel_data_in = j+320*i;
		    #10;
	    end
    end
    data_valid_in = 1;
    #10;
    data_valid_in = 0;
    for (int i = 1;i < 6;i+=1)begin
	    for(int j = 0;j<320;j+=1)begin
		    hcount_in = j;
		    vcount_in = i;
		    pixel_data_in = j+320*i;
		    #10;
	    end
    end

    $display("Finishing Sim");
    $finish;
  end
endmodule //buffer_tb

`default_nettype wire
