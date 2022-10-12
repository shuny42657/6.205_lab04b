`timescale 1ns / 1ps
`default_nettype none


module buffer (
    input wire clk_in, //system clock
    input wire rst_in, //system reset

    input wire [10:0] hcount_in, //current hcount being read
    input wire [9:0] vcount_in, //current vcount being read
    input wire [15:0] pixel_data_in, //incoming pixel
    input wire data_valid_in, //incoming  valid data signal

    output logic [2:0][15:0] line_buffer_out, //output pixels of data (blah make this packed)
    output logic [10:0] hcount_out, //current hcount being read
    output logic [9:0] vcount_out, //current vcount being read
    output logic data_valid_out //valid data out signal
  );

  // Your code here!

  xilinx_true_dual_port_read_first_1_clock_ram #(3,320,"HIGH_PERFORMANCE","") bram1();
  xilinx_true_dual_port_read_first_1_clock_ram #(3,320,"HIGH_PERFORMANCE","") bram2();
  xilinx_true_dual_port_read_first_1_clock_ram #(3,320,"HIGH_PERFORMANCE","") bram3();
  xilinx_true_dual_port_read_first_1_clock_ram #(3,320,"HIGH_PERFORMANCE","") bram4();

  logic [$clog2(240*320):0] addr_upper,addr_middle,addr_lower,addr_next; 
  logic [15:0]bram1_out,bram2_out,bram3_out,bram4_out;

  assign addr_upper = 
  always_ff @(posedge clk_in)begin
	  if(rst_in)begin

	  end
	  if(data_valid_in)begin
		  line_buffer_out[0] <= bram1_out;
		  line_buffer_out[1] <= bram2_out;
		  line_buffer_out[2] <= bram3_out;
		  hcount_out <= hcount_in;
		  vcount_out <= vcount_in;
		  data_valid_out <= 1;
	  end else begin
		  data_valid_out <= 0;
	  end

  end
  

endmodule


`default_nettype wire
