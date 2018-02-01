`timescale 1 ns / 1 ps

`define DIRECTPASS
`define EDID256

module dvi_demo (
  //input wire        rstbtn_n,    //The pink reset button
  input wire        clk100,      //100 MHz osicallator
  input wire [3:0]  RX0_TMDS,
  input wire [3:0]  RX0_TMDSB,
  //input wire [3:0]  RX1_TMDS,
  //input wire [3:0]  RX1_TMDSB,

  output wire [3:0] TX0_TMDS,
  output wire [3:0] TX0_TMDSB,
  //output wire [3:0] TX1_TMDS,
  //output wire [3:0] TX1_TMDSB,
  
  inout wire DDC_SCL,
  inout wire DDC_SDA,

  input wire MSW,						//mechanical switch on miniSpartan6+ board

  output wire [7:0] LED,
  output wire [1:0] test_pin
);

  wire rstbtn_n;
  wire [1:0] SW;
  assign rstbtn_n = 1'b1;
  assign SW = 2'b00;

  ////////////////////////////////////////////////////
  // 25 MHz and switch debouncers
  ////////////////////////////////////////////////////
  wire clk25, clk25m;

  BUFIO2 #(.DIVIDE_BYPASS("FALSE"), .DIVIDE(3))								//5 
  sysclk_div (.DIVCLK(clk25m), .IOCLK(), .SERDESSTROBE(), .I(clk100));

  BUFG clk25_buf (.I(clk25m), .O(clk25));

  wire [1:0] sws;

  synchro #(.INITIALIZE("LOGIC0"))
  synchro_sws_0 (.async(SW[0]),.sync(sws[0]),.clk(clk25));

  synchro #(.INITIALIZE("LOGIC0"))
  synchro_sws_1 (.async(SW[1]),.sync(sws[1]),.clk(clk25));

  wire [1:0] select = sws;

  reg [1:0] select_q = 2'b00;
  reg [1:0] switch = 2'b00;
  always @ (posedge clk25) begin
    select_q <= select;

    switch[0] = select[0] ^ select_q[0];
    switch[1] = select[1] ^ select_q[1];
  end

`ifdef EDID256 
edid_256 OPTOMA(
				.CLOCK_50					(clk25),
				
				.SCL							(DDC_SCL),
				.SDA							(DDC_SDA),
				
				.SW							(),
				.dLED							()
    );
`else 
ddc_edid  DELL15(
					.CLOCK_50				(clk25),
					
					.SCL						(DDC_SCL),
					.SDA						(DDC_SDA),
					
					.dLED						()
);
`endif
  /////////////////////////
  //
  // Input Port 0
  //
  /////////////////////////
  wire rx0_pclk, rx0_pclkx2, rx0_pclkx10, rx0_pllclk0;
  wire rx0_plllckd;
  wire rx0_reset;
  wire rx0_serdesstrobe;
  wire rx0_hsync;          // hsync data
  wire rx0_vsync;          // vsync data
  wire rx0_de;             // data enable
  wire rx0_psalgnerr;      // channel phase alignment error
  wire [7:0] rx0_red;      // pixel data out
  wire [7:0] rx0_green;    // pixel data out
  wire [7:0] rx0_blue;     // pixel data out
  wire [29:0] rx0_sdata;
  wire rx0_blue_vld;
  wire rx0_green_vld;
  wire rx0_red_vld;
  wire rx0_blue_rdy;
  wire rx0_green_rdy;
  wire rx0_red_rdy;

  dvi_decoder dvi_rx0 (
    //These are input ports
    .tmdsclk_p   (RX0_TMDS[3]),
    .tmdsclk_n   (RX0_TMDSB[3]),
    .blue_p      (RX0_TMDS[0]),
    .green_p     (RX0_TMDS[1]),
    .red_p       (RX0_TMDS[2]),
    .blue_n      (RX0_TMDSB[0]),
    .green_n     (RX0_TMDSB[1]),
    .red_n       (RX0_TMDSB[2]),
    .exrst       (~rstbtn_n),

    //These are output ports
    .reset       (rx0_reset),
    .pclk        (rx0_pclk),
    .pclkx2      (rx0_pclkx2),
    .pclkx10     (rx0_pclkx10),
    .pllclk0     (rx0_pllclk0), // PLL x10 output
    .pllclk1     (rx0_pllclk1), // PLL x1 output
    .pllclk2     (rx0_pllclk2), // PLL x2 output
    .pll_lckd    (rx0_plllckd),
    .tmdsclk     (rx0_tmdsclk),
    .serdesstrobe(rx0_serdesstrobe),
    .hsync       (rx0_hsync),
    .vsync       (rx0_vsync),
    .de          (rx0_de),

    .blue_vld    (rx0_blue_vld),
    .green_vld   (rx0_green_vld),
    .red_vld     (rx0_red_vld),
    .blue_rdy    (rx0_blue_rdy),
    .green_rdy   (rx0_green_rdy),
    .red_rdy     (rx0_red_rdy),

    .psalgnerr   (rx0_psalgnerr),

    .sdout       (rx0_sdata),
    .red         (rx0_red),
    .green       (rx0_green),
    .blue        (rx0_blue)); 

  /////////////////////////
  //
  // Input Port 1
  //
  /////////////////////////
  /*wire rx1_pclk, rx1_pclkx2, rx1_pclkx10, rx1_pllclk0;
  wire rx1_plllckd;
  wire rx1_reset;
  wire rx1_serdesstrobe;
  wire rx1_hsync;          // hsync data
  wire rx1_vsync;          // vsync data
  wire rx1_de;             // data enable
  wire rx1_psalgnerr;      // channel phase alignment error
  wire [7:0] rx1_red;      // pixel data out
  wire [7:0] rx1_green;    // pixel data out
  wire [7:0] rx1_blue;     // pixel data out
  wire [29:0] rx1_sdata;
  wire rx1_blue_vld;
  wire rx1_green_vld;
  wire rx1_red_vld;
  wire rx1_blue_rdy;
  wire rx1_green_rdy;
  wire rx1_red_rdy;

  dvi_decoder dvi_rx1 (
    //These are input ports
    .tmdsclk_p   (RX1_TMDS[3]),
    .tmdsclk_n   (RX1_TMDSB[3]),
    .blue_p      (RX1_TMDS[0]),
    .green_p     (RX1_TMDS[1]),
    .red_p       (RX1_TMDS[2]),
    .blue_n      (RX1_TMDSB[0]),
    .green_n     (RX1_TMDSB[1]),
    .red_n       (RX1_TMDSB[2]),
    .exrst       (~rstbtn_n),

    //These are output ports
    .reset       (rx1_reset),
    .pclk        (rx1_pclk),
    .pclkx2      (rx1_pclkx2),
    .pclkx10     (rx1_pclkx10),
    .pllclk0     (rx1_pllclk0), // PLL x10 outptu
    .pllclk1     (rx1_pllclk1), // PLL x1 output
    .pllclk2     (rx1_pllclk2), // PLL x2 output
    .pll_lckd    (rx1_plllckd),
    .tmdsclk     (rx1_tmdsclk),
    .serdesstrobe(rx1_serdesstrobe),
    .hsync       (rx1_hsync),
    .vsync       (rx1_vsync),
    .de          (rx1_de),

    .blue_vld    (rx1_blue_vld),
    .green_vld   (rx1_green_vld),
    .red_vld     (rx1_red_vld),
    .blue_rdy    (rx1_blue_rdy),
    .green_rdy   (rx1_green_rdy),
    .red_rdy     (rx1_red_rdy),

    .psalgnerr   (rx1_psalgnerr),

    .sdout       (rx1_sdata),
    .red         (rx1_red),
    .green       (rx1_green),
    .blue        (rx1_blue)); */
	 

  // TMDS output
`ifdef DIRECTPASS
  wire rstin         = rx0_reset;
  wire pclk          = rx0_pclk;
  wire pclkx2        = rx0_pclkx2;
  wire pclkx10       = rx0_pclkx10;
  wire serdesstrobe  = rx0_serdesstrobe;
  wire [29:0] s_data = rx0_sdata;
  
  wire [29:0] ssl_data = tmds_data;
  wire [29:0] datain;

  //
  // Forward TMDS Clock Using OSERDES2 block
  //
  reg [4:0] tmdsclkint = 5'b00000;
  reg toggle = 1'b0;

  always @ (posedge pclkx2 or posedge rstin) begin
    if (rstin)
      toggle <= 1'b0;
    else
      toggle <= ~toggle;
  end

  always @ (posedge pclkx2) begin
    if (toggle)
      tmdsclkint <= 5'b11111;
    else
      tmdsclkint <= 5'b00000;
  end

  wire tmdsclk;

  serdes_n_to_1 #(
    .SF           (5))
  clkout (
    .iob_data_out (tmdsclk),
    .ioclk        (pclkx10),
    .serdesstrobe (serdesstrobe),
    .gclk         (pclkx2),
    .reset        (rstin),
    .datain       (tmdsclkint));

  OBUFDS TMDS3 (.I(tmdsclk), .O(TX0_TMDS[3]), .OB(TX0_TMDSB[3]));

  wire [4:0] tmds_data0, tmds_data1, tmds_data2;
  wire [2:0] tmdsint;

  //
  // Forward TMDS Data: 3 channels
  //
  serdes_n_to_1 #(.SF(5)) oserdes0 (
             .ioclk(pclkx10),
             .serdesstrobe(serdesstrobe),
             .reset(rstin),
             .gclk(pclkx2),
             .datain(tmds_data0),
             .iob_data_out(tmdsint[0])) ;

  serdes_n_to_1 #(.SF(5)) oserdes1 (
             .ioclk(pclkx10),
             .serdesstrobe(serdesstrobe),
             .reset(rstin),
             .gclk(pclkx2),
             .datain(tmds_data1),
             .iob_data_out(tmdsint[1])) ;

  serdes_n_to_1 #(.SF(5)) oserdes2 (
             .ioclk(pclkx10),
             .serdesstrobe(serdesstrobe),
             .reset(rstin),
             .gclk(pclkx2),
             .datain(tmds_data2),
             .iob_data_out(tmdsint[2])) ;

  OBUFDS TMDS0 (.I(tmdsint[0]), .O(TX0_TMDS[0]), .OB(TX0_TMDSB[0]));
  OBUFDS TMDS1 (.I(tmdsint[1]), .O(TX0_TMDS[1]), .OB(TX0_TMDSB[1]));
  OBUFDS TMDS2 (.I(tmdsint[2]), .O(TX0_TMDS[2]), .OB(TX0_TMDSB[2]));
  
  assign datain = (msw==1) ? ssl_data : s_data;

  convert_30to15_fifo pixel2x (
    .rst     (rstin),
    .clk     (pclk),
    .clkx2   (pclkx2),
    .datain  (datain),				//datain: switch between sl and pc; s_data: always pc
    .dataout ({tmds_data2, tmds_data1, tmds_data0}));

`else
  /////////////////
  //
  // Output Port 0
  //
  /////////////////
  wire         tx0_de;
  wire         tx0_pclk;
  wire         tx0_pclkx2;
  wire         tx0_pclkx10;
  wire         tx0_serdesstrobe;
  wire         tx0_reset;
  wire [7:0]   tx0_blue;
  wire [7:0]   tx0_green;
  wire [7:0]   tx0_red;
  wire         tx0_hsync;
  wire         tx0_vsync;
  wire         tx0_pll_reset;

  /*assign tx0_de           = (select[0]) ? rx1_de    : rx0_de;
  assign tx0_blue         = (select[0]) ? rx1_blue  : rx0_blue;
  assign tx0_green        = (select[0]) ? rx1_green : rx0_green;
  assign tx0_red          = (select[0]) ? rx1_red   : rx0_red;
  assign tx0_hsync        = (select[0]) ? rx1_hsync : rx0_hsync;
  assign tx0_vsync        = (select[0]) ? rx1_vsync : rx0_vsync;
  assign tx0_pll_reset    =  switch[0] | ((select[0]) ? rx1_reset : rx0_reset);*/
  assign tx0_de           = rx0_de;
  assign tx0_blue         = rx0_blue;
  assign tx0_green        = rx0_green;
  assign tx0_red          = rx0_red;
  assign tx0_hsync        = rx0_hsync;
  assign tx0_vsync        = rx0_vsync;
  assign tx0_pll_reset    =  switch[0] | rx0_reset;

  //////////////////////////////////////////////////////////////////
  // Instantiate a dedicate PLL for output port
  //////////////////////////////////////////////////////////////////
  wire tx0_clkfbout, tx0_clkfbin, tx0_plllckd;
  wire tx0_pllclk0, tx0_pllclk2;

  PLL_BASE # (
    .CLKIN_PERIOD(10),
    .CLKFBOUT_MULT(10), //set VCO to 10x of CLKIN
    .CLKOUT0_DIVIDE(1),
    .CLKOUT1_DIVIDE(10),
    .CLKOUT2_DIVIDE(5),
    .COMPENSATION("SOURCE_SYNCHRONOUS")
  ) PLL_OSERDES_0 (
    .CLKFBOUT(tx0_clkfbout),
    .CLKOUT0(tx0_pllclk0),
    .CLKOUT1(),
    .CLKOUT2(tx0_pllclk2),
    .CLKOUT3(),
    .CLKOUT4(),
    .CLKOUT5(),
    .LOCKED(tx0_plllckd),
    .CLKFBIN(tx0_clkfbin),
    .CLKIN(tx0_pclk),
    .RST(tx0_pll_reset)
  );
  
  /*pll_65m PLL_65(
					  .CLK_IN1				(tx0_pclk),
					  .CLKFB_IN				(tx0_clkfbin),
					  
					  .CLK_OUT1				(tx0_pllclk0),
					  .CLK_OUT2				(),
					  .CLK_OUT3				(tx0_pllclk2),
					  .CLKFB_OUT			(tx0_clkfbout),
					  
					  .RESET					(tx0_pll_reset),
					  .LOCKED				(tx0_plllckd)
 );*/

  //
  // This BUFGMUX directly selects between two RX PLL pclk outputs
  // This way we have a matched skew between the RX pclk clocks and the TX pclk
  //
  /*BUFGMUX tx0_bufg_pclk (.S(select[0]), .I1(rx1_pllclk1), .I0(rx0_pllclk1), .O(tx0_pclk));*/
  BUFG tx0_bufg_pclk (.I(rx0_pllclk1), .O(tx0_pclk));

  //
  // This BUFG is needed in order to deskew between PLL clkin and clkout
  // So the tx0 pclkx2 and pclkx10 will have the same phase as the pclk input
  //
  BUFG tx0_clkfb_buf (.I(tx0_clkfbout), .O(tx0_clkfbin));

  //
  // regenerate pclkx2 for TX
  //
  BUFG tx0_pclkx2_buf (.I(tx0_pllclk2), .O(tx0_pclkx2));

  //
  // regenerate pclkx10 for TX
  //
  wire tx0_bufpll_lock;
  BUFPLL #(.DIVIDE(5)) tx0_ioclk_buf (.PLLIN(tx0_pllclk0), .GCLK(tx0_pclkx2), .LOCKED(tx0_plllckd),
           .IOCLK(tx0_pclkx10), .SERDESSTROBE(tx0_serdesstrobe), .LOCK(tx0_bufpll_lock));

  assign tx0_reset = ~tx0_bufpll_lock;

  dvi_encoder_top dvi_tx0 (
    .pclk        (tx0_pclk),
    .pclkx2      (tx0_pclkx2),
    .pclkx10     (tx0_pclkx10),
    .serdesstrobe(tx0_serdesstrobe),
    .rstin       (tx0_reset),
    .blue_din    (tx0_blue),
    .green_din   (tx0_green),
    .red_din     (tx0_red),
    .hsync       (tx0_hsync),
    .vsync       (tx0_vsync),
    .de          (tx0_de),
    .TMDS        (TX0_TMDS),
    .TMDSB       (TX0_TMDSB));

  /////////////////
  //
  // Output Port 1
  //
  /////////////////
  /*wire         tx1_de;
  wire         tx1_pclk;
  wire         tx1_pclkx2;
  wire         tx1_pclkx10;
  wire         tx1_serdesstrobe;
  wire         tx1_reset;
  wire [7:0]   tx1_blue;
  wire [7:0]   tx1_green;
  wire [7:0]   tx1_red;
  wire         tx1_hsync;
  wire         tx1_vsync;
  wire         tx1_pll_reset;

  assign tx1_de           = (select[1]) ? rx1_de    : rx0_de;
  assign tx1_blue         = (select[1]) ? rx1_blue  : rx0_blue;
  assign tx1_green        = (select[1]) ? rx1_green : rx0_green;
  assign tx1_red          = (select[1]) ? rx1_red   : rx0_red;
  assign tx1_hsync        = (select[1]) ? rx1_hsync : rx0_hsync;
  assign tx1_vsync        = (select[1]) ? rx1_vsync : rx0_vsync;
  assign tx1_pll_reset    =  switch[1] | ((select[1]) ? rx1_reset : rx0_reset);

  //////////////////////////////////////////////////////////////////
  // Instantiate a dedicate PLL for output port
  //////////////////////////////////////////////////////////////////
  wire tx1_clkfbout, tx1_clkfbin, tx1_plllckd;
  wire tx1_pllclk0,  tx1_pllclk2;

  PLL_BASE # (
    .CLKIN_PERIOD(10),
    .CLKFBOUT_MULT(10), //set VCO to 10x of CLKIN
    .CLKOUT0_DIVIDE(1),
    .CLKOUT1_DIVIDE(10),
    .CLKOUT2_DIVIDE(5),
    .COMPENSATION("SOURCE_SYNCHRONOUS")
  ) PLL_OSERDES_1 (
    .CLKFBOUT(tx1_clkfbout),
    .CLKOUT0(tx1_pllclk0),
    .CLKOUT1(),
    .CLKOUT2(tx1_pllclk2),
    .CLKOUT3(),
    .CLKOUT4(),
    .CLKOUT5(),
    .LOCKED(tx1_plllckd),
    .CLKFBIN(tx1_clkfbin),
    .CLKIN(tx1_pclk),
    .RST(tx1_pll_reset)
  );

  //
  // This BUFGMUX selects between two RX PLL pclk outputs
  // This way we have a matched skew between the RX pclk clocks and the TX pclk
  //
  BUFGMUX tx1_bufg_pclk (.S(select[1]), .I1(rx1_pllclk1), .I0(rx0_pllclk1), .O(tx1_pclk));

  //
  // This BUFG is needed in order to deskew between PLL clkin and clkout
  // So the tx1 pclkx2 and pclkx10 will have the same phase as the pclk input
  //
  BUFG tx1_clkfb_buf (.I(tx1_clkfbout), .O(tx1_clkfbin));

  //
  // regenerate pclkx2 for TX
  //
  BUFG tx1_pclkx2_buf (.I(tx1_pllclk2), .O(tx1_pclkx2));

  //
  // regenerate pclkx10 for TX
  //
  wire tx1_bufpll_lock;
  BUFPLL #(.DIVIDE(5)) tx1_ioclk_buf (.PLLIN(tx1_pllclk0), .GCLK(tx1_pclkx2), .LOCKED(tx1_plllckd),
           .IOCLK(tx1_pclkx10), .SERDESSTROBE(tx1_serdesstrobe), .LOCK(tx1_bufpll_lock));

  assign tx1_reset = ~tx1_bufpll_lock;

  dvi_encoder_top dvi_tx1 (
    .pclk        (tx1_pclk),
    .pclkx2      (tx1_pclkx2),
    .pclkx10     (tx1_pclkx10),
    .serdesstrobe(tx1_serdesstrobe),
    .rstin       (tx1_reset),
    .blue_din    (tx1_blue),
    .green_din   (tx1_green),
    .red_din     (tx1_red),
    .hsync       (tx1_hsync),
    .vsync       (tx1_vsync),
    .de          (tx1_de),
    .TMDS        (TX1_TMDS),
    .TMDSB       (TX1_TMDSB));*/
`endif

  //////////////////////////////////////
  // Status LED
  //////////////////////////////////////
  /*assign LED = {rx0_red_rdy, rx0_green_rdy, rx0_blue_rdy, rx1_red_rdy, rx1_green_rdy, rx1_blue_rdy,
                rx0_de, rx1_de};*/
  reg [31:0] crx0 = 0;
  reg [31:0] cpll = 0;
  reg [31:0] cpll25 = 0;
  reg [31:0] ctmds = 0;
  always@(posedge rx0_pclk)
		crx0 = crx0 + 1;
  always@(posedge rx0_pllclk1)
	   cpll = cpll + 1;
  always@(posedge clk25)
	   cpll25 = cpll25 + 1;
  always@(posedge rx0_tmdsclk)
      ctmds = ctmds + 1;
		
  //assign LED[7:0] = {2'b00, MSW, crx0[25], cpll[25], cpll25[23], ctmds[24], rx0_psalgnerr};
  
//******************* Below is the Structured Light output ***************************
wire rstb;
wire sync_hs, sync_vs, de;
wire [7:0] cosd3;
wire [2:0] tmdso;
wire [29:0] tmds_data;


reg wrst = 0;
reg [7:0] pdata = 0;
reg msw = 0;
reg [15:0] fr_cntr = 0;
reg [31:0] px_cntr = 0;
reg [7:0] pixel_1st = 0;

assign sync_hs = rx0_hsync;
assign sync_vs = rx0_vsync;
assign de = rx0_de;
//*************************** Use mechanical switch *************************
/*always@(posedge rx0_pllclk1)
begin
		if(!sync_vs)
			msw = MSW;
		else
			msw = msw;
end*/
//*************************** Use internal counter **************************
always@(posedge rx0_vsync)
begin
		if(fr_cntr==599)				//toggle every 10 seconds
			fr_cntr = 0;
		else
			fr_cntr = fr_cntr + 1;
end
always@(posedge rx0_vsync)
begin
		if(fr_cntr==599)
			msw = ~msw;
		else
			msw = msw;
end

hdmi_sl  HDMI_PORT2(
					.clock_pixel			(rx0_pllclk1),
					.clock_TMDS				(rx0_pllclk0),
					.iRed						(pdata),
					.iGreen					(pdata),
					.iBlue					(pdata),
									
					.SYNC_H					(sync_hs),
					.SYNC_V					(sync_vs),
					.DE						(de),
					
					.oRequest				(rstb),				//signal to reset the DDS
					.tmdso					(tmdso),
					.tmds_30b				(tmds_data)
);

//************************* Record the 1st pixel in a frame *************************
always@(posedge rx0_pllclk1)
begin
		if(!rx0_vsync)
			px_cntr <= 0;
		else
		begin
			if(de)
				px_cntr <= px_cntr + 1;
			else
				px_cntr <= px_cntr;
		end
end

always@(posedge rx0_pllclk1)
begin
	if(px_cntr==3)								//1 or 2 does not work, as long as >= 3, all good
													//Condition: Dell 24' EDID, Windows7 PC, 800x600 resolution
													
													//1st pixel is px_cntr==2, Condition: Optoma EDID, Dell laptop Windows10, 1280x800 resolution. GREAT.
	begin
		if(msw)
			pixel_1st = rx0_red;				//pdata
		else
			pixel_1st = rx0_red;
	end
	else
		pixel_1st = pixel_1st;
end
assign LED = pixel_1st;
assign test_pin = {rx0_hsync, rx0_de};
//************************************************************************************
always@(posedge rx0_pllclk1)
	 wrst = ~rstb;

ddsc DDSM(
			.clk				(sync_hs),
			.sclr				(~wrst),
			
			.pinc_in			(32'd35791394),
			.poff_in			(0),
			.cosine			(cosd3),
			.phase_out		()						//NC
);

always@(posedge rx0_pllclk1)
begin
		if(!cosd3[7])
				pdata = cosd3 + 128;
		else
				pdata = cosd3[6:0];
end
  
endmodule
