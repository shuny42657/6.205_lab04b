`timescale 1ns / 1ps
`default_nettype none

module center_of_mass (
                         input wire clk_in,
                         input wire rst_in,
                         input wire [10:0] x_in,
                         input wire [9:0]  y_in,
                         input wire valid_in,
                         input wire tabulate_in,
                         output logic [10:0] x_out,
                         output logic [9:0] y_out,
                         output logic valid_out);

  //your design here!
  logic can_divide;
  logic [$clog2(1024*700):0] count;
  logic [32:0] x_acc;
  logic [32:0] y_acc;
  logic [10:0] x_avg;
  logic [9:0] y_avg;
  logic x_error_out,y_error_out;
  logic x_busy_out,y_busy_out;
  logic x_valid_out,y_valid_out;
  logic x_remainder_out,y_remainder_out;
  logic old_x_busy_out,old_y_busy_out;
  logic detect_falling_x,detect_falling_y;
  logic old_valid_out;
  divider #(33) x_div(.clk_in(clk_in),.rst_in(rst_in),.dividend_in(x_acc),.divisor_in(count),.data_valid_in(can_divide),.quotient_out(x_avg),.remainder_out(x_remainder_out),.data_valid_out(x_valid_out),.error_out(x_error_out),.busy_out(x_busy_out));
  divider #(33) y_div(.clk_in(clk_in),.rst_in(rst_in),.dividend_in(y_acc),.divisor_in(count),.data_valid_in(can_divide),.quotient_out(y_avg),.remainder_out(y_remainder_out),.data_valid_out(y_valid_out),.error_out(y_error_out),.busy_out(y_busy_out));
  always_ff @(posedge clk_in)begin
          if(rst_in)begin
                  valid_out <= 0;
                  x_acc <= 0;
                  y_acc <= 0;
                  count <= 0;
          end

          if(valid_in)begin
		  x_acc <= x_acc + x_in;
                  y_acc <= y_acc + y_in;
		  count <= count + 1;
          end
	  if(tabulate_in)begin
		  can_divide <= ~(count == 0);
	  end else begin
		  can_divide <= 0;
	  end

	  if(~x_busy_out && old_x_busy_out)begin
		  detect_falling_x <= 1;
	  end
	  if(~y_busy_out && old_y_busy_out)begin
		  detect_falling_y <= 1;
	  end
	  if(detect_falling_x && detect_falling_y)begin
		  if(x_error_out | y_error_out)begin
			  x_acc <= 0;
			  y_acc <= 0;
			  count <= 0;
			  detect_falling_x <= 0;
			  detect_falling_y <= 0;
		  end else begin
		  	x_acc <= 0;
		  	y_acc <= 0;
		  	count <= 0;
		  	x_out <= x_avg;
		  	y_out <= y_avg;
		  	detect_falling_x <= 0;
		  	detect_falling_y <= 0;
		  	valid_out <= 1;
		end
	  end
	  if(old_valid_out == 1)begin
		  valid_out <= 0;
	  end
	  old_x_busy_out <= x_busy_out;
	  old_y_busy_out <= y_busy_out;
	  old_valid_out <= valid_out;
  end

endmodule

`default_nettype wire
