#!/bin/env python
# -*- coding: utf-8 -*-
import numpy as np
import subprocess as sp
import random
# from matplotlib import pyplot as plt

def print_line(fn):
    with open(fn, "r") as f:
        for line in f:
            print(line)

def int_bin16_str_2_dec(bin16_str):
    """Convert a 16 bit binary to decimal integer"""
    unsigned_dec = int(bin16_str, 2)
    if (bin16_str[0] == '0'):
        return unsigned_dec
    else:
        return - ((2 ** 16) - unsigned_dec)

def int_dec_2_bin16_str(dec):
    if (dec >= 0):
        return bin(dec)[2:].zfill(16)
    else:
        return bin(2 ** 16 + dec)[2:]

def dec_2_bin16_str(flt):
    """Convert a decimal float-point number to 16 bit binary"""
    dec = int(flt * (2 ** 8))
    return int_dec_2_bin16_str(dec)

def nearest(num, lst):
    """Find nearest number in sorted lst"""
    left_index = 0
    right_index = lst.size - 1
    while(True):
        if (right_index - left_index <= 1):
            break
        if (num < lst[int((left_index + right_index) / 2)]):
            right_index = int((left_index + right_index) / 2) - 1
        else:
            left_index = int((left_index + right_index) / 2)
    if (num - lst[left_index] > lst[right_index] - num):
        return lst[right_index]
    else:
        return lst[left_index]

def deg_2_rad(lst):
    return np.array([i * np.pi / 180 for i in lst])
def rad_2_deg(lst):
    return np.array([i / np.pi * 180 for i in lst])

mem_addr_width = 9
vsrc_mem = \
"""
module gen_mem#(
                parameter MEM_WORD_WIDTH = 16,
                parameter MEM_LENGTH = {mem_length},
                parameter MEM_ADDR_WIDTH = {mem_addr_width}
                )(
                  input [MEM_ADDR_WIDTH - 1 : 0]      mem_read_addr,
                  output reg [MEM_WORD_WIDTH - 1 : 0] degree_in,
                  output reg [MEM_WORD_WIDTH - 1 : 0] x_in,
                  output reg [MEM_WORD_WIDTH - 1 : 0] y_in,
                  output reg                          arctan_en_in
                  );
   reg [MEM_WORD_WIDTH - 1 : 0]                       degree_in_reg [MEM_LENGTH - 1 : 0];
   reg [MEM_WORD_WIDTH - 1 : 0]                       x_in_reg [MEM_LENGTH - 1 : 0];
   reg [MEM_WORD_WIDTH - 1 : 0]                       y_in_reg [MEM_LENGTH - 1 : 0];
   reg                                                arctan_en_in_reg [MEM_LENGTH - 1 : 0];
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
"""
module gen_mem_result#(
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
   reg [MEM_WORD_WIDTH - 1 : 0]                         degree_out_reg [MEM_LENGTH - 1 : 0];
   reg [MEM_WORD_WIDTH - 1 : 0]                         x_out_reg [MEM_LENGTH - 1 : 0];
   reg [MEM_WORD_WIDTH - 1 : 0]                         y_out_reg [MEM_LENGTH - 1 : 0];
   reg                                                  arctan_en_reg [MEM_LENGTH - 1 : 0];
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
`define SIM_TIME 20000

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
                      parameter FLIP_FLAG_WIDTH = 1,
                      parameter MEM_WORD_WIDTH = 16,
                      parameter MEM_LENGTH = {mem_length},
                      parameter MEM_ADDR_WIDTH = {mem_addr_width}
                      )();
   reg                          clk;
   reg                          reset;
   integer                      fp;
   integer                      i;
   initial begin
      $dumpfile("./gen_tb_verify.vcd");
      $dumpvars;
      clk = 0;
      reset = 1;
      valid_in = 0;
      #1 reset = 0;
      #5 reset = 1;
      valid_in = 1;
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
   wire [FLIP_FLAG_WIDTH - 1 : 0] flip_in;
   wire [FLIP_FLAG_WIDTH - 1 : 0] flip_out;
   wire                           arctan_en_in;
   wire                           arctan_en_out;
   wire [INPUT_WIDTH - 1 : 0]     x_in;
   wire [INPUT_WIDTH - 1 : 0]     y_in;
   reg                           valid_in;
   wire                           valid_out;
   reg [MEM_ADDR_WIDTH - 1 : 0]   mem_read_addr;
   reg [MEM_ADDR_WIDTH - 1 : 0]   mem_write_addr;

   always @ (posedge clk or negedge reset)
     if (!reset) mem_read_addr <= 0;
     else
       mem_read_addr <= mem_read_addr + 1;
   always @ (posedge clk or negedge reset)
     if (!reset) mem_write_addr <= 0;
     else
       if (valid_out)
         mem_write_addr <= mem_write_addr + 1;

   pipeline pipeline(/*AUTOINST*/
                     // Outputs
                     .degree_out        (degree_out[OUTPUT_WIDTH-1:0]),
                     .x_out             (x_out[OUTPUT_WIDTH-1:0]),
                     .y_out             (y_out[OUTPUT_WIDTH-1:0]),
                     .flip_out        (flip_out[FLIP_FLAG_WIDTH-1:0]),
                     .arctan_en_out     (arctan_en_out),
                     .valid_out         (valid_out),
                     // Inputs
                     .clk               (clk),
                     .reset             (reset),
                     .degree_in         (degree_in[INPUT_WIDTH-1:0]),
                     .x_in              (x_in[INPUT_WIDTH-1:0]),
                     .y_in              (y_in[INPUT_WIDTH-1:0]),
                     .flip_in         (flip_in[FLIP_FLAG_WIDTH-1:0]),
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

deg_avail = np.arctan(np.power(0.5, range(6)))
deg_perm = [np.array([i1, i2, i3, i4, i5, i6]) for i1 in [-1, 1] for i2 in [-1, 1] for i3 in [-1, 1] for i4 in [-1, 1] for i5 in [-1, 1] for i6 in [-1, 1]]
deg = np.array(sorted([np.dot(deg_avail, i) for i in deg_perm]))

test_deg_in = np.array(range(-90,91))
test_deg_expected = np.array([nearest(i, deg) for i in (test_deg_in * np.pi / 180)])
test_x_expected = np.cos(test_deg_expected)
test_y_expected = np.sin(test_deg_expected)
with open("degree_in_reg.txt", "w") as vraw_degree_in_f:
    for i in test_deg_in:
        vraw_degree_in_f.write(dec_2_bin16_str(i) + '\n')
with open("x_in_reg.txt", "w") as vraw_x_in_f:
    for i in range(181):
        vraw_x_in_f.write('0000000100000000' +  '\n')
with open("y_in_reg.txt", "w") as vraw_y_in_f:
    for i in range(181):
        vraw_y_in_f.write('0000000100000000' + '\n')
with open("arctan_en_in_reg.txt", "w") as vraw_arctan_in_f:
    for i in range(181):
        vraw_arctan_in_f.write("0\n")
sp.run(["iverilog", "-o", "gen_tb_verify.vvp", "gen_tb_verify.v"],stdout=sp.DEVNULL, stderr=sp.DEVNULL)
sp.run(["vvp", "gen_tb_verify.vvp"], stdout=sp.DEVNULL, stderr=sp.DEVNULL )
test_x_out = np.empty(181)
test_y_out = np.empty(181)
test_deg_out = np.empty(181)
with open("x_out_reg.txt", "r") as vraw_x_out_f:
    counter = 0
    for i in vraw_x_out_f:
        if (counter >= 181):
            break
        else:
            test_x_out[counter] = int_bin16_str_2_dec(i) / (2 ** 8)
            counter += 1
with open("y_out_reg.txt", "r") as vraw_y_out_f:
    counter = 0
    for i in vraw_y_out_f:
        if (counter >= 181):
            break
        else:
            test_y_out[counter] = int_bin16_str_2_dec(i) / (2 ** 8)
            counter += 1
with open("degree_out_reg.txt", "r") as vraw_degree_out_f:
    counter = 0
    for i in vraw_degree_out_f:
        if (counter >= 181):
            break
        else:
            test_deg_out[counter] = int_bin16_str_2_dec(i) / (2 ** 8)
            counter += 1
# ger upper bound of error
x_max_error = min([max(np.abs(test_x_expected - test_x_out)),0.1])
y_max_error = min([max(np.abs(test_y_expected - test_y_out)),0.1])
upper_bound = max([x_max_error, y_max_error])

# uncomment this to get a plot
# plt.plot(test_x_expected - test_x_out)
# plt.plot(test_y_expected - test_y_out)
# plt.plot(rad_2_deg(test_deg_expected) - test_deg_out)
# plt.show()

# random test
def test_sin_cos_rand():
    with open("x_in_reg.txt", "w") as vraw_x_in_f:
        for i in range(512):
            vraw_x_in_f.write('0000000100000000' +  '\n')
    with open("y_in_reg.txt", "w") as vraw_y_in_f:
        for i in range(512):
            vraw_y_in_f.write('0000000100000000' + '\n')
    with open("arctan_en_in_reg.txt", "w") as vraw_arctan_in_f:
        for i in range(512):
            vraw_arctan_in_f.write("0\n")
    test_deg_in = [(random.uniform(-1, 1) * 90) for i in range(512)]
    with open("degree_in_reg.txt", "w") as vraw_degree_in_f:
        for i in test_deg_in:
            vraw_degree_in_f.write(dec_2_bin16_str(i) + '\n')
    test_deg_expected = np.array([nearest(i, deg) for i in deg_2_rad(test_deg_in)])
    test_x_expected = np.cos(test_deg_expected)
    test_y_expected = np.sin(test_deg_expected)
    sp.run(["iverilog", "-o", "gen_tb_verify.vvp", "gen_tb_verify.v"],stdout=sp.DEVNULL, stderr=sp.DEVNULL)
    sp.run(["vvp", "gen_tb_verify.vvp"], stdout=sp.DEVNULL, stderr=sp.DEVNULL )
    test_x_out = np.empty(512)
    test_y_out = np.empty(512)
    with open("x_out_reg.txt", "r") as vraw_x_out_f:
        counter = 0
        for i in vraw_x_out_f:
            if (counter >= 512):
                break
            else:
                test_x_out[counter] = int_bin16_str_2_dec(i) / (2 ** 8)
                counter += 1
    with open("y_out_reg.txt", "r") as vraw_y_out_f:
        counter = 0
        for i in vraw_y_out_f:
            if (counter >= 512):
                break
            else:
                test_y_out[counter] = int_bin16_str_2_dec(i) / (2 ** 8)
                counter += 1
    return max([max(np.abs(test_y_expected - test_y_out)), max(np.abs(test_x_expected - test_x_out))])
for i in range(10):
    error = test_sin_cos_rand()
    if(error > upper_bound):
        print('Check failed, sin/cos error excceeds upper bound')
        print('upper bound is: {upperbound}'.format(upperbound = upper_bound))
        print('error is: {error}'.format(error = error))
        exit(1)

test_arctan_in = np.array(range(-45, 46))
test_deg_expected = np.array([nearest(i, deg) for i in np.arctan(test_arctan_in)])

with open("degree_in_reg.txt", "w") as vraw_degree_in_f:
    for i in range(91):
        vraw_degree_in_f.write('0000000000000000' + '\n')
with open("x_in_reg.txt", "w") as vraw_x_in_f:
    for i in range(91):
        vraw_x_in_f.write('0000000100000000' +  '\n')
with open("y_in_reg.txt", "w") as vraw_y_in_f:
    for i in test_arctan_in:
        vraw_y_in_f.write(dec_2_bin16_str(i) + '\n')
with open("arctan_en_in_reg.txt", "w") as vraw_arctan_in_f:
    for i in range(91):
        vraw_arctan_in_f.write("1\n")
sp.run(["iverilog", "-o", "gen_tb_verify.vvp", "gen_tb_verify.v"],stdout=sp.DEVNULL, stderr=sp.DEVNULL)
sp.run(["vvp", "gen_tb_verify.vvp"], stdout=sp.DEVNULL, stderr=sp.DEVNULL )
test_deg_out = np.empty(91)
with open("degree_out_reg.txt", "r") as vraw_degree_out_f:
    counter = 0
    for i in vraw_degree_out_f:
        if (counter >= 91):
            break
        else:
            test_deg_out[counter] = int_bin16_str_2_dec(i) / (2 ** 8)
            counter += 1
upper_bound = min([max(abs(rad_2_deg(test_deg_expected) - test_deg_out)) + 1, 4])
# uncomment this to get a plot
# plt.plot(test_deg_expected)
# plt.plot(deg_2_rad(test_deg_out))
# plt.show()

def test_arctan_rand():
    with open("x_in_reg.txt", "w") as vraw_x_in_f:
        for i in range(512):
            vraw_x_in_f.write('0000000100000000' +  '\n')
    with open("degree_in_reg.txt", "w") as vraw_degree_in_f:
        for i in range(512):
            vraw_degree_in_f.write('0000000000000000' + '\n')
    test_arctan_in = [(random.uniform(-1, 1) * 90) for i in range(512)]
    with open("arctan_en_in_reg.txt", "w") as vraw_arctan_in_f:
        for i in range(512):
            vraw_arctan_in_f.write("1\n")
    with open("y_in_reg.txt", "w") as vraw_y_in_f:
        for i in test_arctan_in:
            vraw_y_in_f.write(dec_2_bin16_str(i) + '\n')
    test_deg_expected = np.array([nearest(i, deg) for i in np.arctan(test_arctan_in)])
    sp.run(["iverilog", "-o", "gen_tb_verify.vvp", "gen_tb_verify.v"],stdout=sp.DEVNULL, stderr=sp.DEVNULL)
    sp.run(["vvp", "gen_tb_verify.vvp"], stdout=sp.DEVNULL, stderr=sp.DEVNULL )
    test_deg_out = np.empty(512)
    with open("degree_out_reg.txt", "r") as vraw_degree_out_f:
        counter = 0
        for i in vraw_degree_out_f:
            if (counter >= 512):
                break
            else:
                test_deg_out[counter] = int_bin16_str_2_dec(i) / (2 ** 8)
                counter += 1
    return max(abs(test_deg_out - rad_2_deg(test_deg_expected)))
for i in range(10):
    error = test_arctan_rand()
    if(error > upper_bound):
        print('Check failed, arctan error excceeds upper bound')
        print('upper bound is: {upperbound}'.format(upperbound = upper_bound))
        print('error is: {error}'.format(error = error))
        exit(1)

# upper_bound = min([0.1, max(abs(test_deg_expected - deg_2_rad(test_deg_out)))])

# ---------------------------------------------------------------------------- #
# # Manual Test 1, pipeline cos, sin test
# with open("degree_in_reg.txt", "w") as vraw_degree_in_f:
#     for i in range(180):
#         vraw_degree_in_f.write(dec_2_bin16_str(i - 90) + '\n')
# with open("x_in_reg.txt", "w") as vraw_x_in_f:
#     for i in range(512):
#         vraw_x_in_f.write('0000000100000000' +  '\n')
# with open("y_in_reg.txt", "w") as vraw_y_in_f:
#     for i in range(512):
#         vraw_y_in_f.write((bin(int(i/512 * 2 ** 8))[2:]).zfill(16) + '\n')
# with open("arctan_en_in_reg.txt", "w") as vraw_arctan_in_f:
#     for i in range(512):
#         vraw_arctan_in_f.write("0\n")
#         # vraw_arctan_in_f.write(str(i%2) + '\n')


# sp.run(["iverilog", "-o", "gen_tb_verify.vvp", "gen_tb_verify.v"],stdout=sp.DEVNULL, stderr=sp.DEVNULL)
# sp.run(["vvp", "gen_tb_verify.vvp"], stdout=sp.DEVNULL, stderr=sp.DEVNULL )

# sim_x_result = np.empty(180)
# sim_y_result = np.empty(180)
# with open("x_out_reg.txt", "r") as vraw_x_out_f:
#     counter = 0
#     for i in vraw_x_out_f:
#         if (counter >= 180):
#             break
#         else:
#             sim_x_result[counter] = int_bin16_str_2_dec(i) / (2 ** 8)
#             counter += 1
# with open("y_out_reg.txt", "r") as vraw_y_out_f:
#     counter = 0
#     for i in vraw_y_out_f:
#         if (counter >= 180):
#             break
#         else:
#             sim_y_result[counter] = int_bin16_str_2_dec(i) / (2 ** 8)
#             counter += 1

# plt.plot(np.cos(deg), np.sin(deg), marker='s', linestyle='None')
# plt.plot(np.cos(np.array(range(180)) * 2 * np.pi / 180), np.sin(np.array(range(180)) * 2 * np.pi / 180))
# plt.plot(sim_x_result, sim_y_result, marker='o', linestyle='None')
# plt.show()

# # Manual test 2, arctan
# with open("degree_in_reg.txt", "w") as vraw_degree_in_f:
#     for i in range(180):
#         vraw_degree_in_f.write(dec_2_bin16_str(i - 90) + '\n')
# with open("x_in_reg.txt", "w") as vraw_x_in_f:
#     for i in range(100):
#         vraw_x_in_f.write('0000000100000000' +  '\n')
# with open("y_in_reg.txt", "w") as vraw_y_in_f:
#     for i in range(160):
#         vraw_y_in_f.write(dec_2_bin16_str(np.tan((i - 80) / 180 * np.pi)) + '\n')
# with open("arctan_en_in_reg.txt", "w") as vraw_arctan_in_f:
#     for i in range(512):
#         vraw_arctan_in_f.write("1\n")
# sp.run(["iverilog", "-o", "gen_tb_verify.vvp", "gen_tb_verify.v"],stdout=sp.DEVNULL, stderr=sp.DEVNULL)
# sp.run(["vvp", "gen_tb_verify.vvp"], stdout=sp.DEVNULL, stderr=sp.DEVNULL )

# sim_degree_result = np.empty(160)
# with open("degree_out_reg.txt", "r") as vraw_deg_out_f:
#     counter = 0
#     for i in vraw_deg_out_f:
#         if (counter >= 160):
#             break
#         else:
#             sim_degree_result[counter] = int_bin16_str_2_dec(i) / (2 ** 8)
#             counter += 1
# print(sim_degree_result)
# plt.plot(np.cos(deg), np.sin(deg), marker='s', linestyle='None')
# plt.plot(np.cos(np.array(range(180)) * 2 * np.pi / 180), np.sin(np.array(range(180)) * 2 * np.pi / 180))
# plt.plot(np.cos(sim_degree_result * np.pi / 180), np.sin(sim_degree_result * np.pi / 180), marker='o', linestyle='None')
# plt.show()
