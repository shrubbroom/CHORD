`include "pipeline.v"
`timescale 1ns/1ns
`define SIM_TIME 118600

module tb#(
           parameter INPUT_WIDTH = 16,
           parameter OUTPUT_WIDTH = 16,
           parameter INPUT_INT_WIDTH = 7,
           parameter INPUT_FRAC_WIDTH = 8,
           parameter OUTPUT_INT_WIDTH = 7,
           parameter OUTPUT_FRAC_WIDTH = 8,
           parameter ITERATION_NUMBER = 6,
           parameter ITERATION_WORD_WIDTH = 32,
           parameter ITERATION_WORD_INT_WIDTH = 12,
           parameter ITERATION_WORD_FRAC_WIDTH = 20,
           parameter FLIP_FLAG_WIDTH = 2
           )();
   reg               clk;
   reg               reset;
   initial begin
      degree_in_reg = 16'b10000110000000000;
      clk = 0;
      reset = 0;
      $dumpfile("./tb.vcd");
      $dumpvars(0, tb.clk);
      $dumpvars(0, tb.reset);
      $dumpvars(0, tb.x_out);
      $dumpvars(0, tb.y_out);
      $dumpvars(0, tb.degree_out);
      $dumpvars(0, tb.degree_in);

      for(integer i = 0; i < ITERATION_NUMBER + 1; i = i + 1)
        begin
           $dumpvars(0, tb.pipeline.degree_reg[i]);
           $dumpvars(0, tb.pipeline.degree_approx_reg[i]);
           $dumpvars(0, tb.pipeline.x_reg[i]);
           $dumpvars(0, tb.pipeline.y_reg[i]);
           if (i < ITERATION_NUMBER)
             $dumpvars(0, tb.pipeline.degree_mem[i]);
        end
      $dumpvars(0, tb.pipeline.k_reg);
      $dumpvars(0, tb.pipeline.x_correct_reg);
      $dumpvars(0, tb.pipeline.y_correct_reg);
      $dumpvars(0, tb.pipeline.y_enlarge_reg);
      $dumpvars(0, tb.pipeline.x_enlarge_reg);
      #5 reset = 1;
      # `SIM_TIME $finish;
   end
   always #10 clk = !clk;
   reg [INPUT_WIDTH - 1 : 0] degree_in_reg;
   wire [OUTPUT_WIDTH - 1 : 0] degree_out;
   wire [OUTPUT_WIDTH - 1 : 0] x_out;
   wire [OUTPUT_WIDTH - 1 : 0] y_out;
   wire [INPUT_WIDTH - 1 : 0]  degree_in;
   wire [FLIP_FLAG_WIDTH - 1 : 0]     flip_in;
   wire [FLIP_FLAG_WIDTH - 1 : 0]     flip_out;
   wire                                 arctan_en_in;
   wire                                 arctan_en_out;
   wire [INPUT_WIDTH - 1 : 0]  x_in;
   wire [INPUT_WIDTH - 1 : 0]  y_in;
   assign degree_in = degree_in_reg;
   assign arctan_en_in = 1;
   assign x_in = 16'b0000000100000000;
   assign y_in = 16'b0000010000000010;
   pipeline pipeline(/*AUTOINST*/
                     // Outputs
                     .degree_out        (degree_out[OUTPUT_WIDTH-1:0]),
                     .x_out             (x_out[OUTPUT_WIDTH-1:0]),
                     .y_out             (y_out[OUTPUT_WIDTH-1:0]),
                     .flip_out          (flip_out[FLIP_FLAG_WIDTH-1:0]),
                     .arctan_en_out     (arctan_en_out),
                     .valid_out         (valid_out),
                     // Inputs
                     .clk               (clk),
                     .reset             (reset),
                     .degree_in         (degree_in[INPUT_WIDTH-1:0]),
                     .x_in              (x_in[INPUT_WIDTH-1:0]),
                     .y_in              (y_in[INPUT_WIDTH-1:0]),
                     .flip_in           (flip_in[FLIP_FLAG_WIDTH-1:0]),
                     .arctan_en_in      (arctan_en_in),
                     .valid_in          (valid_in));
endmodule // tb
