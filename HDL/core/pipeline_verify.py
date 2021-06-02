#!/bin/env python
# -*- coding: utf-8 -*-
import numpy as np
import subprocess as sp

def print_line(fn):
    with open(fn, "r") as f:
        for line in f:
            # print(int(line, 2) * 2 ** (-8))
            print(line)

mem_addr_width = 9
vsrc_mem = \
"""module gen_mem#(
            parameter MEM_WORD_WIDTH = 16,
            parameter MEM_LENGTH = {mem_length},
            parameter MEM_ADDR_WIDTH = {mem_addr_width}
            )(
              input [MEM_ADDR_WIDTH - 1 : 0]  mem_read_addr,
              output reg [MEM_WORD_WIDTH - 1 : 0] degree_in,
              output reg [MEM_WORD_WIDTH - 1 : 0] x_in,
              output reg [MEM_WORD_WIDTH - 1 : 0] y_in,
              output reg                          arctan_en_in
              );
   reg [MEM_WORD_WIDTH - 1 : 0]               degree_in_reg [MEM_LENGTH - 1 : 0];
   reg [MEM_WORD_WIDTH - 1 : 0]               x_in_reg [MEM_LENGTH - 1 : 0];
   reg [MEM_WORD_WIDTH - 1 : 0]               y_in_reg [MEM_LENGTH - 1 : 0];
   reg                                        arctan_en_in_reg [MEM_LENGTH - 1 : 0];
   initial
     begin
        $readmemb("./degree_in_reg.txt", degree_in_reg);
        $readmemb("./x_in_reg.txt", x_in_reg);
        $readmemb("./y_in_reg.txt", y_in_reg);
        $readmemb("./arctan_en_in_reg.txt", arctan_en_in_reg);
     end
   always @ *
     if (mem_read_addr < MEM_LENGTH) begin
        degree_in = degree_in_reg[mem_read_addr];
        x_in = x_in_reg[mem_read_addr];
        y_in = y_in_reg[mem_read_addr];
        arctan_en_in = arctan_en_in_reg[mem_read_addr];
     end
endmodule
""".format(mem_addr_width = mem_addr_width, mem_length = 2 ** mem_addr_width)

with open("gen_mem.v", "w") as vsrc_mem_f:
    vsrc_mem_f.write(vsrc_mem)

vsrc_mem_result = \
"""module gen_mem_result#(
                   parameter MEM_WORD_WIDTH = 16,
                   parameter MEM_LENGTH = {mem_length},
                   parameter MEM_ADDR_WIDTH = {mem_addr_width}
                   )(
                     input [MEM_ADDR_WIDTH - 1 : 0] mem_write_addr,
                     input [MEM_WORD_WIDTH - 1 : 0] degree_out,
                     input [MEM_WORD_WIDTH - 1 : 0] x_out,
                     input [MEM_WORD_WIDTH - 1 : 0] y_out,
                     input                          arctan_en_out,
                     input                          clk,
                     input                          reset
                     );
   reg [MEM_WORD_WIDTH - 1 : 0]                     degree_out_reg [MEM_LENGTH - 1 : 0];
   reg [MEM_WORD_WIDTH - 1 : 0]                     x_out_reg [MEM_LENGTH - 1 : 0];
   reg [MEM_WORD_WIDTH - 1 : 0]                     y_out_reg [MEM_LENGTH - 1 : 0];
   reg                                              arctan_en_reg [MEM_LENGTH - 1 : 0];
   always @ (posedge clk)
     if (mem_write_addr < MEM_LENGTH) begin
        degree_out_reg[mem_write_addr] <= degree_out;
        x_out_reg[mem_write_addr] <= x_out;
        y_out_reg[mem_write_addr] <= y_out;
     end
endmodule
""".format(mem_addr_width = mem_addr_width, mem_length = 2 ** mem_addr_width)

with open("gen_mem_result.v", "w") as vsrc_mem_result_f:
    vsrc_mem_result_f.write(vsrc_mem_result)

vsrc_tb_verify = \
"""
`include "pipeline.v"
`include "gen_mem.v"
`include "gen_mem_result.v"
`timescale 1ns/1ns
`define SIM_TIME 118600

module gen_tb_verify#(
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
                  parameter FLIP_FLAG_WIDTH = 2,
                  parameter MEM_WORD_WIDTH = 16,
                  parameter MEM_LENGTH = {mem_length},
                  parameter MEM_ADDR_WIDTH = {mem_addr_width}
                  )();
   reg               clk;
   reg               reset;
   integer           fp;
   integer           i;
   initial begin
      clk = 0;
      reset = 1;
      #1 reset = 0;
      #5 reset = 1;
      # `SIM_TIME begin
         fp = $fopen("./degree_out_reg.txt","w");
         for (i = 0; i < MEM_LENGTH; i = i + 1)
           $fwrite(fp, "%b\\n", gen_tb_verify.gen_mem_result.degree_out_reg[i]);
         $fclose(fp);

         fp = $fopen("./x_out_reg.txt","w");
         for (i = 0; i < MEM_LENGTH; i = i + 1)
           $fwrite(fp, "%b\\n", gen_tb_verify.gen_mem_result.x_out_reg[i]);
         $fclose(fp);

         fp = $fopen("./y_out_reg.txt","w");
         for (i = 0; i < MEM_LENGTH; i = i + 1)
           $fwrite(fp, "%b\\n", gen_tb_verify.gen_mem_result.y_out_reg[i]);
         $fclose(fp);

         $finish;
      end
   end

   always #10 clk = !clk;
   wire [OUTPUT_WIDTH - 1 : 0] degree_out;
   wire [OUTPUT_WIDTH - 1 : 0] x_out;
   wire [OUTPUT_WIDTH - 1 : 0] y_out;
   wire [INPUT_WIDTH - 1 : 0]  degree_in;
   wire [FLIP_FLAG_WIDTH - 1 : 0]     sector_in;
   wire [FLIP_FLAG_WIDTH - 1 : 0]     sector_out;
   wire                                 arctan_en_in;
   wire                                 arctan_en_out;
   wire [INPUT_WIDTH - 1 : 0]  x_in;
   wire [INPUT_WIDTH - 1 : 0]  y_in;
   wire                                 valid_in;
   wire                                 valid_out;
   reg [MEM_ADDR_WIDTH - 1 : 0]         mem_read_addr;
   reg [MEM_ADDR_WIDTH - 1 : 0]         mem_write_addr;

   always @ (posedge clk or negedge reset)
     if (!reset) mem_read_addr <= 0;
     else
       mem_read_addr <= mem_read_addr + 1;
   always @ (posedge clk or negedge reset)
     if (!reset) mem_write_addr <= 0;
     else
       if (valid_out)
         mem_write_addr <= mem_write_addr + 1;

   assign valid_in = 1;
   pipeline pipeline(/*AUTOINST*/
                     // Outputs
                     .degree_out        (degree_out[OUTPUT_WIDTH-1:0]),
                     .x_out             (x_out[OUTPUT_WIDTH-1:0]),
                     .y_out             (y_out[OUTPUT_WIDTH-1:0]),
                     .sector_out        (sector_out[FLIP_FLAG_WIDTH-1:0]),
                     .arctan_en_out     (arctan_en_out),
                     .valid_out         (valid_out),
                     // Inputs
                     .clk               (clk),
                     .reset             (reset),
                     .degree_in         (degree_in[INPUT_WIDTH-1:0]),
                     .x_in              (x_in[INPUT_WIDTH-1:0]),
                     .y_in              (y_in[INPUT_WIDTH-1:0]),
                     .sector_in         (sector_in[FLIP_FLAG_WIDTH-1:0]),
                     .arctan_en_in      (arctan_en_in),
                     .valid_in          (valid_in));
   gen_mem gen_mem(/*AUTOINST*/
           // Outputs
           .degree_in                   (degree_in[MEM_WORD_WIDTH-1:0]),
           .x_in                        (x_in[MEM_WORD_WIDTH-1:0]),
           .y_in                        (y_in[MEM_WORD_WIDTH-1:0]),
           .arctan_en_in                (arctan_en_in),
           // Inputs
           .mem_read_addr               (mem_read_addr[MEM_ADDR_WIDTH-1:0]));
   gen_mem_result gen_mem_result(/*AUTOINST*/
                         // Inputs
                         .mem_write_addr        (mem_write_addr[MEM_ADDR_WIDTH-1:0]),
                         .degree_out            (degree_out[MEM_WORD_WIDTH-1:0]),
                         .x_out                 (x_out[MEM_WORD_WIDTH-1:0]),
                         .y_out                 (y_out[MEM_WORD_WIDTH-1:0]),
                         .arctan_en_out         (arctan_en_out),
                         .clk                   (clk),
                         .reset                 (reset));
endmodule // tb_verify
""".format(mem_addr_width = mem_addr_width, mem_length = 2 ** mem_addr_width)

with open("gen_tb_verify.v", "w") as vsrc_tb_verify_f:
    vsrc_tb_verify_f.write(vsrc_tb_verify)

with open("degree_in_reg.txt", "w") as vraw_degree_in_f:
    for i in range(512):
        vraw_degree_in_f.write((bin(int(i * 90 / 512 * 2 ** 8))[2:]).zfill(16) + '\n')

with open("x_in_reg.txt", "w") as vraw_x_in_f:
    for i in range(512):
        vraw_x_in_f.write('0000000100000000' +  '\n')

with open("y_in_reg.txt", "w") as vraw_y_in_f:
    for i in range(512):
        vraw_y_in_f.write((bin(int(i/512 * 2 ** 8))[2:]).zfill(16) + '\n')

with open("arctan_en_in_reg.txt", "w") as vraw_arctan_in_f:
    for i in range(512):
        vraw_arctan_in_f.write("0\n")
        # vraw_arctan_in_f.write(str(i%2) + '\n')


sp.run(["iverilog", "-o", "gen_tb_verify.vcd", "gen_tb_verify.v"])
sp.run(["vvp", "gen_tb_verify.vcd"])

print_line("degree_in_reg.txt")
print('-' * 80)
print_line("x_out_reg.txt")
# with open("x_in_reg.txt", "r") as vraw_x_out_f:
#     for line in vraw_x_out_f:
#         print(int(line, 2) * 2 ** (-8))
# print('-' * 80)
# with open("y_in_reg.txt", "r") as vraw_y_out_f:
#     for line in vraw_y_out_f:
#         print(int(line, 2) * 2 ** (-8))
# print('-' * 80)
