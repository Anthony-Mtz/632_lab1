`default_nettype none

module top
	(input CLOCK_50, 
	 input logic [3:0] KEY,
	 input logic [9:0] SW,
	 output logic [9:0] LEDR, 
	 output logic [35:0] GPIO_0);

	localparam WORD_WIDTH = 1;  // @TODO: does this have to be 8?
	localparam COUNT = 1000000;
	localparam MEMORY_SIZE = COUNT / WORD_WIDTH;

	logic q0, q1, q2, bit_xor, bit_out, clk, bit_clk;
	fast_oscil#(97) oscil0(.clk, .q(q0), .en(SW[0]));
	fast_oscil#(79) oscil1(.clk, .q(q1), .en(SW[0]));
	fast_oscil#(277) oscil2(.clk, .q(q2), .en(SW[0]));
	
	
	assign bit_xor = q0 ^ q1 ^ q2;
	assign clk = CLOCK_50;
	logic tmp, tmp2;
	
	always_ff@(posedge clk) begin
		tmp 	  <= KEY[1];
		tmp2    <= tmp;
	end
	
	always_ff@(posedge sample_clock) begin
		bit_out <= bit_xor;
	end
	
	assign LEDR[0] = bit_out;
	assign LEDR[1] = 1;
	assign LEDR[2] = SW[0];

	logic [$clog2(COUNT):0] write_count, read_count;

	logic write_en, read_en;
	logic [WORD_WIDTH-1:0] mem_out;
	logic [$clog2(MEMORY_SIZE)-1:0] write_addr, read_addr;

	logic sample_clock;

	logic reset_n;

	clock_divider #(.DIV_FACT(4)) sampler(.clk(CLOCK_50), .reset_n(1'b1), .en(1'b1),
											.clk_div(sample_clock));


	MEMORY #(.MEMORY_SIZE(MEMORY_SIZE),.WORD_WIDTH(WORD_WIDTH)) memory(.clock(CLOCK_50), .reset_n(1'b1),
											.write_en(write_en), .read_en(1'b1),
											.write_addr(write_addr), .read_addr(read_addr),
											.din(bit_out), .dout(mem_out));

	logic tx_busy;
	logic [7:0] din;

	logic send;
	logic incr_write_count, reset_write_count;
	logic incr_read_count, reset_read_count;

	enum logic [2:0] {WAIT = 3'd1, GENERATE_RAND = 3'd2, HOLD = 3'd3, 
					  TRANSMIT_RAND = 3'd4, TX_WAIT = 3'd5} state, nextState;

	assign LEDR[9:7] = state;

	assign read_addr = read_count/WORD_WIDTH;
	assign write_addr = write_count/WORD_WIDTH;

	assign din = (mem_out) ? 8'h31 : 8'h30;

	uart transmit(.din, .wr_en(send), .clk_50m(CLOCK_50), .tx(GPIO_0[25]), .tx_busy);

	logic generate_and_send;
	enum logic {PRESSED, RELEASED} state_button, nextState_button;
		
	always_comb begin
		nextState = WAIT;
		incr_read_count = 1'b0;
		reset_read_count = 1'b0;
		incr_write_count = 1'b0;
		reset_write_count = 1'b0;
		send = 1'b0;
        write_en = 1'd0;

		case(state)
		WAIT: begin
			nextState = (generate_and_send) ? GENERATE_RAND : WAIT;
			reset_write_count = generate_and_send;
		end
		GENERATE_RAND: begin
			if(write_count < COUNT) begin
				nextState = (sample_clock) ? HOLD : GENERATE_RAND;
				incr_write_count = sample_clock;
				write_en = sample_clock;
			end
			else begin
				nextState = TRANSMIT_RAND;
				reset_read_count = 1'b1;
			end
		end
		HOLD: begin
			nextState = (sample_clock) ? HOLD : GENERATE_RAND;
		end
		TRANSMIT_RAND: begin
			if(read_count < COUNT) begin
			nextState = TX_WAIT;
			send = 1'b1;
			end
			else begin
			nextState = WAIT;
			end
		end
		TX_WAIT: begin
			nextState = (tx_busy) ? TX_WAIT : TRANSMIT_RAND;
			incr_read_count = ~tx_busy;
		end
		endcase
	end

    always_comb begin
		nextState_button = RELEASED;
		generate_and_send = 1'b0;
		
		case(state_button)
		PRESSED: begin
			nextState_button = (~KEY[0]) ? PRESSED : RELEASED;
			generate_and_send = 1'b0;
		end

		RELEASED: begin
			nextState_button = (~KEY[0]) ? PRESSED : RELEASED;
			generate_and_send = ~KEY[0];
		end
		endcase

	end

	always_ff @(posedge CLOCK_50) begin

		// Reset button
		if(~KEY[3]) begin
		state_button <= RELEASED;
		state        <= WAIT;
		end
		else begin
		state_button <= nextState_button;
		state        <= nextState;
		end
		// Read and write count flops (controls read and write addrs)
		if(reset_write_count)
			write_count <= '0;
		if(incr_write_count)
			write_count <= write_count + WORD_WIDTH;

		if(reset_read_count)
			read_count <= '0;
		if(incr_read_count)
			read_count <= read_count + 1'b1;
	end

endmodule: top

module clock_divider_flop
  (
    input  logic en,
    input  logic clk,
    input  logic reset_n,
    output logic div_out
  );

  always_ff @(posedge clk, negedge reset_n) begin
    if (~reset_n) begin
      div_out <= 1'b0;
    end
    else if (en) begin
      div_out <= ~div_out;
    end
  end

endmodule: clock_divider_flop


module clock_divider
  #(parameter DIV_FACT=4)
  (
    input  logic en,
    input  logic clk,
    input  logic reset_n,
    output logic clk_div
  );
    
  localparam DIV = 1+$clog2(DIV_FACT);


  logic [DIV-1:0] div_conns;
  assign div_conns[0] = clk;
  assign clk_div = div_conns[DIV-1];

  genvar i;
  generate
    for (i = 1; i < DIV; i++) begin : clock_div
      clock_divider_flop flop(.en, .clk(div_conns[i-1]), .reset_n, .div_out(div_conns[i]));
    end
  endgenerate
  
endmodule: clock_divider

module MEMORY
  #(parameter MEMORY_SIZE = 4096,
    parameter WORD_WIDTH = 32) 
  ( 
    input  logic clock, reset_n,
    input  logic write_en,
    input  logic read_en,
    input  logic [$clog2(MEMORY_SIZE)-1:0] write_addr,
    input  logic [$clog2(MEMORY_SIZE)-1:0] read_addr,
    input  logic din,
    output logic [WORD_WIDTH-1:0] dout
  );

  logic memory[MEMORY_SIZE-1:0];
  logic [WORD_WIDTH-1:0] temp_data;

  always_ff @(posedge clock, negedge reset_n) begin
    if(~reset_n) begin
      //memory <= '0;
    end
    else if (write_en) memory[write_addr] <= din;
  end

  assign dout = read_en ? memory[read_addr] : '0;

endmodule: MEMORY