module fifo(input clk,rst,read_fifo_en,valid_out_interface,
            input  [31:0]  out_interface,
            output [31:0] out_fifo,
            output 	     empty);
reg [31:0] 		     mem [15:0];
reg [4:0] 		     rp,wp; //read pointer, write pointer
reg 			     full_in,empty_in,half_full_in,overflow_in;

wire full,overflow,half_full;

assign full=full_in;
assign empty=empty_in;
assign half_full=half_full_in;
assign overflow=overflow_in;
integer 		     i;

assign out_fifo=mem[rp[3:0]];

always@(posedge clk or negedge rst) begin
    if (!rst) begin
        for(i=16;i!=0;i=i-1)
          mem[i-1]<=0;
        rp<=0;
        wp<=0;
        empty_in<=1;
        full_in<=0;
        half_full_in<=0;
        overflow_in<=0;
        // out_fifo<=0;
      end

    else begin

        //write
        if (valid_out_interface && ~full_in) begin
            mem[wp[3:0]]<=out_interface;
            wp<=wp+1;
          end

        //read
        if(read_fifo_en && ~empty_in) begin
            // out_fifo<=mem[rp[3:0]];
            rp<=rp+1;
          end

      end // else rst
  end // always@ (posedge clk or negedge rst)

always @(*) begin
    //determine signal full and empty and half_full
    if(wp-rp==5'b10000)
      full_in<=1;
    else if (wp-rp==5'b00000)
      empty_in<=1;
    else if (wp-rp==5'b01000)
      half_full_in<=1;
    else begin
        full_in<=0;
        empty_in<=0;
        half_full_in<=0;
      end

    //determine signal overflow
    if(full_in && valid_out_interface)
      overflow_in<=1;
    else
      overflow_in<=0;
  end //always(*)

endmodule
