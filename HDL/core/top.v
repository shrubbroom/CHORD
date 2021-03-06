`include "pipeline.v"
`include "interface_input.v"
`include "interface_output.v"
module top#(
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
            parameter FLIP_FLAG_WIDTH = 1
            )(
              /*AUTOINPUT*/
              );
   /*dummy top*/
   /*AUTOWIRE*/
   pipeline pipeline(/*AUTOINST*/);
   interface_input interface_input(/*AUTOINST*/);
   interface_output interface_output(/*AUTOINST*/);
endmodule // top
