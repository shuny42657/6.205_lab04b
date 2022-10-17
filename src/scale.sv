`timescale 1ns / 1ps
`default_nettype none

module scale(
  input wire [1:0] scale_in,
  input wire [10:0] hcount_in,
  input wire [9:0] vcount_in,
  input wire [15:0] frame_buff_in,
  output logic [15:0] cam_out
);
  //YOUR DESIGN HERE!
  logic [10:0] border_x;
  logic [9:0] border_y;
  logic is_in_border;
  always_comb begin
	  case(scale_in)
		  2'b00: begin
			  border_x = 240-1;
			  border_y = 320-1;
		  end
		  2'b01: begin
			  border_x = 480-1;
			  border_y = 640-1;
		  end
		  2'b10: begin
			  border_x = 640-1;
			  border_y = 853-1;
		  end
		  2'b11: begin
			  border_x = 600-1;
			  border_y = 800-1;
		  end
	  endcase
	  is_in_border = (hcount_in <= border_x && vcount_in <= border_y);
	  cam_out = is_in_border? frame_buff_in : 16'h0000;
  end
endmodule


`default_nettype wire
