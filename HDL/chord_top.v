`include "ahb_lite_cordic.v"
`include "fifo.v"
`include "./core/ex_top.v"
module chord_top(
                 input [31:0]    HADDR,
                 input [2:0]     HBURST,
                 input           HCLK,
                 input           HMASTLOCK,
                 input [3:0]     HPROT,
                 input           HREADY,
                 input           HRESETn,
                 input           HSEL,
                 input [2:0]     HSIZE,
                 input [1:0]     HTRANS,
                 input [31:0]    HWDATA,
                 input           HWRITE,
                 output [31:0]   HRDATA,
                 output          HREADYOUT,
                 output          HRESP
                 );
   wire                          clk;
   wire                          reset;
   assign clk = HCLK;
   assign reset = HRESETn;
   wire                          empty;
   wire [31:0]                   in_interface;
   wire [31:0]                   out_fifo;
   wire [31:0]                   out_interface;
   wire                          read_fifo_en;
   wire                          valid_in_interface;
   wire                          valid_out_interface;
   fifo fifo(.out_fifo                  (out_fifo[31:0]),
             .empty                     (empty),
             .clk                       (clk),
             .reset                     (reset),
             .read_fifo_en              (read_fifo_en),
             .valid_out_interface       (valid_out_interface),
             .out_interface             (out_interface[31:0]));
   ahb_lite_cordic ahb_lite_cordic(.HREADYOUT           (HREADYOUT),
                                   .HRESP               (HRESP),
                                   .HRDATA              (HRDATA[31:0]),
                                   .in_interface        (in_interface[31:0]),
                                   .valid_in_interface  (valid_in_interface),
                                   .read_fifo_en        (read_fifo_en),
                                   .HSEL                (HSEL),
                                   .HCLK                (HCLK),
                                   .HRESETn             (HRESETn),
                                   .HADDR               (HADDR[31:0]),
                                   .HBURST              (HBURST[2:0]),
                                   .HMASTLOCK           (HMASTLOCK),
                                   .HPROT               (HPROT[3:0]),
                                   .HSIZE               (HSIZE[2:0]),
                                   .HTRANS              (HTRANS[1:0]),
                                   .HWRITE              (HWRITE),
                                   .HREADY              (HREADY),
                                   .HWDATA              (HWDATA[31:0]),
                                   .valid_out_interface (valid_out_interface),
                                   .out_fifo            (out_fifo[31:0]),
                                   .empty               (empty));
   ex_top ex_top(.out_interface         (out_interface[31:0]),
                 .valid_out_interface   (valid_out_interface),
                 .clk                   (clk),
                 .in_interface          (in_interface[31:0]),
                 .reset                 (reset),
                 .valid_in_interface    (valid_in_interface));
endmodule // chord_top
