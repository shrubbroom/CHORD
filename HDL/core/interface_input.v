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
                         parameter SECTOR_FLAG_WIDTH = 2
                         )(
                           input wire                                       clk,
                           input wire                                       rst,
                           input wire signed [UNSIGNED_INPUT_WIDTH - 1 : 0] degree_in,
                           output reg [UNSIGNED_OUTPUT_WIDTH - 1 : 0]       degree_out,
                           output wire [1:0]                                quadrant
                           );

   parameter                                                                S1=2'b00;
   parameter                                                                S2=2'b10;
   parameter                                                                S3=2'b11;
   parameter                                                                S4=2'b01;

   parameter                                                                ANGLE_N90=-16'sd90;
   parameter                                                                ANGLE_P90=16'sd90;
   parameter                                                                ANGLE_P180=16'sd180;

   // degree_in range: from -180° to 180°

   assign quadrant[0]=(degree_in>0)?0:1;
   assign quadrant[1]=(degree_in>ANGLE_N90)?((degree_in<ANGLE_P90)?0:1):(1);

   always @(*) begin
      case (quadrant)
        S1: degree_out=degree_in;
        S2: degree_out=degree_in+ANGLE_N90;
        S3: degree_out=degree_in+ANGLE_P180;
        S4: degree_out=degree_in+ANGLE_P90;
      endcase   
   end


endmodule //interface
