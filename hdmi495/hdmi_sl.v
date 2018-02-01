`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:46:09 11/30/2015 
// Design Name: 
// Module Name:    hdmi_top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module hdmi_sl(
					clock_pixel,
					clock_TMDS,
					iRed,
					iGreen,
					iBlue,
					
					SYNC_H,
					SYNC_V,
					DE,
					
					oRequest,
					tmdso,
					tmds_30b
					//TMDSp_clock,
					//TMDSn_clock
    );
	 
//********** VGA para of 800*600 **********
	 parameter HAPIX = 11'd800;
	 parameter HFPOR = 11'd40;
	 parameter HSPUL = 11'd128;
	 parameter HBPOR = 11'd88;
	 
	 parameter VAPIX = 11'd600;
	 parameter VFPOR = 11'd1;
	 parameter VSPUL = 11'd4;
	 parameter VBPOR = 11'd23;
	 
//*********** VGA para of 1024*768 *********
	 /*parameter HAPIX = 11'd1024;
	 parameter HFPOR = 11'd24;
	 parameter HSPUL = 11'd136;
	 parameter HBPOR = 11'd160;
	 
	 parameter VAPIX = 11'd768;
	 parameter VFPOR = 11'd3;
	 parameter VSPUL = 11'd6;
	 parameter VBPOR = 11'd29;*/

//******** I\O List **********
input clock_pixel;							//50M
input clock_TMDS;								//250M
input [7:0] iRed;
input [7:0] iGreen;
input [7:0] iBlue;

input SYNC_H;
input SYNC_V;
input DE;

output oRequest;
output [2:0] tmdso;
output [29:0] tmds_30b;
//output TMDSp_clock, TMDSn_clock;
//***** Reg List *****
reg [10:0] contX;
reg [10:0] contY;
wire actvA;

reg [3:0] TMDS_modulo;
reg shift_LOAD;
reg [9:0] TMDS_shift_red, TMDS_shift_green, TMDS_shift_blue;
reg [7:0] red, green, blue;
//***** Wire List *****
wire syncH, syncV;
wire [7:0] W, A;
wire [9:0] TMDS_red, TMDS_green, TMDS_blue;

initial
begin
		contX <= 0;
		contY <= 0;
		
		TMDS_modulo <= 0;
		shift_LOAD <= 0;
		TMDS_shift_red <= 0;
		TMDS_shift_green <= 0;
		TMDS_shift_blue <= 0;
end

//*****###################### RTL code ######################*****
/*always@(posedge clock_pixel)
begin
		if(contX == HAPIX+HFPOR+HSPUL+HBPOR)
				contX = 0;
		else
				contX = contX + 1;
end

always@(posedge clock_pixel)
begin
		if(contX == HAPIX+HFPOR+HSPUL+HBPOR)
		begin
				if(contY == VAPIX+VFPOR+VSPUL+VBPOR)
						contY = 0;
				else
						contY = contY + 1;
		end
		else
				contY = contY;
end

always@(posedge clock_pixel)
		syncH <= (contX >= HAPIX+HFPOR) && (contX < HAPIX+HFPOR+HSPUL);
always@(posedge clock_pixel)
		syncV <= (contY >= VAPIX+VFPOR) && (contY < VAPIX+VFPOR+VSPUL);
always@(posedge clock_pixel)
		actvA <= (contX < HAPIX) && (contY < VAPIX);
		
assign oRequest = (contY == VAPIX+VFPOR+VSPUL+VBPOR) || (contY < VAPIX);*/
//******************** Synchronized timing ***********************

always@(negedge clock_pixel)
begin
		if(!DE)
			contX = 0;
		else
			contX = contX + 1;
end
assign actvA = ((contX<=HAPIX)&&(contX>0)) ? 1 : 0;			// this works if DELL 24' + WINDOWS7
//assign actvA = DE;
assign oRequest = ~SYNC_V;										//This is 100% correct

assign syncH = ~SYNC_H;
assign syncV = ~SYNC_V;
//*********** Pattern to Display ****************
/*assign red = {contX[5:0] & {6{contY[4:3] == ~contX[4:3]}}, 2'b00};
assign green = contX[7:0] & {8{contY[6]}};
assign blue = contY[7:0];*/

assign W = {8{contX[7:0]==contY[7:0]}};
assign A = {8{contX[7:5]==3'h2 && contY[7:5]==3'h2}};

always @(posedge clock_pixel) red <= ({contX[5:0] & {6{contY[4:3]==~contX[4:3]}}, 2'b00} | W) & ~A;
always @(posedge clock_pixel) green <= (contX[7:0] & {8{contY[6]}} | W) & ~A;
always @(posedge clock_pixel) blue <= contY[7:0] | W | A;
//***********************************************
TMDS_encoder  iRED  (.clk(clock_pixel), .VD(iRed),   .CD(2'b00), 		     .VDE(actvA), .TMDS(TMDS_red));
TMDS_encoder  iGREEN(.clk(clock_pixel), .VD(iGreen), .CD(2'b00), 			  .VDE(actvA), .TMDS(TMDS_green));
TMDS_encoder  iBLUE (.clk(clock_pixel), .VD(iBlue),  .CD({syncV, syncH}), .VDE(actvA), .TMDS(TMDS_blue));

always@(posedge clock_TMDS)
begin
		TMDS_shift_red   <= shift_LOAD ? TMDS_red   : TMDS_shift_red[9:1];
		TMDS_shift_green <= shift_LOAD ? TMDS_green : TMDS_shift_green[9:1];
		TMDS_shift_blue  <= shift_LOAD ? TMDS_blue  : TMDS_shift_blue[9:1];
		
		TMDS_modulo <= (TMDS_modulo == 9) ? 4'd0 : TMDS_modulo + 1;
end
always@(posedge clock_TMDS)
		shift_LOAD <= (TMDS_modulo == 9);
//*********** Differential Output ***************
assign tmdso = {TMDS_shift_red[0], TMDS_shift_green[0], TMDS_shift_blue[0]};
assign tmds_30b = {TMDS_red[9:5], TMDS_green[9:5], TMDS_blue[9:5],
						 TMDS_red[4:0], TMDS_green[4:0], TMDS_blue[4:0]};
//OBUFDS mCLOCK(.I(oclock), .O(TMDSp_clock), .OB(TMDSn_clock));
endmodule
