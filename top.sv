`default_nettype none

module top
	(input CLOCK_50, 
	 input logic [3:0] KEY,
	 input logic [9:0] SW,
	 output logic [9:0] LEDR, 
	 output logic [35:0] GPIO_0);

	logic q0, q1, q2, bit_xor, bit_out, clk;
	fast_oscil#(79) oscil0(.clk, .q(q0), .en(SW[0]));
	fast_oscil#(823) oscil1(.clk, .q(q1), .en(SW[0]));
	fast_oscil#(7507) oscil2( .clk, .q(q2), .en(SW[0]));
	
	
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
	assign LEDR[2] = SW[0];

	// parameter BITS = 1;
	// parameter TOTAL_COUNT = 1000000;

	// logic [$clog2(TOTAL_COUNT):0] count;

	// logic [BITS-1:0] word_OUT;
	// logic [$clog2(BITS):0] pointer;
	// logic enter, send, tx_busy, increment, reset_pointer, generate_random, generate_sequence;
	// logic reset_count, generate_done, increment_count;

	// logic [7:0] din;

	// assign din = (bit_out) ? 8'h31 : 8'h30;

	// uart transmit(.din, .wr_en(send), .clk_50m(CLOCK_50), .tx(GPIO_0[25]), .tx_busy);

	// enum logic [1:0] {MAIN_WAIT, SEQ_GEN, WAIT_GEN} main_state, main_nextState;

	// always_comb begin
	// main_nextState = MAIN_WAIT;
	// reset_count = 1'b0;
	// increment_count = 1'b0;
	// generate_random = 1'b0;

	// case(main_state)

	// 	MAIN_WAIT: begin
	// 	main_nextState = (generate_sequence) ? SEQ_GEN : MAIN_WAIT;
	// 	reset_count = 1'b1;
	// 	end

	// 	SEQ_GEN: begin
	// 	if(count < TOTAL_COUNT) begin
	// 		main_nextState = WAIT_GEN;
	// 		generate_random = 1'b1;
	// 	end
	// 	else begin
	// 		main_nextState = MAIN_WAIT;
	// 		reset_count = 1'b1;
	// 	end
	// 	end

	// 	WAIT_GEN: begin
	// 	main_nextState = (generate_done) ? SEQ_GEN : WAIT_GEN;
	// 	increment_count = generate_done;
	// 	end

	// endcase
	// end

	// enum logic [1:0] {WAIT, TRANSMIT, BUSY} state, nextState;

	// always_comb begin
	// 	nextState = WAIT;
	// 	enter = 1'b0;
	// 	send = 1'b0;
	// 	reset_pointer = 1'b0;
	// 	increment = 1'b0;
	// 	generate_done = 1'b0;

	// 	case(state)
	// 		WAIT: begin
	// 		nextState = (generate_random) ? TRANSMIT : WAIT;
	// 		enter = generate_random;
	// 		reset_pointer = 1'b1;
	// 		end
	// 		TRANSMIT: begin
	// 		if(pointer < BITS) begin
	// 			nextState = BUSY;
	// 			send = 1'b1;
	// 		end
	// 		else begin
	// 			nextState = WAIT;
	// 			generate_done = 1'b1;
	// 			reset_pointer = 1'b1;
	// 		end
	// 		end
	// 		BUSY: begin
	// 		nextState = (tx_busy) ? BUSY : TRANSMIT;
	// 		increment = ~tx_busy;
	// 		end
	// 	endcase
	// end

	// enum logic {PRESSED, RELEASED} state_button, nextState_button;

	// always_comb begin
	// 	nextState_button = RELEASED;
	// 	generate_sequence = 1'b0;

	// 	case(state_button)
	// 		PRESSED: begin
	// 		nextState_button = (~KEY[0]) ? PRESSED : RELEASED;
	// 		generate_sequence = 1'b0;
	// 		end

	// 		RELEASED: begin
	// 		nextState_button = (~KEY[0]) ? PRESSED : RELEASED;
	// 		generate_sequence = ~KEY[0];
	// 		end
	// 	endcase
	// end


	// always_ff @(posedge CLOCK_50) begin
	// 	if(~KEY[3]) begin
	// 		main_state <= MAIN_WAIT;
	// 		state <= WAIT;
	// 		state_button <= RELEASED;
	// 	end
	// 	else begin
	// 		main_state <= main_nextState;
	// 		state <= nextState;
	// 		state_button <= nextState_button;
	// 	end
	// 	if(reset_pointer)
	// 		pointer <= '0;
	// 	else begin  
	// 		pointer <= (increment) ? pointer + 1 : pointer;
	// 	end
	// 	if(reset_count)
	// 		count <= '0;
	// 	else begin
	// 		count <= (increment_count) ? count + BITS : count;
	// 	end
	// end

endmodule: top
