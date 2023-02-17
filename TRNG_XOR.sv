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

  // parameter BITS = 8;
  // parameter TOTAL_COUNT = 1000000;

  // logic [$clog2(TOTAL_COUNT):0] count;

  // logic [BITS-1:0] word_OUT;
  // logic [$clog2(BITS):0] pointer;
  // logic enter, send, tx_busy, increment, reset_pointer, generate_random, generate_sequence;
  // logic reset_count, generate_done, increment_count;

  // logic [7:0] din;

  // assign din = (word_OUT[BITS-1-pointer]) ? 8'h31 : 8'h30;

  // assign LEDR[8:0] = word_OUT;
  // assign LEDR[9] = tx_busy;
 
  // uart transmit(.din, .wr_en(send), .clk_50m(CLOCK_50), .tx(GPIO_0[25]), .tx_busy);
  // TRNG #(.SIZE(BITS)) DUT(.clock(enter), .word_OUT);




  // enum logic [1:0] {MAIN_WAIT, SEQ_GEN, WAIT_GEN} main_state, main_nextState;

  // always_comb begin
  //   main_nextState = MAIN_WAIT;
  //   reset_count = 1'b0;
  //   increment_count = 1'b0;
  //   generate_random = 1'b0;

  //   case(main_state)

  //     MAIN_WAIT: begin
  //       main_nextState = (generate_sequence) ? SEQ_GEN : MAIN_WAIT;
  //       reset_count = 1'b1;
  //     end

  //     SEQ_GEN: begin
  //       if(count < TOTAL_COUNT) begin
  //         main_nextState = WAIT_GEN;
  //         generate_random = 1'b1;
  //       end
  //       else begin
  //         main_nextState = MAIN_WAIT;
  //         reset_count = 1'b1;
  //       end
  //     end

  //     WAIT_GEN: begin
  //       main_nextState = (generate_done) ? SEQ_GEN : WAIT_GEN;
  //       increment_count = generate_done;
  //     end

  //   endcase


  // end







  // enum logic [1:0] {WAIT, TRANSMIT, BUSY} state, nextState;

  // always_comb begin
  //   nextState = WAIT;
  //   enter = 1'b0;
  //   send = 1'b0;
  //   reset_pointer = 1'b0;
  //   increment = 1'b0;
  //   generate_done = 1'b0;
    
  //   case(state)
      
  //     WAIT: begin
  //       nextState = (generate_random) ? TRANSMIT : WAIT;
  //       enter = generate_random;
  //       reset_pointer = 1'b1;
  //     end

  //     TRANSMIT: begin
  //       if(pointer < BITS) begin
  //         nextState = BUSY;
  //         send = 1'b1;
  //       end
  //       else begin
  //         nextState = WAIT;
  //         generate_done = 1'b1;
  //         reset_pointer = 1'b1;
  //       end
  //     end

  //     BUSY: begin
  //       nextState = (tx_busy) ? BUSY : TRANSMIT;
  //       increment = ~tx_busy;
  //     end

  //   endcase

  // end


  // enum logic {PRESSED, RELEASED} state_button, nextState_button;

  // always_comb begin
  //   nextState_button = RELEASED;
  //   generate_sequence = 1'b0;
    
  //   case(state_button)
  //     PRESSED: begin
  //       nextState_button = (~KEY[0]) ? PRESSED : RELEASED;
  //       generate_sequence = 1'b0;
  //     end

  //     RELEASED: begin
  //       nextState_button = (~KEY[0]) ? PRESSED : RELEASED;
  //       generate_sequence = ~KEY[0];
  //     end
  //   endcase

  // end


  // always_ff @(posedge CLOCK_50) begin
  //   if(~KEY[3]) begin
  //     main_state <= MAIN_WAIT;
  //     state <= WAIT;
  //     state_button <= RELEASED;
  //   end
  //   else begin
  //     main_state <= main_nextState;
  //     state <= nextState;
  //     state_button <= nextState_button;
  //   end

  //   if(reset_pointer)
  //     pointer <= '0;
  //   else begin  
  //     pointer <= (increment) ? pointer + 1 : pointer;
  //   end

  //   if(reset_count)
  //     count <= '0;
  //   else begin
  //     count <= (increment_count) ? count + BITS : count;
  //   end
  // end

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
      for(int i=0; i<MEMORY_SIZE; i++) begin
        memory[i] = 'd0;
      end
    end
    else if (write_en) memory[write_addr] <= din;
  end

  assign dout = read_en ? memory[read_addr] : 'd0;

endmodule: MEMORY


module TOP
  (
  input  logic [3:0] KEY,
  input  logic CLOCK_50,
  output logic [35:0] GPIO_0
  );

  localparam WORD_WIDTH = 8;  // @TODO: does this have to be 8?
  localparam COUNT = 1000000;
  localparam MEMORY_SIZE = COUNT / WORD_WIDTH;

  logic [$clog2(COUNT):0] write_count, read_count;
  logic [WORD_WIDTH-1:0] word_OUT;

  logic write_en, read_en;
  logic [WORD_WIDTH-1:0] mem_out;
  logic [$clog2(MEMORY_SIZE)-1:0] write_addr, read_addr;

  logic sample_clock;

  logic reset_n;

  clock_divider #(.DIV_FACT(4)) sampler(.clk(CLOCK_50), .reset_n(reset_n), .en(1'b1),
                                        .clk_div(sample_clock));

  TRNG #(.SIZE(WORD_WIDTH)) DUT(.clock(sample_clock), .word_OUT(word_OUT));

  MEMORY #(.MEMORY_SIZE(MEMORY_SIZE),.WORD_WIDTH(WORD_WIDTH)) memory(.clock(CLOCK_50), .reset_n(reset_n),
                                           .write_en(write_en), .read_en(1'b1),
                                           .write_addr(write_addr), .read_addr(read_addr),
                                           .din(word_OUT), .dout(mem_out));

  logic tx_busy;
  logic [7:0] din;

  logic send;
  logic incr_write_count, reset_write_count;
  logic incr_read_count, reset_read_count;

  enum logic [2:0] {WAIT, GENERATE_RAND, HOLD, TRANSMIT_RAND, TX_WAIT} state, nextState;

  assign read_addr = read_count/WORD_WIDTH;
  assign write_addr = write_addr/WORD_WIDTH;

  // assign din = (mem_out[read_addr][WORD_WIDTH-(read_count%WORD_WIDTH)]) ? 8'h31 : 8'h30;
  assign din = (mem_out[WORD_WIDTH-(read_count%WORD_WIDTH)]) ? 8'h31 : 8'h30;

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

endmodule: TOP


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