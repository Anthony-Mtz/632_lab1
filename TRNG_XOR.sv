module xor_ring_oscillator
  #(parameter SIZE = 32)
  (
    output logic [SIZE-1:0] xor_OUT
  );

  genvar i;
  generate
    for (i=1; i < SIZE-1; i++) begin: xor_ring_oscillator_gen
      assign xor_OUT[i] = xor_OUT[i-1] ^ xor_OUT[i] ^ xor_OUT[i+1];
    end
  endgenerate

  assign xor_OUT[0] = xor_OUT[SIZE-1] ^ xor_OUT[0] ^ xor_OUT[1]; 
  assign xor_OUT[SIZE-1] = ~(xor_OUT[SIZE-2] ^ xor_OUT[SIZE-1] ^ xor_OUT[0]);

endmodule: xor_ring_oscillator


module LHCA
  #(parameter SIZE = 32) 
  (
    input  logic clock,
    input  logic [SIZE-1:0] xor_IN,
    output logic [SIZE-1:0] flop_OUT
  );

  logic [SIZE-1:0] xor_OUT;
 
  genvar i;
  generate
    for (i=1; i < SIZE-1; i++) begin: LHCA_generate
      assign xor_OUT[i] = flop_OUT[i-1] ^ flop_OUT[i] ^ xor_IN[i] ^ flop_OUT[i+1];      
    end
  endgenerate

  assign xor_OUT[0] = 0 ^ flop_OUT[0] ^ xor_IN[0] ^ flop_OUT[1];
  assign xor_OUT[SIZE-1] = flop_OUT[SIZE-2] ^ flop_OUT[SIZE-1] ^ xor_IN[SIZE-1] ^ 0;

  always_ff @(posedge clock)
    flop_OUT <= xor_OUT;

endmodule: LHCA


module TRNG
  #(parameter SIZE = 32) 
  (
    input  logic clock,
    output logic [SIZE-1:0] word_OUT
  );

  logic [SIZE-1:0] oscillator_out, lhca_in;

  xor_ring_oscillator #(.SIZE(SIZE)) oscillator(.xor_OUT(oscillator_out));
  LHCA #(.SIZE(SIZE)) lhca(.clock(clock), .xor_IN(lhca_in), .flop_OUT(word_OUT));

  always_ff @(posedge clock)
    lhca_in <= oscillator_out;

endmodule: TRNG


module TOP_OLD(
  input  logic [3:0] KEY,
  input  logic CLOCK_50,
  output logic [9:0] LEDR,
  output logic [35:0] GPIO_0
  );

  parameter BITS = 8;
  parameter TOTAL_COUNT = 1000000;

  logic [$clog2(TOTAL_COUNT):0] count;

  logic [BITS-1:0] word_OUT;
  logic [$clog2(BITS):0] pointer;
  logic enter, send, tx_busy, increment, reset_pointer, generate_random, generate_sequence;
  logic reset_count, generate_done, increment_count;

  logic [7:0] din;

  assign din = (word_OUT[BITS-1-pointer]) ? 8'h31 : 8'h30;

  assign LEDR[8:0] = word_OUT;
  assign LEDR[9] = tx_busy;
 
  uart transmit(.din, .wr_en(send), .clk_50m(CLOCK_50), .tx(GPIO_0[25]), .tx_busy);
  TRNG #(.SIZE(BITS)) DUT(.clock(enter), .word_OUT);




  enum logic [1:0] {MAIN_WAIT, SEQ_GEN, WAIT_GEN} main_state, main_nextState;

  always_comb begin
    main_nextState = MAIN_WAIT;
    reset_count = 1'b0;
    increment_count = 1'b0;
    generate_random = 1'b0;

    case(main_state)

      MAIN_WAIT: begin
        main_nextState = (generate_sequence) ? SEQ_GEN : MAIN_WAIT;
        reset_count = 1'b1;
      end

      SEQ_GEN: begin
        if(count < TOTAL_COUNT) begin
          main_nextState = WAIT_GEN;
          generate_random = 1'b1;
        end
        else begin
          main_nextState = MAIN_WAIT;
          reset_count = 1'b1;
        end
      end

      WAIT_GEN: begin
        main_nextState = (generate_done) ? SEQ_GEN : WAIT_GEN;
        increment_count = generate_done;
      end

    endcase


  end







  enum logic [1:0] {WAIT, TRANSMIT, BUSY} state, nextState;

  always_comb begin
    nextState = WAIT;
    enter = 1'b0;
    send = 1'b0;
    reset_pointer = 1'b0;
    increment = 1'b0;
    generate_done = 1'b0;
    
    case(state)
      
      WAIT: begin
        nextState = (generate_random) ? TRANSMIT : WAIT;
        enter = generate_random;
        reset_pointer = 1'b1;
      end

      TRANSMIT: begin
        if(pointer < BITS) begin
          nextState = BUSY;
          send = 1'b1;
        end
        else begin
          nextState = WAIT;
          generate_done = 1'b1;
          reset_pointer = 1'b1;
        end
      end

      BUSY: begin
        nextState = (tx_busy) ? BUSY : TRANSMIT;
        increment = ~tx_busy;
      end

    endcase

  end


  enum logic {PRESSED, RELEASED} state_button, nextState_button;

  always_comb begin
    nextState_button = RELEASED;
    generate_sequence = 1'b0;
    
    case(state_button)
      PRESSED: begin
        nextState_button = (~KEY[0]) ? PRESSED : RELEASED;
        generate_sequence = 1'b0;
      end

      RELEASED: begin
        nextState_button = (~KEY[0]) ? PRESSED : RELEASED;
        generate_sequence = ~KEY[0];
      end
    endcase

  end


  always_ff @(posedge CLOCK_50) begin
    if(~KEY[3]) begin
      main_state <= MAIN_WAIT;
      state <= WAIT;
      state_button <= RELEASED;
    end
    else begin
      main_state <= main_nextState;
      state <= nextState;
      state_button <= nextState_button;
    end

    if(reset_pointer)
      pointer <= '0;
    else begin  
      pointer <= (increment) ? pointer + 1 : pointer;
    end

    if(reset_count)
      count <= '0;
    else begin
      count <= (increment_count) ? count + BITS : count;
    end
  end

endmodule: TOP_OLD


module MEMORY
  #(parameter MEMORY_SIZE = 4096,
    parameter WORD_WIDTH = 32) 
  ( 
    input  logic clock, reset_n,
    input  logic write_en,
    input  logic read_en,
    input  logic [$clog2(MEMORY_SIZE)-1:0] write_addr,
    input  logic [$clog2(MEMORY_SIZE)-1:0] read_addr,
    input  logic [WORD_WIDTH-1:0] din,
    output logic [WORD_WIDTH-1:0] dout
  );

  logic [MEMORY_SIZE-1:0][WORD_WIDTH-1:0] memory;
  logic [WORD_WIDTH-1:0] temp_data;

  always_ff @(posedge clock, negedge reset_n) begin
    if(~reset_n) begin
      // reset memory
    end
    else if (write_en) memory[write_addr] <= din;
  end

  assign dout = read_en ? memory[read_addr] : 'd0;



endmodule: MEMORY


module TOP(
  input  logic [3:0] KEY,
  input  logic CLOCK_50,
  output logic [35:0] GPIO_0
);

  parameter WORD_WIDTH = 8;
  parameter COUNT = 1000000;
  parameter MAX_ADDR = COUNT / WORD_WIDTH;

  logic [$clog2(COUNT):0] count;
  logic [WORD_WIDTH-1:0] word_OUT;

  logic write_en, read_en;
  logic [WORD_WIDTH-1:0] mem_out;
  logic [$clog2(WORD_WIDTH)-1:0] write_addr, read_addr;

  logic sample_clock;

  clock_divider #(.DIVIDE(4)) sampler(.clk_50m(CLOCK_50), .divided_clock(sample_clock));

  TRNG #(.SIZE(WORD_WIDTH)) DUT(.clock(sample_clock), .word_OUT(word_OUT));

  MEMORY #(.WORD_WIDTH(WORD_WIDTH)) memory(.clock(CLOCK_50), .write_en(write_en), .read_en(read_en),
                                           .write_addr(write_addr), .read_addr(read_addr),
                                           .din(word_OUT), .dout(mem_out));

  // logic send, tx_busy;
  // logic [7:0] din;

  // assign din = (word_OUT[BITS-1-pointer]) ? 8'h31 : 8'h30;

  // uart transmit(.din, .wr_en(send), .clk_50m(CLOCK_50), .tx(GPIO_0[25]), .tx_busy);




  logic incr_count, reset_count;
  logic incr_write_addr, reset_write_addr;
  logic incr_read_addr, reset_read_addr;
  enum logic [1:0] {WAIT, GENERATE_RAND, TRANSMIT_RAND} state, nextState;

  





  logic generate_and_send;
  enum logic {PRESSED, RELEASED} state_button, nextState_button;

  always_comb begin
    nextState_button = RELEASED;
    generate_sequence = 1'b0;
    
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
    if(~KEY[3]) begin
      state_button <= RELEASED;
    end
    else begin

      state_button <= nextState_button;
    end
end

endmodule: TOP


module clock_divider
        #(parameter DIVIDE = 32)
        (input logic clk_50m,
		     output logic divided_clock);

parameter CLK_ACC_MAX = 50000000 / DIVIDE;
parameter CLK_ACC_WIDTH = $clog2(clk_acc_MAX);
reg [CLK_ACC_WIDTH - 1:0] clk_acc = 0;

assign divided_clock = (clk_acc == 9'd0);

always @(posedge clk_50m) begin
	if (clk_acc == clk_acc_MAX[CLK_ACC_WIDTH - 1:0])
		clk_acc <= 0;
	else
		clk_acc <= clk_acc + 9'b1;
end

endmodule