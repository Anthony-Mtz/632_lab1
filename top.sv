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
	logic sample_clock;
	logic send;
	logic incr_write_count, reset_write_count;
	logic incr_read_count, reset_read_count;
	logic generate_and_send;
	logic start_50, memory_clk, mem_50, done;
	logic [31:0] clk_counter;
	
	enum logic [2:0] {WAIT = 3'd1, GENERATE_RAND = 3'd2, HOLD = 3'd3, WAIT_DONE} state, nextState;
	enum logic [2:0] {INIT, TRANSMIT_RAND = 3'd4, TX_WAIT = 3'd5} state_50, nextState_50;
	enum logic {PRESSED, RELEASED} state_button, nextState_button;
	
	fast_oscil #(97) oscil0(.clk(CLOCK_50), .q(q0), .en(SW[0]));
	fast_oscil #(79) oscil1(.clk(CLOCK_50), .q(q1), .en(SW[0]));
	fast_oscil #(277) oscil2(.clk(CLOCK_50), .q(q2), .en(SW[0]));

   //fast_oscil #(173) oscil_clk (.q(clk), .en(SW[0]));
	//assign sample_clock = clk;
	assign bit_xor = q0 ^ q1 ^ q2;
	//assign clk = CLOCK_50;
	

	always_ff@(posedge sample_clock) begin
		bit_out <= bit_xor;
	end

	assign LEDR[0] = bit_out;
	assign LEDR[2] = SW[0];
	assign LEDR[3] = ~KEY[0];
	assign LEDR[4] = generate_and_send;

	logic [$clog2(COUNT)-1:0] write_count, read_count;

	logic write_en, read_en;
	logic [WORD_WIDTH-1:0] mem_out;
	logic [$clog2(MEMORY_SIZE)-1:0] write_addr, read_addr;

	

	logic reset_n;

	clock_divider #(.DIV_FACT(4)) sampler(.clk(CLOCK_50), .reset_n(1'b1), .en(1'b1),
											.clk_div(sample_clock));

	assign memory_clk = (mem_50) ? CLOCK_50 : sample_clock;
	MEMORY #(.MEMORY_SIZE(MEMORY_SIZE),.WORD_WIDTH(WORD_WIDTH)) memory(.clock(memory_clk), .reset_n(1'b1),
											.write_en(write_en), .read_en(1'b1),
											.write_addr(write_addr), .read_addr(read_addr),
											.din(bit_out), .dout(mem_out));

	logic tx_busy;
	logic [7:0] din;

	assign LEDR[9:7] = state;

	assign read_addr = read_count;
	assign write_addr = write_count;

	assign din = (mem_out) ? 8'h31 : 8'h30;

	uart transmit(.din, .wr_en(send), .clk_50m(CLOCK_50), .tx(GPIO_0[25]), .tx_busy);
	
	always_comb begin
		nextState = WAIT;
		incr_write_count = 1'b0;
		reset_write_count = 1'b0;
        write_en = 1'd0;
		start_50 = 1'd0;

		case(state)
		WAIT: begin
			nextState = (generate_and_send) ? GENERATE_RAND : WAIT;
			reset_write_count = generate_and_send;
		end
		GENERATE_RAND: begin
			if(write_count < COUNT) begin
				nextState = GENERATE_RAND;
				incr_write_count = 1'd1;
				write_en = 1'd1;
			end
			else begin
				nextState = WAIT_DONE;
				start_50 = 1'd1;
			end
		end
		WAIT_DONE: begin
			nextState = WAIT_DONE;
		end
		endcase
	end

	always_comb begin
		nextState_50 = INIT;
		send = 1'd0;
		incr_read_count = 1'b0;
		reset_read_count = 1'b0;
		mem_50 = 1'd0;
		case(state_50)
			INIT: begin
				reset_read_count = 1'd1;
				if(start_50) begin
					mem_50 = 1'd1;
					nextState_50 = TRANSMIT_RAND;
				end
				else nextState_50 = INIT;
			end
			TRANSMIT_RAND: begin
				mem_50 = 1'd1;
				if(read_count < COUNT) begin
					nextState_50 = TX_WAIT;
					send = 1'b1;
				end
				else begin
					nextState_50 = INIT;
				end
			end
			TX_WAIT: begin
				mem_50 = 1'd1;
				nextState_50 = (tx_busy) ? TX_WAIT : TRANSMIT_RAND;
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

	always_ff @(posedge sample_clock) begin

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
	end

	always_ff @(posedge CLOCK_50) begin
		if(~KEY[3]) state_50 <= INIT;
		else state_50 <= nextState_50;

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
