

module fast_oscil #(parameter NUM_OSCIL = 5)(input clk, input sel_in_data, input d, output q);

	genvar i;
	logic [NUM_OSCIL-1:0] tmp_arr;
	assign tmp_arr[0] = (sel_in_data) ? d : ~q;
	always_ff @(posedge clk) begin
		q <= tmp_arr[NUM_OSCIL-1];
	end
	

	logic in;
	
	generate 
		for (i = 1; i < NUM_OSCIL; i = i+1) begin : oscillator
		
				assign tmp_arr[i] = ~tmp_arr[i-1];
			
		end
	endgenerate


endmodule: fast_oscil
