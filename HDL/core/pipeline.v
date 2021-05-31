module pipeline#(
                 parameter UNSIGNED_INPUT_WIDTH = 16,
                 parameter UNSIGNED_OUTPUT_WIDTH = 16,
                 parameter UNSIGNED_INPUT_INT_WIDTH = 7,
                 parameter UNSIGNED_INPUT_FRAC_WIDTH = 8,
                 parameter UNSIGNED_OUTPUT_INT_WIDTH = 7,
                 parameter UNSIGNED_OUTPUT_FRAC_WIDTH = 8,
                 parameter ITERATION_NUMBER = 6,
                 parameter ITERATION_WORD_WIDTH = 33,
                 parameter ITERATION_WORD_INT_WIDTH = 7,
                 parameter ITERATION_WORD_FRAC_WIDTH = 26
                 )(
                   input wire                         clk,
                   input wire                         reset,
                   input wire [UNSIGNED_INPUT_WIDTH - 1 : 0]   degree_in,
                   output wire [UNSIGNED_OUTPUT_WIDTH - 1 : 0] degree_out,
                   output wire [UNSIGNED_OUTPUT_WIDTH - 1 : 0] x_out,
                   output wire [UNSIGNED_OUTPUT_WIDTH - 1 : 0] y_out

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

   wire [ITERATION_NUMBER - 1 : 0][ITERATION_WORD_WIDTH - 1 : 0] degree_mem;
   assign degree_mem[0] = 010110100000000000000000000000000;
   assign degree_mem[1] = 001101010010000101001110011000110;
   assign degree_mem[2] = 000111000001001010001110100000001;
   assign degree_mem[3] = 000011100100000000000010001001001;
   assign degree_mem[4] = 000001110010011100010101010011001;
   assign degree_mem[5] = 000000111001010001101111001010011;

   reg [ITERATION_NUMBER - 1 : -1][ITERATION_WORD_WIDTH - 1 : 0] degree_reg;
   reg [ITERATION_NUMBER - 1 : -1][ITERATION_WORD_WIDTH - 1 : 0] degree_approx_reg;
   reg [ITERATION_NUMBER - 1 : -1][ITERATION_WORD_WIDTH - 1 : 0] x_reg;
   reg [ITERATION_NUMBER - 1 : -1][ITERATION_WORD_WIDTH - 1 : 0] y_reg;

   always @ *
     begin
        degree_reg[-1][ITERATION_WORD_FRAC_WIDTH + UNSIGNED_INPUT_INT_WIDTH - 1 : ITERATION_WORD_FRAC_WIDTH - UNSIGNED_INPUT_FRAC_WIDTH] = degree_in;
        // degree_reg[-1][ITERATION_WORD_WIDTH - 1 : ITERATION_WORD_FRAC_WIDTH + UNSIGNED_INPUT_INT_WIDTH] = 0;
        degree_reg[-1][ITERATION_WORD_FRAC_WIDTH - UNSIGNED_INPUT_FRAC_WIDTH - 1 : 0] = 0;
        degree_approx_reg[-1] = 0;
        x_reg[-1] = 0000000100000000;
        y_reg[-1] = 0;
     end

   generate
      genvar i;
      for( i = 0; i < ITERATION_NUMBER; i = i + 1)
        begin
           always @ (posedge clk or negedge reset) begin
              if(!reset) begin
                 degree_reg[i] <= 0;
                 degree_approx_reg[i] <= 0;
                 x_reg[i] <= 0;
                 y_reg[i] <= 0;
              end
              else begin
                 if (degree_approx_reg[i - 1] > degree_reg[i - 1]) begin
                    degree_approx_reg[i] <= degree_approx_reg[i - 1] - degree_mem[i];
                    x_reg[i] <= x_reg[i - 1] + (y_reg[i - 1] >> (i + 1));
                    y_reg[i] <= y_reg[i - 1] - (x_reg[i - 1] >> (i + 1));
                 end
                 else begin
                    degree_approx_reg[i] <= degree_approx_reg[i - 1] + degree_mem[i];
                    x_reg[i] <= x_reg[i - 1] - (y_reg[i - 1] >> (i + 1));
                    y_reg[i] <= y_reg[i - 1] + (x_reg[i - 1] >> (i + 1));
                 end
                 degree_reg[i] <= degree_reg[i - 1];
              end
           end
        end
   endgenerate

   /*
    k = 0.1001101101111011011001111101010111101100101100001111100111101011001100011000010111000110000010110101
    */
   wire [ITERATION_WORD_WIDTH - 1 : 0] k_reg;
   assign k_reg[ITERATION_WORD_WIDTH - 1 : 0] = 000000010011011011110110110011111;

   reg [ITERATION_WORD_WIDTH - 1 : 0] x_correct_reg;
   reg [ITERATION_WORD_WIDTH - 1 : 0] y_correct_reg;
   always @ * begin
      x_correct_reg = x_reg[ITERATION_NUMBER - 1] * k_reg;
      y_correct_reg = y_reg[ITERATION_NUMBER - 1] * k_reg;
   end

   assign degree_out[UNSIGNED_OUTPUT_WIDTH - 1 : 0]
     = degree_approx_reg[ITERATION_NUMBER - 1]
       [ITERATION_WORD_FRAC_WIDTH + UNSIGNED_INPUT_INT_WIDTH - 1 : ITERATION_WORD_FRAC_WIDTH - UNSIGNED_INPUT_FRAC_WIDTH];
   assign x_out[UNSIGNED_OUTPUT_WIDTH - 1 : 0]
     = x_correct_reg
       [ITERATION_WORD_FRAC_WIDTH + UNSIGNED_INPUT_INT_WIDTH - 1 : ITERATION_WORD_FRAC_WIDTH - UNSIGNED_INPUT_FRAC_WIDTH];
   assign y_out[UNSIGNED_OUTPUT_WIDTH - 1 : 0]
     = y_correct_reg
       [ITERATION_WORD_FRAC_WIDTH + UNSIGNED_INPUT_INT_WIDTH - 1 : ITERATION_WORD_FRAC_WIDTH - UNSIGNED_INPUT_FRAC_WIDTH];
endmodule // pipeline
