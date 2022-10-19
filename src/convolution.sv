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
   
    logic signed [15:0] r_conv,g_conv,b_conv;
    logic signed [15:0] r_shift,g_shift,b_shift; 
    logic signed [4:0] r_out;
    logic signed [5:0] g_out;
    logic signed [4:0] b_out;

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
    logic [3:0] data_valid_pipe;
    logic [10:0] hcount_pipe [3:0];
    logic [9:0] vcount_pipe [3:0];
    always_ff @(posedge clk_in)begin
		    data_valid_pipe[0] <= data_valid_in;
            	    hcount_pipe[0] <= hcount_in;
            		vcount_pipe[0] <= vcount_in;
	    /*data_valid_pipe[0] <= data_valid_in;
	    hcount_pipe[0] <= hcount_in;
	    vcount_pipe[0] <= vcount_in;*/
	    for(int i = 1;i<4;i = i+1)begin
		    data_valid_pipe[i] <= data_valid_pipe[i-1];
		    hcount_pipe[i] <= hcount_pipe[i-1];
		    vcount_pipe[i] <= vcount_pipe[i-1];
	    end
	    data_valid_out <= data_valid_pipe[2];
	    hcount_out <= hcount_pipe[2];
	    vcount_out <= vcount_pipe[2];
    end
    always_comb begin
	    /*
	     * r_conv = $signed(coffs[0][0])*$signed({1'b0,caches[0][0][15:11]}) + 
	     * 		
	    r_conv = 0;
	    g_conv = 0;
	    b_conv = 0;
	    /*for (int i = 0;i<3;i = i + 1)begin
		    for(int j = 0;j<3;j = j + 1)begin
			    r_conv = r_conv + $signed(coffs[i][j])*$signed({1'b0,caches[i][j][15:11]});
			    g_conv = g_conv + $signed(coffs[i][j])*$signed({1'b0,caches[i][j][10:5]});
			    b_conv = b_conv + $signed(coffs[i][j])*$signed({1'b0,caches[i][j][4:0]});
		    end
	    end*/
	    r_conv = 0;
	    b_conv = 0;
	    g_conv = 0;
	    r_conv = $signed(r_conv) + $signed(coffs[0][0])*$signed({1'b0,caches[0][0][15:11]});
            g_conv = $signed(g_conv) + $signed(coffs[0][0])*$signed({1'b0,caches[0][0][10:5]});
            b_conv = $signed(b_conv) + $signed(coffs[0][0])*$signed({1'b0,caches[0][0][4:0]});
	    r_conv = $signed(r_conv) + $signed(coffs[0][1])*$signed({1'b0,caches[0][1][15:11]});
            g_conv = $signed(g_conv) + $signed(coffs[0][1])*$signed({1'b0,caches[0][1][10:5]});
            b_conv = $signed(b_conv) + $signed(coffs[0][1])*$signed({1'b0,caches[0][1][4:0]});
	    r_conv = $signed(r_conv) + $signed(coffs[0][2])*$signed({1'b0,caches[0][2][15:11]});
            g_conv = $signed(g_conv) + $signed(coffs[0][2])*$signed({1'b0,caches[0][2][10:5]});
            b_conv = $signed(b_conv) + $signed(coffs[0][2])*$signed({1'b0,caches[0][2][4:0]});
	    r_conv = $signed(r_conv) + $signed(coffs[1][0])*$signed({1'b0,caches[1][0][15:11]});
            g_conv = $signed(g_conv) + $signed(coffs[1][0])*$signed({1'b0,caches[1][0][10:5]});
            b_conv = $signed(b_conv) + $signed(coffs[1][0])*$signed({1'b0,caches[1][0][4:0]});
	    r_conv = $signed(r_conv) + $signed(coffs[1][1])*$signed({1'b0,caches[1][1][15:11]});
            g_conv = $signed(g_conv) + $signed(coffs[1][1])*$signed({1'b0,caches[1][1][10:5]});
            b_conv = $signed(b_conv) + $signed(coffs[1][1])*$signed({1'b0,caches[1][1][4:0]});
	    r_conv = $signed(r_conv) + $signed(coffs[1][2])*$signed({1'b0,caches[1][2][15:11]});
            g_conv = $signed(g_conv) + $signed(coffs[1][2])*$signed({1'b0,caches[1][2][10:5]});
            b_conv = $signed(b_conv) + $signed(coffs[1][2])*$signed({1'b0,caches[1][2][4:0]});
	    r_conv = $signed(r_conv) + $signed(coffs[2][0])*$signed({1'b0,caches[2][0][15:11]});
            g_conv = $signed(g_conv) + $signed(coffs[2][0])*$signed({1'b0,caches[2][0][10:5]});
            b_conv = $signed(b_conv) + $signed(coffs[2][0])*$signed({1'b0,caches[2][0][4:0]});
	    r_conv = $signed(r_conv) + $signed(coffs[2][1])*$signed({1'b0,caches[2][1][15:11]});
            g_conv = $signed(g_conv) + $signed(coffs[2][1])*$signed({1'b0,caches[2][1][10:5]});
            b_conv = $signed(b_conv) + $signed(coffs[2][1])*$signed({1'b0,caches[2][1][4:0]});
	    r_conv = $signed(r_conv) + $signed(coffs[2][2])*$signed({1'b0,caches[2][2][15:11]});
            g_conv = $signed(g_conv) + $signed(coffs[2][2])*$signed({1'b0,caches[2][2][10:5]});
            b_conv = $signed(b_conv) + $signed(coffs[2][2])*$signed({1'b0,caches[2][2][4:0]});


	    /*r_conv = r_conv >>> shift;
	    g_conv = g_conv >>> shift;
	    b_conv = b_conv >>> shift;*/
    end
    always_ff @(posedge clk_in)begin
	    if(rst_in)begin
		    r_out <= 0;
		    g_out <= 0;
		    b_out <= 0;
		    caches <= 0;
	    end

	    if(data_valid_in)begin
		    //write in data
		    caches[0] <= caches[1];
		    caches[1] <= caches[2];
		    caches[2] <= data_in;
		    /*for(int i = 0;i<3;i=i+1)begin
			   caches[i][2] <= caches[i][1];
			   caches[i][1] <= caches[i][0];
			   caches[i][0] <= data_in[i];
		    end*/ 

		    /*r_shift <= r_conv >>> shift;
		    g_shift <= g_conv >>> shift;
		    b_shift <= b_conv >>> shift;
		    r_out <= r_shift < 0 ? 0 : r_shift;
		    g_out <= g_shift < 0 ? 0 : g_shift;
		    b_out <= b_shift < 0 ? 0 : b_shift;*/
		    //line_out <= {r_out[4:0],g_out[5:0],b_out[4:0]};
	    end
	    r_shift <= r_conv >>> shift;
            g_shift <= g_conv >>> shift;
            b_shift <= b_conv >>> shift;
            r_out <= r_shift < 0 ? 0 : r_shift;
            g_out <= g_shift < 0 ? 0 : g_shift;
            b_out <= b_shift < 0 ? 0 : b_shift;
	    line_out <= {r_out[4:0],g_out[5:0],b_out[4:0]};
    end
endmodule

`default_nettype wire
