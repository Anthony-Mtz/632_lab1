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


module TOP(
  input  logic [3:0] KEY,
  output logic [9:0] LEDR
  );

  TRNG #(.SIZE(10)) DUT(.clock(~KEY[0]), .word_OUT(LEDR));

endmodule: TOP