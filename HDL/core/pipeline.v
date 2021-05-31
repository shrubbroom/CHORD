module pipeline#(
                 parameter UNSIGNED_INPUT_WIDTH = 16,
                 parameter UNSIGNED_OUTPUT_WIDTH = 16,
                 parameter UNSIGNED_INPUT_INT_WIDTH = 7,
                 parameter UNSIGNED_INPUT_FRAC_WIDTH = 8,
                 parameter UNSIGNED_OUTPUT_INT_WIDTH = 7,
                 parameter UNSIGNED_OUTPUT_FRAC_WIDTH = 8,
                 parameter ITERATION_NUMBER = 6,
                 parameter ITERATION_WORD_WIDTH = 32,
                 parameter ITERATION_WORD_INT_WIDTH = 10,
                 parameter ITERATION_WORD_FRAC_WIDTH = 22
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

   wire [ITERATION_WORD_WIDTH - 1 : 0] degree_mem [ITERATION_NUMBER - 1 : 0];
   assign degree_mem[0] = 32'b00001011010000000000000000000000;
   assign degree_mem[1] = 32'b00000110101001000010100111001100;
   assign degree_mem[2] = 32'b00000011100000100101000111010000;
   assign degree_mem[3] = 32'b00000001110010000000000001000100;
   assign degree_mem[4] = 32'b00000000111001001110001010101001;
   assign degree_mem[5] = 32'b00000000011100101000110111100101;

   reg [ITERATION_WORD_WIDTH - 1 : 0] degree_reg [ITERATION_NUMBER : 0];
   reg [ITERATION_WORD_WIDTH - 1 : 0] degree_approx_reg [ITERATION_NUMBER : 0];
   reg [ITERATION_WORD_WIDTH - 1 : 0] x_reg [ITERATION_NUMBER : 0];
   reg [ITERATION_WORD_WIDTH - 1 : 0] y_reg [ITERATION_NUMBER : 0];

   always @ *
     begin
        degree_reg[0][ITERATION_WORD_FRAC_WIDTH + UNSIGNED_INPUT_INT_WIDTH - 1 : ITERATION_WORD_FRAC_WIDTH - UNSIGNED_INPUT_FRAC_WIDTH] = degree_in;
        degree_reg[0][ITERATION_WORD_WIDTH - 1 : ITERATION_WORD_FRAC_WIDTH + UNSIGNED_INPUT_INT_WIDTH] = 0;
        degree_reg[0][ITERATION_WORD_FRAC_WIDTH - UNSIGNED_INPUT_FRAC_WIDTH - 1 : 0] = 0;
        degree_approx_reg[0] = 0;
        x_reg[0] = 32'b00000000010000000000000000000000;
        y_reg[0] = 0;
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
              end
              else begin
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
                 degree_reg[i] <= degree_reg[i - 1];
              end
           end
        end
   endgenerate

   /*
    k = 0.1001101101111011011001111101010111101100101100001111100111101011001100011000010111000110000010110101
    */
   wire [ITERATION_WORD_WIDTH * 2 - 1 : 0] k_reg;
   wire [ITERATION_WORD_WIDTH * 2 - 1 : 0] x_enlarge_reg;
   wire [ITERATION_WORD_WIDTH * 2 - 1 : 0] y_enlarge_reg;
   assign k_reg = 64'b0000000000000000000000000000000000000000001001101101111011011001;
   assign x_enlarge_reg[ITERATION_WORD_WIDTH * 2 - 1 : ITERATION_WORD_WIDTH] = 0;
   assign x_enlarge_reg[ITERATION_WORD_WIDTH - 1 : 0] = x_reg[ITERATION_NUMBER];
   assign y_enlarge_reg[ITERATION_WORD_WIDTH * 2 - 1 : ITERATION_WORD_WIDTH] = 0;
   assign y_enlarge_reg[ITERATION_WORD_WIDTH - 1 : 0] = y_reg[ITERATION_NUMBER];


   reg [ITERATION_WORD_WIDTH * 2 - 1 : 0] x_correct_reg;
   reg [ITERATION_WORD_WIDTH * 2 - 1 : 0] y_correct_reg;
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
endmodule // pipeline
