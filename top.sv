`default_nettype none

module top(input CLOCK_50, input logic [3:0] KEY, output logic [9:0] LEDR);

	logic sel_in_data, d, q0, q1, q2, bit_xor, bit_out, clk;
	fast_oscil#(5) oscil0(.clk, .sel_in_data, .d, .q(q0));
	fast_oscil#(7) oscil1(.clk, .sel_in_data, .d, .q(q1));
	fast_oscil#(11) oscil2( .clk, .sel_in_data, .d, .q(q2));
	
	
	assign bit_xor = q0 ^ q1 ^ q2;
	assign clk = CLOCK_50;
	logic tmp, tmp2;
	
	always_ff@(posedge clk) begin
		tmp 	  <= KEY[0];
		tmp2    <= tmp;
	end
	
	always_ff@(negedge tmp2) begin
		bit_out <= bit_xor;
	end
	
	assign LEDR[0] = bit_out;
	assign LEDR[1] = 1;

endmodule: top
