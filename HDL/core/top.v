`include "pipeline.v"
`include "interface_input.v"
module top#(
            parameter UNSIGNED_INPUT_WIDTH = 16,
            parameter UNSIGNED_OUTPUT_WIDTH = 16,
            parameter UNSIGNED_INPUT_INT_WIDTH = 7,
            parameter UNSIGNED_INPUT_FRAC_WIDTH = 8,
            parameter UNSIGNED_OUTPUT_INT_WIDTH = 7,
            parameter UNSIGNED_OUTPUT_FRAC_WIDTH = 8,
            parameter ITERATION_NUMBER = 6,
            parameter ITERATION_WORD_WIDTH = 32,
            parameter ITERATION_WORD_INT_WIDTH = 12,
            parameter ITERATION_WORD_FRAC_WIDTH = 20,
            parameter SECTOR_FLAG_WIDTH = 2
            )(
              /*AUTOINPUT*/
              // Beginning of automatic inputs (from unused autoinst inputs)
              input                                   arctan_en_in, // To pipeline of pipeline.v
              input                                   clk, // To pipeline of pipeline.v, ...
              input signed [UNSIGNED_INPUT_WIDTH-1:0] degree_in,// To pipeline of pipeline.v, ...
              input                                   reset, // To pipeline of pipeline.v
              input                                   rst, // To interface_input of interface_input.v
              input [SECTOR_FLAG_WIDTH-1:0]           sector_in,// To pipeline of pipeline.v
              input                                   valid_in, // To pipeline of pipeline.v
              input [UNSIGNED_INPUT_WIDTH-1:0]        x_in, // To pipeline of pipeline.v
              input [UNSIGNED_INPUT_WIDTH-1:0]        y_in  // To pipeline of pipeline.v
              // End of automatics
              );
   /*dummy top*/
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire                                               arctan_en_out;          // From pipeline of pipeline.v
   wire [UNSIGNED_OUTPUT_WIDTH-1:0]                   degree_out; // From pipeline of pipeline.v, ...
   wire [1:0]                                         quadrant;               // From interface_input of interface_input.v
   wire [SECTOR_FLAG_WIDTH-1:0]                       sector_out;     // From pipeline of pipeline.v
   wire                                               valid_out;              // From pipeline of pipeline.v
   wire [UNSIGNED_OUTPUT_WIDTH-1:0]                   x_out;      // From pipeline of pipeline.v
   wire [UNSIGNED_OUTPUT_WIDTH-1:0]                   y_out;      // From pipeline of pipeline.v
   // End of automatics
   pipeline pipeline(/*AUTOINST*/
                     // Outputs
                     .degree_out        (degree_out[UNSIGNED_OUTPUT_WIDTH-1:0]),
                     .x_out             (x_out[UNSIGNED_OUTPUT_WIDTH-1:0]),
                     .y_out             (y_out[UNSIGNED_OUTPUT_WIDTH-1:0]),
                     .sector_out        (sector_out[SECTOR_FLAG_WIDTH-1:0]),
                     .arctan_en_out     (arctan_en_out),
                     .valid_out         (valid_out),
                     // Inputs
                     .clk               (clk),
                     .reset             (reset),
                     .degree_in         (degree_in[UNSIGNED_INPUT_WIDTH-1:0]),
                     .x_in              (x_in[UNSIGNED_INPUT_WIDTH-1:0]),
                     .y_in              (y_in[UNSIGNED_INPUT_WIDTH-1:0]),
                     .sector_in         (sector_in[SECTOR_FLAG_WIDTH-1:0]),
                     .arctan_en_in      (arctan_en_in),
                     .valid_in          (valid_in));
   interface_input interface_input(/*AUTOINST*/
                                   // Outputs
                                   .degree_out          (degree_out[UNSIGNED_OUTPUT_WIDTH-1:0]),
                                   .quadrant            (quadrant[1:0]),
                                   // Inputs
                                   .clk                 (clk),
                                   .rst                 (rst),
                                   .degree_in           (degree_in[UNSIGNED_INPUT_WIDTH-1:0]));
endmodule // top
