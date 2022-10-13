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

  xilinx_true_dual_port_read_first_1_clock_ram #(3,320,"HIGH_PERFORMANCE","") bram1(.addra(addr1),.addrb(addr1),.dina(0),.dinb(0),.clka(clk_in),.wea(write_in[3]),.web(0),.ena(1),.enb(0),.rsta(rst_in),.rstb(rst_in),.regcea(1),.regceb(0),.douta(bram1_out),.doutb(bram1_b));
  xilinx_true_dual_port_read_first_1_clock_ram #(3,320,"HIGH_PERFORMANCE","") bram2(.addra(addr2),.addrb(addr2),.dina(0),.dinb(0),.clka(clk_in),.wea(write_in[2]),.web(0),.ena(1),.enb(0),.rsta(rst_in),.rstb(rst_in),.regcea(1),.regceb(0),.douta(bram2_out),.doutb(bram2_b));
  xilinx_true_dual_port_read_first_1_clock_ram #(3,320,"HIGH_PERFORMANCE","") bram3(.addra(addr3),.addrb(addr3),.dina(0),.dinb(0),.clka(clk_in),.wea(write_in[1]),.web(0),.ena(1),.enb(0),.rsta(rst_in),.rstb(rst_in),.regcea(1),.regceb(0),.douta(bram3_out),.doutb(bram3_b));
  xilinx_true_dual_port_read_first_1_clock_ram #(3,320,"HIGH_PERFORMANCE","") bram4(.addra(addr4),.addrb(addr4),.dina(0),.dinb(0),.clka(clk_in),.wea(write_in[0]),.web(0),.ena(1),.enb(0),.rsta(rst_in),.rstb(rst_in),.regcea(1),.regceb(0),.douta(bram4_out),.doutb(bram4_b));

  logic [$clog2(240*320):0] addr1,addr2,addr3,addr4; 
  logic [15:0]bram1_out,bram2_out,bram3_out,bram4_out;
  logic [15:0]bram1_b,bram2_b,bram3_b,bram4_b;
  logic [3:0] write_in;
  logic [1:0] hcount_pipe,vcount_pipe,data_valid_out_pipe;

  assign addr1 = vcount_in; //(hcount,vcount)
  assign addr2 = vcount_in-1; //(hcount,vcount-1)
  assign addr3 = vcount_in-2; //(hcount,vcount-2)
  assign addr4 = vcount_in-3; //(hcount,vcount-3)
  always_ff @(posedge clk_in)begin
	  data_valid_out_pipe[0] <= data_valid_in;
	  data_valid_out_pipe[1] <= data_valid_out_pipe[0];
	  data_valid_out <= data_valid_out_pipe[1];
	  if (data_valid_in)begin
		  hcount_pipe[0] <= hcount_in;
		  vcount_pipe[0] <= vcount_in;
	  end
	  hcount_pipe[1] <= hcount_pipe[0];
	  hcount_out <= hcount_pipe[1];
	  vcount_pipe[1] <= vcount_pipe[0];
	  vcount_out <= vcount_pipe[1];
  end

  always_ff @(posedge clk_in)begin
	  if(rst_in)begin

	  end
	  if(data_valid_in)begin
		  line_buffer_out[0] <= bram1_out;
		  line_buffer_out[1] <= bram2_out;
		  line_buffer_out[2] <= bram3_out;
		  case(write_in)
			  4'b1000:begin
				  //writing to bram1
				  line_buffer_out[2] <= bram2_out[hcount_in];
				  line_buffer_out[1] <= bram3_out[hcount_in];
				  line_buffer_out[0] <= bram4_out[hcount_in];
			  end
			  4'b0100:begin
				  //writing to bram2
				  line_buffer_out[2] <= bram3_out[hcount_in];
				  line_buffer_out[1] <= bram4_out[hcount_in];
				  line_buffer_out[0] <= bram1_out[hcount_in];
			  end
			  4'b0010:begin
				  //writing to bram3
				  line_buffer_out[2] <= bram4_out[hcount_in];
				  line_buffer_out[1] <= bram1_out[hcount_in];
				  line_buffer_out[0] <= bram2_out[hcount_in];
			  end
			  4'b0001:begin
				  //writing to bram4
				  line_buffer_out[2] <= bram3_out[hcount_in];
				  line_buffer_out[1] <= bram2_out[hcount_in];
				  line_buffer_out[0] <= bram1_out[hcount_in];
			  end
		  endcase
		  if(hcount_in == 319)begin
			  for(int i  = 1;i<4;i+=1)begin
				  write_in[i] <= write_in[i-1];
			  end
			  write_in[0] <= write_in[1];
		  end

	  end else begin
		  data_valid_out <= 0;
	  end

  end
  

endmodule


`default_nettype wire
