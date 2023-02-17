

module fast_oscil #(parameter NUM_OSCIL = 5)
	(input logic clk, en, 
	 output logic q);

	genvar i;
	logic [NUM_OSCIL-1:0] tmp_arr;
	logic q_tmp;
	assign tmp_arr[0] = ~(tmp_arr[i-1] & en); /* synthesis keep */
	always_ff @(posedge clk) begin
		q_tmp <= tmp_arr[NUM_OSCIL-1];
		q <= q_tmp;
	end
	

	logic in;
	
	generate 
		for (i = 1; i < NUM_OSCIL; i = i+1) begin : oscillator /* synthesis keep */
				assign tmp_arr[i] = ~tmp_arr[i-1]; /* synthesis keep */
		end
	endgenerate


endmodule: fast_oscil
