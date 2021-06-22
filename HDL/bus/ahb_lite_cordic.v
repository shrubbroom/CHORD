module ahb_lite_cordic
  #(
    parameter INPUT_WIDTH = 16,
    parameter OUTPUT_WIDTH = 16
    )(
      //ABB-Lite side
      //Select
      input                 HSEL,
      //Global signals
      input                 HCLK,
      input                 HRESETn,
      //Address and control
      input [ 31 : 0 ]      HADDR,
      input [ 2 : 0 ]       HBURST, //ignored
      input                 HMASTLOCK, // ignored
      input [ 3 : 0 ]       HPROT, // ignored
      input [ 2 : 0 ]       HSIZE,//000=8bits,001=16bits,010=32bits
      input [ 1 : 0 ]       HTRANS,//Transfer type
      input                 HWRITE,//1=write 0=read
      input                 HREADY,
      //Master data
      input [ 31 : 0 ]      HWDATA,//Write data from master to slave

      //Transfer response
      output                HREADYOUT,//1=transfer finish
      output                HRESP, //Transfer success or failure
      //Slave Data
      output reg [ 31 : 0 ] HRDATA,


      //CORDIC side
      output reg [31:0]     interface_in,
      input [31:0]          interface_out
      );

   //FSM states
   parameter                S_IDLE              =0,
                            S_INIT              =1,
                            S_READ              =2,
                            S_WRITE             =3;

   reg [  5 : 0 ]           State, Next;
   // reg     [ 24 : 0 ]              delay_u;
   // reg     [  4 : 0 ]              delay_n;
   // reg     [  2 : 0 ]              HSIZE_old;
   // reg     [ 31 : 0 ]              HADDR_old;
   // reg                             HWRITE_old;
   // reg     [  1 : 0 ]              HTRANS_old;
   // reg     [ 31 : 0 ]              DATA;

   parameter                HTRANS_IDLE = 2'b0;

   assign  HRESP  = 1'b0;
   assign  HREADYOUT = (State == S_IDLE);

   wire                     NeedAction = (HTRANS != HTRANS_IDLE) && HSEL && HREADY;
   // wire    NeedRefresh         = ~|delay_u;
   // wire    DelayFinished       = ~|delay_n;
   // wire    BigDelayFinished    = ~|delay_u;
   // wire    RepeatsFinished     = ~|repeat_cnt;

   always @ (posedge HCLK) begin
      if (~HRESETn)
        State <= S_INIT;
      else
        State <= Next;
   end

   always @ (*) begin

      //State change decision
      case(State)
        S_IDLE : Next = NeedAction ? (HWRITE ? S_WRITE : S_READ): S_IDLE;
        S_INIT : Next = NeedAction ? (HWRITE ? S_WRITE : S_READ) : S_IDLE;
        S_READ : Next = S_IDLE;
        S_WRITE : Next = S_IDLE;
      endcase
   end

   // always @ (posedge HCLK) begin
   //     //data and addr operations
   //     case(State)
   //         S_INIT,
   //         S_IDLE              :   if (HSEL) begin
   //                                     HADDR_old   <= HADDR;   HWRITE_old  <= HWRITE;
   //                                     HSIZE_old   <= HSIZE;   HTRANS_old  <= HTRANS;
   //                                 end
   //         S_READ         :    HRDATA <= { DQ, DATA [15:0] };
   //         S_WRITE0        :   DATA <= HWDATA;
   //         default             :   ;
   //     endcase
   // end


   // set CORDIC i/o
   always @ (*) begin
      //data
      case(State)
        default       :   interface_in = 32'bz; // 32'b0
        S_READ        :   HRDATA = interface_out;
        S_WRITE       :   interface_in = HWDATA;
      endcase
   end

endmodule //ahb_lite_cordic
