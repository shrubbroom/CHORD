module pipeline#(
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
                   input wire                                  clk,
                   input wire                                  reset,
                   input wire [UNSIGNED_INPUT_WIDTH - 1 : 0]   degree_in,

                   input wire [UNSIGNED_INPUT_WIDTH - 1 : 0]   x_in,
                   input wire [UNSIGNED_INPUT_WIDTH - 1 : 0]   y_in,

                   input wire [SECTOR_FLAG_WIDTH - 1 : 0]      sector_in,
                   input wire                                  arctan_en_in,
                   output wire [UNSIGNED_OUTPUT_WIDTH - 1 : 0] degree_out,
                   output wire [UNSIGNED_OUTPUT_WIDTH - 1 : 0] x_out,
                   output wire [UNSIGNED_OUTPUT_WIDTH - 1 : 0] y_out,
                   output wire [SECTOR_FLAG_WIDTH - 1 : 0]     sector_out,
                   output wire                                 arctan_en_out
                   );
   /*
    TAN(*)  | DEG         | DEG (BIN)
    1       | 45          | 101101.000000000000000000000000000000000000000000000000000000000000000000
    0.5     | 26.56505118 | 11010.1001000010100111001100011010011000011101110000111100111111101001101
    0.25    | 14.03624347 | 1110.00001001010001110100000001111101011100000001011011110111100000011111
    0.125   | 7.123016349 | 111.001000000000000100010010010010011111111110100000101101101010101101100
    0.0625  | 3.576334375 | 11.1001001110001010101001100100110000101100100110011101110011101111000111
    0.03125 | 1.789910608 | 1.11001010001101111001010011100101001011100010101001111001001110011100110
    */

   wire [ITERATION_WORD_WIDTH - 1 : 0]                         degree_mem [ITERATION_NUMBER - 1 : 0];
   // degree_mem[0] = 32'b000000101101 00000000000000000000;
   // degree_mem[1] = 32'b000000011010 10010000101001110011;
   // degree_mem[2] = 32'b000000001110 00001001010001110100;
   // degree_mem[3] = 32'b000000000111 00100000000000010001;
   // degree_mem[4] = 32'b000000000011 10010011100010101010;
   // degree_mem[5] = 32'b000000000001 11001010001101111001;
   assign degree_mem[0] = 32'b00000010110100000000000000000000;
   assign degree_mem[1] = 32'b00000001101010010000101001110011;
   assign degree_mem[2] = 32'b00000000111000001001010001110100;
   assign degree_mem[3] = 32'b00000000011100100000000000010001;
   assign degree_mem[4] = 32'b00000000001110010011100010101010;
   assign degree_mem[5] = 32'b00000000000111001010001101111001;


   reg [ITERATION_WORD_WIDTH - 1 : 0]                          degree_reg [ITERATION_NUMBER : 0];
   reg [ITERATION_WORD_WIDTH - 1 : 0]                          degree_approx_reg [ITERATION_NUMBER : 0];
   reg signed [ITERATION_WORD_WIDTH - 1 : 0]                          x_reg [ITERATION_NUMBER : 0];
   reg signed [ITERATION_WORD_WIDTH - 1 : 0]                          y_reg [ITERATION_NUMBER : 0];

   reg                                                         arctan_en_reg [ITERATION_NUMBER : 0];
   reg [SECTOR_FLAG_WIDTH - 1 : 0]                             sector_reg [ITERATION_NUMBER : 0];

   always @ *
     begin
        degree_reg[0][ITERATION_WORD_FRAC_WIDTH + UNSIGNED_INPUT_INT_WIDTH - 1 : ITERATION_WORD_FRAC_WIDTH - UNSIGNED_INPUT_FRAC_WIDTH] = degree_in;
        degree_reg[0][ITERATION_WORD_WIDTH - 1 : ITERATION_WORD_FRAC_WIDTH + UNSIGNED_INPUT_INT_WIDTH] = 0;
        degree_reg[0][ITERATION_WORD_FRAC_WIDTH - UNSIGNED_INPUT_FRAC_WIDTH - 1 : 0] = 0;
        degree_approx_reg[0] = 0;
        arctan_en_reg[0] = arctan_en_in;
        sector_reg[0] = sector_in;
        if (arctan_en_in) begin
           x_reg[0][ITERATION_WORD_FRAC_WIDTH + UNSIGNED_INPUT_INT_WIDTH - 1 : ITERATION_WORD_FRAC_WIDTH - UNSIGNED_INPUT_FRAC_WIDTH] = x_in;
           x_reg[0][ITERATION_WORD_WIDTH - 1 : ITERATION_WORD_FRAC_WIDTH + UNSIGNED_INPUT_INT_WIDTH] = 0;
           x_reg[0][ITERATION_WORD_FRAC_WIDTH - UNSIGNED_INPUT_FRAC_WIDTH - 1 : 0] = 0;
           y_reg[0][ITERATION_WORD_FRAC_WIDTH + UNSIGNED_INPUT_INT_WIDTH - 1 : ITERATION_WORD_FRAC_WIDTH - UNSIGNED_INPUT_FRAC_WIDTH] = y_in;
           y_reg[0][ITERATION_WORD_WIDTH - 1 : ITERATION_WORD_FRAC_WIDTH + UNSIGNED_INPUT_INT_WIDTH] = 0;
           y_reg[0][ITERATION_WORD_FRAC_WIDTH - UNSIGNED_INPUT_FRAC_WIDTH - 1 : 0] = 0;
        end
        else begin
           // x_reg[0] = 32'b000000000001 00000000000000000000;
           x_reg[0] = 32'b00000000000100000000000000000000;
           y_reg[0] = 0;
        end
     end

   generate
      genvar i;
      for(i = 1; i < ITERATION_NUMBER + 1; i = i + 1)
        begin
           always @ (posedge clk or negedge reset) begin
              if(!reset) begin
                 degree_reg[i] <= 0;
                 degree_approx_reg[i] <= 0;
                 x_reg[i] <= 0;
                 y_reg[i] <= 0;
                 arctan_en_reg[i] <= 0;
                 sector_reg[i] <= 0;
              end
              else
                if (arctan_en_reg[i - 1]) begin
                   arctan_en_reg[i] <= 1;
                   if (y_reg[i - 1] > 0) begin
                      degree_approx_reg[i] <= degree_approx_reg[i - 1] + degree_mem[i - 1];
                      x_reg[i] <= x_reg[i - 1] + (y_reg[i - 1] >> (i - 1));
                      y_reg[i] <= y_reg[i - 1] - (x_reg[i - 1] >> (i - 1));
                   end
                   else begin
                      degree_approx_reg[i] <= degree_approx_reg[i - 1] - degree_mem[i - 1];
                      x_reg[i] <= x_reg[i - 1] - (y_reg[i - 1] >> (i - 1));
                      y_reg[i] <= y_reg[i - 1] + (x_reg[i - 1] >> (i - 1));
                   end
                end
                else begin
                   arctan_en_reg[i] <= 0;
                   if (degree_approx_reg[i - 1] > degree_reg[i - 1]) begin
                      degree_approx_reg[i] <= degree_approx_reg[i - 1] - degree_mem[i - 1];
                      x_reg[i] <= x_reg[i - 1] + (y_reg[i - 1] >> (i - 1));
                      y_reg[i] <= y_reg[i - 1] - (x_reg[i - 1] >> (i - 1));
                   end
                   else begin
                      degree_approx_reg[i] <= degree_approx_reg[i - 1] + degree_mem[i - 1];
                      x_reg[i] <= x_reg[i - 1] - (y_reg[i - 1] >> (i - 1));
                      y_reg[i] <= y_reg[i - 1] + (x_reg[i - 1] >> (i - 1));
                   end
                end
              degree_reg[i] <= degree_reg[i - 1];
              sector_reg[i] <= sector_reg[i - 1];
           end
        end
   endgenerate

   /*
    k = 0.1001101101111011011001111101010111101100101100001111100111101011001100011000010111000110000010110101
    */
   wire [ITERATION_WORD_WIDTH * 2 - 1 : 0] k_reg;
   wire [ITERATION_WORD_WIDTH * 2 - 1 : 0] x_enlarge_reg;
   wire [ITERATION_WORD_WIDTH * 2 - 1 : 0] y_enlarge_reg;
   // k_reg = 64'b00000000000000000000000000000000 000000000000 10011011011110110110;
   assign k_reg = 64'b0000000000000000000000000000000000000000000010011011011110110110;
   assign x_enlarge_reg[ITERATION_WORD_WIDTH * 2 - 1 : ITERATION_WORD_WIDTH] = 0;
   assign x_enlarge_reg[ITERATION_WORD_WIDTH - 1 : 0] = x_reg[ITERATION_NUMBER];
   assign y_enlarge_reg[ITERATION_WORD_WIDTH * 2 - 1 : ITERATION_WORD_WIDTH] = 0;
   assign y_enlarge_reg[ITERATION_WORD_WIDTH - 1 : 0] = y_reg[ITERATION_NUMBER];


   reg [ITERATION_WORD_WIDTH * 2 - 1 : 0]  x_correct_reg;
   reg [ITERATION_WORD_WIDTH * 2 - 1 : 0]  y_correct_reg;
   always @ * begin
      x_correct_reg = (x_enlarge_reg * k_reg) >> 22;
      y_correct_reg = (y_enlarge_reg * k_reg) >> 22;
   end

   assign degree_out[UNSIGNED_OUTPUT_WIDTH - 1 : 0]
     = degree_approx_reg[ITERATION_NUMBER]
       [ITERATION_WORD_FRAC_WIDTH + UNSIGNED_INPUT_INT_WIDTH - 1 : ITERATION_WORD_FRAC_WIDTH - UNSIGNED_INPUT_FRAC_WIDTH];
   assign x_out[UNSIGNED_OUTPUT_WIDTH - 1 : 0]
     = x_correct_reg
       [ITERATION_WORD_FRAC_WIDTH + UNSIGNED_INPUT_INT_WIDTH - 1 : ITERATION_WORD_FRAC_WIDTH - UNSIGNED_INPUT_FRAC_WIDTH];
   assign y_out[UNSIGNED_OUTPUT_WIDTH - 1 : 0]
     = y_correct_reg
       [ITERATION_WORD_FRAC_WIDTH + UNSIGNED_INPUT_INT_WIDTH - 1 : ITERATION_WORD_FRAC_WIDTH - UNSIGNED_INPUT_FRAC_WIDTH];
   assign arctan_en_out
     = arctan_en_reg[ITERATION_NUMBER];
   assign sector_out
     =sector_reg[ITERATION_NUMBER];
endmodule // pipeline
