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
  xilinx_true_dual_port_read_first_1_clock_ram #(16,320,"HIGH_PERFORMANCE","") bram1(.addra(hcount_in),.addrb(),.dina(pixel_data_in),.dinb(3'b0),.clka(clk_in),.wea(actually_write_in[3]),.web(1'b0),.ena(1'b1),.enb(1'b1),.rsta(rst_in),.rstb(rst_in),.regcea(1'b1),.regceb(1'b0),.douta(bram1_out),.doutb(bram1_b));
  xilinx_true_dual_port_read_first_1_clock_ram #(16,320,"HIGH_PERFORMANCE","") bram2(.addra(hcount_in),.addrb(),.dina(pixel_data_in),.dinb(3'b0),.clka(clk_in),.wea(actually_write_in[2]),.web(1'b0),.ena(1'b1),.enb(1'b1),.rsta(rst_in),.rstb(rst_in),.regcea(1'b1),.regceb(1'b0),.douta(bram2_out),.doutb(bram2_b));
  xilinx_true_dual_port_read_first_1_clock_ram #(16,320,"HIGH_PERFORMANCE","") bram3(.addra(hcount_in),.addrb(),.dina(pixel_data_in),.dinb(3'b0),.clka(clk_in),.wea(actually_write_in[1]),.web(1'b0),.ena(1'b1),.enb(1'b1),.rsta(rst_in),.rstb(rst_in),.regcea(1'b1),.regceb(1'b0),.douta(bram3_out),.doutb(bram3_b));
  xilinx_true_dual_port_read_first_1_clock_ram #(16,320,"HIGH_PERFORMANCE","") bram4(.addra(hcount_in),.addrb(),.dina(pixel_data_in),.dinb(3'b0),.clka(clk_in),.wea(actually_write_in[0]),.web(1'b0),.ena(1'b1),.enb(1'b1),.rsta(rst_in),.rstb(rst_in),.regcea(1'b1),.regceb(1'b0),.douta(bram4_out),.doutb(bram4_b));

  logic [8:0] addr1,addr2,addr3,addr4; 
  logic [15:0]bram1_out,bram2_out,bram3_out,bram4_out;
  logic [15:0]bram1_b,bram2_b,bram3_b,bram4_b;
  logic [3:0] write_in;
  logic [3:0] actually_write_in;
  logic [1:0] data_valid_out_pipe;
  logic [10:0] hcount_pipe[1:0];
  logic [9:0] vcount_pipe[1:0];
  logic [15:0]bram1_pipe,bram2_pipe,bram3_pipe,bram4_pipe;

  assign actually_write_in[0] = write_in[0] && data_valid_in;
  assign actually_write_in[1] = write_in[1] && data_valid_in;
  assign actually_write_in[2] = write_in[2] && data_valid_in;
  assign actually_write_in[3] = write_in[3] && data_valid_in;

  always_ff @(posedge clk_in)begin
	  data_valid_out_pipe[0] <= data_valid_in;
	  data_valid_out_pipe[1] <= data_valid_out_pipe[0];
	  data_valid_out <= data_valid_out_pipe[1];
          hcount_pipe[0] <= hcount_in;
	  //vcount_pipe[0] <= vcount_in;
	  vcount_pipe[0] <= vcount_in < 2 ? vcount_in + 240 - 2:vcount_in-2;
	  hcount_pipe[1] <= hcount_pipe[0];
	  hcount_out <= hcount_pipe[1];
	  vcount_pipe[1] <= vcount_pipe[0];
	  vcount_out <= vcount_pipe[1];
  end

  always_ff @(posedge clk_in)begin
	  if(rst_in)begin
		  //data_valid_out <= 0;
		  write_in <= 4'b1000;
	  end
		  case(write_in)
			  4'b1000:begin
				  //writing to bram1
				  bram4_pipe <= bram4_out;
				  bram3_pipe <= bram3_out;
				  bram2_pipe <= bram2_out;
				  line_buffer_out[2] <= bram4_pipe;
				  line_buffer_out[1] <= bram3_pipe;
				  line_buffer_out[0] <= bram2_pipe;
			  end
			  4'b0001:begin
				  //writing to bram4
				  bram3_pipe <= bram3_out;
				  bram2_pipe <= bram2_out;
				  bram1_pipe <= bram1_out;
				  line_buffer_out[2] <= bram3_pipe;
				  line_buffer_out[1] <= bram2_pipe;
				  line_buffer_out[0] <= bram1_pipe;
			  end
			  4'b0010:begin
				  //writing to bram3
				  bram2_pipe <= bram2_out;
				  bram1_pipe <= bram1_out;
				  bram4_pipe <= bram4_out;
				  line_buffer_out[2] <= bram2_pipe;
				  line_buffer_out[1] <= bram1_pipe;
				  line_buffer_out[0] <= bram4_pipe;
			  end
			  4'b0100:begin
				  //writing to bram2
				  bram1_pipe <= bram1_out;
				  bram4_pipe <= bram4_out;
				  bram3_pipe <= bram3_out;
				  line_buffer_out[2] <= bram1_pipe;
				  line_buffer_out[1] <= bram4_pipe;
				  line_buffer_out[0] <= bram3_pipe;
			  end
		  endcase
	  if(hcount_in == 0 && data_valid_in)begin
		  write_in <= {write_in[2:0], write_in[3]};
	  end
  end
  

endmodule


`default_nettype wire
