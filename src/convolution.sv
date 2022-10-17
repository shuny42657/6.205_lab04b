`timescale 1ns / 1ps
`default_nettype none

module convolution #(
    parameter K_SELECT=0)(
    input wire clk_in,
    input wire rst_in,
    input wire [2:0][15:0] data_in,
    input wire [10:0] hcount_in,
    input wire [9:0] vcount_in,
    input wire data_valid_in,

    output logic data_valid_out,
    output logic [10:0] hcount_out,
    output logic [9:0] vcount_out,
    output logic [15:0] line_out
    );

    logic signed [2:0][2:0][7:0] coffs;
    logic signed [7:0] shift;
    kernels #(.K_SELECT(K_SELECT)) convolution(.rst_in(rst_in),.coeffs(coffs),.shift(shift));

    logic signed [2:0][2:0][15:0] caches;
   
    logic [15:0] r_conv,g_conv,b_conv; 
    logic [4:0] r_out;
    logic [5:0] g_out;
    logic [4:0] b_out;

    // Your code here!

    /* Note that the coeffs output of the kernels module
     * is packed in all dimensions, so coeffs should be 
     * defined as `logic signed [2:0][2:0][7:0] coeffs`
     *
     * This is because iVerilog seems to be weird about passing 
     * signals between modules that are unpacked in more
     * than one dimension - even though this is perfectly
     * fine Verilog.
     */
    

    // always_ff @(posedge clk_in) begin
    //   // Make sure to have your output be set with registered logic!
    //   // Otherwise you'll have timing violations.
    //   line_out <= {r, g, 1'b0, b};
    // end
    //
    //
    logic [1:0] data_valid_pipe,hcount_pipe,vcount_pipe;

    always_ff @(posedge clk_in)begin
	    data_valid_pipe[0] <= data_valid_in;
	    data_valid_pipe[1] <= data_valid_pipe[0];
	    data_valid_out <= data_valid_pipe[1];
	    hcount_pipe[0] <= hcount_in;
	    hcount_pipe[1] <= hcount_pipe[0];
	    hcount_out <= hcount_pipe[1];
	    vcount_pipe[0] <= vcount_in;
	    vcount_pipe[1] <= vcount_pipe[0];
	    vcount_out <= vcount_pipe[1];
    end
    always_comb begin
	    r_conv = 0;
	    g_conv = 0;
	    b_conv = 0;
	    for (int i = 0;i<3;i = i + 1)begin
		    for(int j = 0;j<3;j = j + 1)begin
			    r_conv = r_conv + $signed(coffs[i][j])*$signed({1'b0,caches[i][j][15:11]});
			    g_conv = g_conv + $signed(coffs[i][j])*$signed({1'b0,caches[i][j][10:5]});
			    b_conv = b_conv + $signed(coffs[i][j])*$signed({1'b0,caches[i][j][4:0]});
		    end
	    end
	    /*r_conv = r_conv >>> shift;
	    g_conv = g_conv >>> shift;
	    b_conv = b_conv >>> shift;*/
    end
    always_ff @(posedge clk_in)begin
	    if(rst_in)begin
		    r_out <= 0;
		    g_out <= 0;
		    b_out <= 0;
		    rst_in <= 0;
	    end

	    if(data_valid_pipe[1])begin
		    //write in data
		    for(int i = 0;i<3;i+=1)begin
			   caches[i][2] <= caches[i][1];
			   caches[i][1] <= caches[i][0];
			   caches[i][0] <= data_in[i];
		    end 

		    r_conv = r_conv >>> shift;
		    g_conv = g_conv >>> shift;
		    b_conv = b_conv >>> shift;
		    r_out <= r_conv < 0 ? 0 : r_conv;
		    g_out <= g_conv < 0 ? 0 : g_conv;
		    b_out <= b_conv < 0 ? 0 : b_conv;
	    end
	    line_out <= {r_out[4:0],g_out[5:0],b_out[4:0]};
    end
endmodule

`default_nettype wire
