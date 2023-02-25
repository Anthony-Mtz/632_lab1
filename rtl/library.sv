/*
 * File: library.sv
 * Stores all library modules
 *
 */
`default_nettype none

module Register
    #(parameter WIDTH = 32)
    (input logic [WIDTH-1:0] D,
     input logic reset, clk, en,
     output logic [WIDTH-1:0] Q);

    always_ff @(posedge clk, posedge reset) begin
        if(reset) Q <= '0;
        else if(en) Q <= D;
    end

endmodule: Register


module DualPortMemory
  #(parameter AW = 32, DW = 32)
   (input logic re, we, clock,
    input logic [AW-1:0] rd_address, wr_address,
    input logic [DW-1:0] wr_data,
    output logic [DW-1:0] rd_data);

   parameter WORDS = 2**AW;

   logic [WORDS-1:0][7:0] M;

  //assign rd_data = M[rd_address +: DW/8];

   always_ff @(posedge clock) begin
     if (re) rd_data <= M[rd_address +: DW/8];
     else if (we) M[wr_address +: DW/8] <= wr_data;
   end

endmodule: DualPortMemory

module ShiftRegister
  #(parameter INPUT_WIDTH = 4, OUTPUT_WIDTH = 32)
  (input logic [INPUT_WIDTH-1:0] D,
     input logic clk, en, left, load,
   output logic [OUTPUT_WIDTH-1:0] Q);

    //PIPO Register
    always_ff @(posedge clk)
        if(load & en)
          Q <= {{(OUTPUT_WIDTH-INPUT_WIDTH){1'b0}}, D};
        else if(en)
            if(left)
              Q <= {Q[OUTPUT_WIDTH - INPUT_WIDTH - 1: 0], D};
            else
              Q <= {D, Q[OUTPUT_WIDTH-1: INPUT_WIDTH]};

endmodule: ShiftRegister

module Counter
  #(parameter WIDTH = 4, BY = 1)
    (input logic [WIDTH-1:0] D,
     input logic up, clk, en, reset, load,
     output logic [WIDTH-1: 0] Q);

  always_ff @(posedge clk, posedge reset) begin
      if(reset)
        Q <= '0;
      else if (load)
        Q <= D;
      else if(en) begin
        if(up)
          Q <= (Q + WIDTH'(BY));
        else
          Q <= (Q - WIDTH'(BY));
      end
  end

endmodule: Counter
