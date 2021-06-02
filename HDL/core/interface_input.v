module interface_input #(
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
                         parameter SECTOR_FLAG_WIDTH = 2,
                          parameter                                                                S1=2'b00,
                          parameter                                                                S2=2'b10,
                          parameter                                                                S3=2'b11,
                          parameter                                                                S4=2'b01
                         )(
                           input wire                                       clk,
                           input wire                                       rst,
                           input wire signed [UNSIGNED_INPUT_WIDTH - 1 : 0] degree_in_interface,
                           input wire arctan_en_in_interface,
                           input wire valid_in_interface,
                           input wire [UNSIGNED_INPUT_WIDTH - 1 : 0]   x_in_interface,
                           input wire [UNSIGNED_INPUT_WIDTH - 1 : 0]   y_in_interface,

                           output reg [UNSIGNED_OUTPUT_WIDTH - 1 : 0]       degree_in,

                            output wire [UNSIGNED_INPUT_WIDTH - 1 : 0]   x_in,
                            output wire [UNSIGNED_INPUT_WIDTH - 1 : 0]   y_in,

                            output wire [SECTOR_FLAG_WIDTH - 1 : 0]      sector_in,
                            output wire                                  arctan_en_in,
                            output wire                                  valid_in
                           );
   parameter                                                                ANGLE_N90=-16'sd90;
   parameter                                                                ANGLE_P90=16'sd90;
   parameter                                                                ANGLE_P180=16'sd180;

   // degree_in_interface range: from -180° to 180°

   assign sector_in[0]=(degree_in_interface>0)?0:1;
   assign sector_in[1]=(degree_in_interface>ANGLE_N90)?((degree_in_interface<ANGLE_P90)?0:1):(1);

   assign x_in=x_in_interface;
   assign y_in=y_in_interface;

   assign arctan_en_in=arctan_en_in_interface;
   assign valid_in=valid_in_interface;

   always @(*) begin
      case (sector_in)
        S1: degree_in=degree_in_interface;
        S2: degree_in=degree_in_interface+ANGLE_N90;
        S3: degree_in=degree_in_interface+ANGLE_P180;
        S4: degree_in=degree_in_interface+ANGLE_P90;
      endcase   
   end


endmodule //interface
