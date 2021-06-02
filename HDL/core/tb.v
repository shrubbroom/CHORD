`include "pipeline.v"
`timescale 1ns/1ns
`define SIM_TIME 118600

module tb#(
            parameter UNSIGNED_INPUT_WIDTH = 16,
            parameter UNSIGNED_OUTPUT_WIDTH = 16,
            parameter UNSIGNED_INPUT_INT_WIDTH = 7,
            parameter UNSIGNED_INPUT_FRAC_WIDTH = 8,
            parameter UNSIGNED_OUTPUT_INT_WIDTH = 7,
            parameter UNSIGNED_OUTPUT_FRAC_WIDTH = 8,
            parameter ITERATION_NUMBER = 6,
            parameter ITERATION_WORD_WIDTH = 32,
            parameter ITERATION_WORD_INT_WIDTH = 6,
            parameter ITERATION_WORD_FRAC_WIDTH = 26
            )();
   reg                clk;
   reg                reset;
   integer            i;
   initial begin
      clk = 0;
      reset = 0;
      $dumpfile("./build/tb.vcd");
      $dumpvars(0, tb.clk);
      $dumpvars(0, tb.reset);
      $dumpvars(0, tb.x_out);
      $dumpvars(0, tb.y_out);
      $dumpvars(0, tb.degree_out);
      $dumpvars(0, tb.degree_in);
      for(i = 0; i < ITERATION_NUMBER - 1; i = i + 1)
        begin
           $dumpvars(0, tb.pipeline.degree_reg[i]);
           $dumpvars(0, tb.pipeline.degree_approx_reg[i]);
           $dumpvars(0, tb.pipeline.x_reg[i]);
           $dumpvars(0, tb.pipeline.y_reg[i]);
        end
      $dumpvars(0, tb.pipeline.k_reg);
      #5 reset = 1;
      # `SIM_TIME $finish;
   end
   always #10 clk = !clk;
   wire [UNSIGNED_OUTPUT_WIDTH - 1 : 0] degree_out;
   wire [UNSIGNED_OUTPUT_WIDTH - 1 : 0] x_out;
   wire [UNSIGNED_OUTPUT_WIDTH - 1 : 0] y_out;
   wire [UNSIGNED_INPUT_WIDTH - 1 : 0]  degree_in;
   assign degree_in = 0010010100000000;
   pipeline pipeline(/*AUTOINST*/
                     // Outputs
                     .degree_out        (degree_out),
                     .x_out             (x_out),
                     .y_out             (y_out),
                     // Inputs
                     .clk               (clk),
                     .reset             (reset),
                     .degree_in         (degree_in));
endmodule // tb
