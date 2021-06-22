module fifo(input clk,rst_n,r_en,w_en,
            input  [31:0]  data_w,
            output [31:0] data_r,
            output 	     empty,full,half_full,overflow);
reg [31:0] 		     mem [15:0];
reg [4:0] 		     rp,wp; //read pointer, write pointer
reg 			     full_in,empty_in,half_full_in,overflow_in;

assign full=full_in;
assign empty=empty_in;
assign half_full=half_full_in;
assign overflow=overflow_in;
integer 		     i;

assign data_r=mem[rp[3:0]];

always@(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for(i=16;i!=0;i=i-1)
          mem[i-1]<=0;
        rp<=0;
        wp<=0;
        empty_in<=1;
        full_in<=0;
        half_full_in<=0;
        overflow_in<=0;
        // data_r<=0;
      end

    else begin

        //write
        if (w_en && ~full_in) begin
            mem[wp[3:0]]<=data_w;
            wp<=wp+1;
          end

        //read
        if(r_en && ~empty_in) begin
            // data_r<=mem[rp[3:0]];
            rp<=rp+1;
          end

      end // else rst
  end // always@ (posedge clk or negedge rst_n)

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
    if(full_in && w_en)
      overflow_in<=1;
    else
      overflow_in<=0;
  end //always(*)

endmodule
